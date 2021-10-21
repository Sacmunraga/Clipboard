#import "GlobalFunction.h"
#import <Foundation/Foundation.h>

@implementation GlobalFunction
- (id)init {
    self = [super init];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteBoardNotificationReceived:) name:@"info.sacmunraga.globalNotification" object:nil];
    }

    return self;
}

- (void)pasteBoardNotificationReceived:(NSNotification *)notification {
                     NSLog(@"CLIPBOARD: Notification Received");
}
@end
