#line 1 "Tweak.x"





















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


@interface SpringBoard : UIApplication <GCDAsyncSocketDelegate> 
-(void) applicationDidFinishLaunching:(id)arg1;
-(void) setPasteboard; 
@end


static NSTimer *pasteboardCheckTimer;       
static NSUInteger pasteboardchangeCount;    
static UIPasteboard *appPasteBoard;         


#define MAXDATASIZE 1024                    
bool fromServer = false;                    
bool connected = false;                     
bool serverStartup = false;                 
int sockfd, numbytes;                       
char buf[MAXDATASIZE];                      
struct hostent *he;                         
int reuse_ddr = 1;                          
struct sockaddr_in their_addr;              
uint16_t port;                              
char hostname[20];                          


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; 
static void _logos_method$_ungrouped$SpringBoard$clipboard(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SpringBoard$pasteBoardMonitor(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SpringBoard$serverMonitor(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SpringBoard$setPasteboard(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 

#line 60 "Tweak.x"





void startServer(void)
{
    
    

    NSLog(@"CLIPBOARD: Attempting to connect to server ip: . on port: 9999\n");



    NSLog(@"CLIPBOARD: Connected to server!");

    if ((he=gethostbyname(hostname))== NULL) {  
            herror("gethostbyname");
            return;
        }

        if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
            NSLog(@"CLIPBOARD: socket");
            return; 
        }
        
        setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse_ddr, sizeof(int));
        
        their_addr.sin_family = AF_INET;      
        their_addr.sin_port = htons(port);    
        their_addr.sin_addr = *((struct in_addr *)he->h_addr);
        bzero(&(their_addr.sin_zero), 8);     

    serverStartup = true;
    
}




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







static void _logos_method$_ungrouped$SpringBoard$clipboard(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
   
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
		      
     }
     return;
}








static void _logos_method$_ungrouped$SpringBoard$pasteBoardMonitor(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    NSUInteger changeCount = [[UIPasteboard generalPasteboard] changeCount];
    if (changeCount != pasteboardchangeCount) { 

        pasteboardchangeCount = changeCount;
        [[NSNotificationCenter defaultCenter]
        postNotificationName:UIPasteboardChangedNotification
        object:[UIPasteboard generalPasteboard]];
     }

     







     }






static void _logos_method$_ungrouped$SpringBoard$serverMonitor(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
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






static void _logos_method$_ungrouped$SpringBoard$setPasteboard(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {

NSLog(@"CLIPBOARD: Entered setPasteboard!");


















    NSLog(@"CLIPBOARD: Entered setPasteboard()");
    fromServer = true;
    NSString *myNSString = [NSString stringWithUTF8String:buf];
    appPasteBoard.string = myNSString;
    
}    





static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    NSLog(@"CLIPBOARD: Hooked into applicationDidFinishLaunching");
    
    SEL sel = @selector(clipboard);
    pasteboardchangeCount = [[UIPasteboard generalPasteboard] changeCount];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:sel name:UIPasteboardChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPasteboard) name:@"ServerReceivedCrap" object:nil];
    
    pasteboardCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(pasteBoardMonitor)
                                                           userInfo:nil
                                                           repeats:YES];
    
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
}


static __attribute__((constructor)) void _logosLocalCtor_f7664060(int __unused argc, char __unused **argv, char __unused **envp)
{
    @autoreleasepool {
    NSLog(@"CLIPBOARD: LOADED");
    startServer(); 
    
    }
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(clipboard), (IMP)&_logos_method$_ungrouped$SpringBoard$clipboard, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(pasteBoardMonitor), (IMP)&_logos_method$_ungrouped$SpringBoard$pasteBoardMonitor, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(serverMonitor), (IMP)&_logos_method$_ungrouped$SpringBoard$serverMonitor, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(setPasteboard), (IMP)&_logos_method$_ungrouped$SpringBoard$setPasteboard, _typeEncoding); }{ MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);}} }
#line 275 "Tweak.x"
