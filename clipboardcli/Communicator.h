/*
 * =====================================================================================
 *
 *       Filename:  Communicator.h
 *
 *    Description:  Used for client 
 *
 *        Version:  1.0
 *        Created:  12/09/2020 14:27:29
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Tim Shumeyko (shumeyta@dukes.jmu.edu), 
 *   Organization:  James Madison University
 *
 * =====================================================================================
 */

#import <Foundation/Foundation.h>

@interface Communicator : NSObject <NSStreamDelegate>

- (void) setHost: (NSString *) ohost;
- (void) setPort: (int) oport;
- (NSString *) host;
- (int) port;
- (void)setup;
- (void)open;
- (void)close;
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;
- (void)readIn:(NSString *)s;
- (void)writeOut:(NSString *)s;

@end
