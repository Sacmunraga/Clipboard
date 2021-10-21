#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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

#define MAXDATASIZE 1024 /* max number of bytes we can get at once */
GCDAsyncSocket *mySocket = NULL;

    int main(int argc, char *argv[])
    {
        mySocket =[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

        uint16_t port = 9999;              // port to bind to
        // Get hostname of server
        char hostname[20] = "192.168.86.36";
        uid_t euid=geteuid();
    
        if (euid != 0) {
            printf("Must run as root user!\n");
            exit(-1);
        } else {
            /* Anything goes. */
        printf("************ Client started ************\n");

        }

        return 0;
    }
