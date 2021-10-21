/* =====================================================================================
  *
  *       Filename:  Tweak.c
  *
  *    Description:  Client code, intended for use with the ClipBoard Server. This program
  *    requires a jailbroken iDevice in order to access clipboard contents. Accessing 
  *    clipboard contents is acheived through the UIPasteboard of IOS. There is still
  *    work left to do, primarily in handling the establishing and terimination of the
  *    TCP socket.
  *                 
  *
  *        Version:  1.0
  *        Created:  07/21/2021 21:43:10
  *       Revision:  none
  *       Compiler:  gcc
  *
  *         Author:  Tim Shumeyko/Sacmunraga (tim.shumeyko99@hotmail.com) 
  *
  * =====================================================================================
  */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlobalFunction.h"
#import "CocoaAsyncSocket.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

// Methods from Sprinboard that we are going to modify/"hook"
@interface SpringBoard : UIApplication <GCDAsyncSocketDelegate> 
-(void) applicationDidFinishLaunching:(id)arg1;
-(void) setPasteboard; 
@end

// Pasteboard Variables
static NSTimer *pasteboardCheckTimer;       // Timer for frequently checking UIPasteboard
static NSUInteger pasteboardchangeCount;    // Records the amount of times the UIPasteboard contents were changed.
static UIPasteboard *appPasteBoard;         // UIPasteboard object used throughout the program.

// Server variables
#define MAXDATASIZE 1024                    // Largest size of data allowed to be tranferred between the client and server
bool fromServer = false;                    // Variables used for server initialization.
bool connected = false;                     // -
bool serverStartup = false;                 // -
int sockfd, numbytes;                       // -
char buf[MAXDATASIZE];                      // -
struct hostent *he;                         // -
int reuse_ddr = 1;                          // -
struct sockaddr_in their_addr;              // connector's address information
uint16_t port;                              // port to bind to
char hostname[20];                          // Holds hostname of server

%hook SpringBoard
/*
    In this method we attempt to set server variables and initialize it.
*/
%new
void startServer(void)
{
    //strcpy(hostname, "**IP ADDRESS**, this is unique to every device");    
    //port = 9999;

    NSLog(@"CLIPBOARD: Attempting to connect to server ip: . on port: 9999\n");



    NSLog(@"CLIPBOARD: Connected to server!");

    if ((he=gethostbyname(hostname))== NULL) {  // get the host info 
            herror("gethostbyname");
            return;
        }

        if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
            NSLog(@"CLIPBOARD: socket");
            return; 
        }
        
        setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse_ddr, sizeof(int));
        
        their_addr.sin_family = AF_INET;      // host byte order 
        their_addr.sin_port = htons(port);    // short, network byte order 
        their_addr.sin_addr = *((struct in_addr *)he->h_addr);
        bzero(&(their_addr.sin_zero), 8);     // zero the rest of the struct 

    serverStartup = true;
    
}

/*
    Method intended to help connect the iDevice to the Java server running on a seperate device.
*/
int connectToServer(void)
{
    if (serverStartup)
    {
        if (connect(sockfd, (struct sockaddr *)&their_addr, \
                                              sizeof(struct sockaddr)) == -1) {
            NSLog(@"CLIPBOARD: connect failed");
            connected = false;
            NSLog(@"CLIPBOARD: NOT Connected\n");
            return -1;
        } else {
           connected = true;
           NSLog(@"CLIPBOARD: Connected\n");
           return 0;
        }
    } else
    { 
    return -1;
    }
 
} 

/*
    This method is called every time a UIPasteboard change is detected. Upon being called, it
    attempts to send the just-changed UIPasteboard contents to the server.
*/
%new
-(void) clipboard
{
   
    NSLog(@"CLIPBOARD was changed apparently\n");
    appPasteBoard = [UIPasteboard generalPasteboard];
    NSLog(@"CLIPBOARD: %@\n", [appPasteBoard string]);
    
    NSLog(@"CLIPBOARD: Trying to write new clipbard to server...\n");
    const char *buff = [appPasteBoard.string cStringUsingEncoding: NSUTF8StringEncoding];

    if (!connected)
    {
        NSLog(@"CLIPBOARD: Not connected to server at all!.\n");
        for (int i = 0; i < 10; i++)
        {
        if (!serverStartup)
        {
            startServer();
            }

            connectToServer();
            if (connected)
                break;
                }
        if (!connected)
        {
            NSLog(@"CLIPBOARD: Still couldn't connect, quitting\n");
            return;
            }
     }
    
    if (write(sockfd, buff, strlen(buff) + 1) == -1){
              NSLog(@"CLIPBOARD: send");
              close(sockfd);
              connected = false;
		      //exit (1);
     }
     return;
}

/*
    Method intended to monitor the pasteboard. As soon as a change is detected a
    UIPasteboardChangedNotification is posted alerting our other code that a 
    the UIPasteboard contents has been changed.
*/
%new
-(void) pasteBoardMonitor
{
    NSUInteger changeCount = [[UIPasteboard generalPasteboard] changeCount];
    if (changeCount != pasteboardchangeCount) { // means pasteboard was changed

        pasteboardchangeCount = changeCount;
        [[NSNotificationCenter defaultCenter]
        postNotificationName:UIPasteboardChangedNotification
        object:[UIPasteboard generalPasteboard]];
     }

     /*
     if ((numbytes=recv(sockfd, buf, MAXDATASIZE, 0)) != -1) {
        NSLog(@"CLIPBOARD: data received from server!");
        [[NSNotificationCenter defaultCenter]
        postNotificationName:@"ServerReceivedCrap"
        object:nil];
    
     }*/
     }

/*
    Incomplete method which will potentially monitor data received from the server
*/
%new
-(void) serverMonitor
{
    if (connected)
    {
        if ((numbytes=recv(sockfd, buf, MAXDATASIZE, 0)) != -1) {
         NSLog(@"CLIPBOARD: data received from server!");
         [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ServerReceivedCrap"
         object:nil];
    }
    }
}

/*
    Incomplete method which may potentially aid in setting the pasteboard of the iDevice
*/
%new
-(void) setPasteboard
{

NSLog(@"CLIPBOARD: Entered setPasteboard!");
/*
    while (TRUE)
    {
        if (!connected)
        {
            NSLog(@"CLIPBOARD: Not connected yet");
            sleep(10);
            return;
            }
        memset(buf, 0, sizeof buf);
        if ((numbytes=recv(sockfd, buf, MAXDATASIZE, 0)) == -1) {
                  		NSLog(@"CLIPBOARD recv");
                        sleep(10);
                        continue;
//                        [NSThread sleepForTimeInterval:10.0f];
		    }
  */

    NSLog(@"CLIPBOARD: Entered setPasteboard()");
    fromServer = true;
    NSString *myNSString = [NSString stringWithUTF8String:buf];
    appPasteBoard.string = myNSString;
    //}
}    


/*
    Here we hook into the launch of the SpringBoard.app. We add notification observers so that we know when the Pasteboard was changed.
*/
-(void)applicationDidFinishLaunching:(id)arg1 {
    NSLog(@"CLIPBOARD: Hooked into applicationDidFinishLaunching");
    
    SEL sel = @selector(clipboard);
    pasteboardchangeCount = [[UIPasteboard generalPasteboard] changeCount];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:sel name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPasteboard) name:@"ServerReceivedCrap" object:nil];
    //Start monitoring the paste board
    pasteboardCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(pasteBoardMonitor)
                                                           userInfo:nil
                                                           repeats:YES];
    //[NSThread detachNewThreadSelector:@selector(setPasteboard) toTarget:self withObject:nil];
    %orig;
}
%end

%ctor
{
    @autoreleasepool {
    NSLog(@"CLIPBOARD: LOADED");
    startServer(); 
    //connectToServer();
    }
}
