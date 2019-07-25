//
//  NotificationController.m
//  iWatch Extension
//
//  Created by Brooks on 2017/12/31.
//  Copyright © 2017年 王建雨. All rights reserved.
//

#import "NotificationController.h"
#import <UserNotifications/UserNotifications.h>
#import "Header.h"

@interface NotificationController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *pushMessageLabel;

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void)didReceiveNotification:(UNNotification *)notification withCompletion:(void(^)(WKUserNotificationInterfaceType interface)) completionHandler {
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
//    completionHandler(WKUserNotificationInterfaceTypeCustom);
    
    //取出自定义的通知的内容并展示到界面的各个组件上
    UNNotificationContent *content = notification.request.content;
    NSString *contentString = (NSString *)[content.userInfo valueForKeyPath:@"alert.body"];
    if (contentString.length > 0) {
        [self.pushMessageLabel setText:contentString];
        [[NSUserDefaults standardUserDefaults] setObject:contentString forKey:kAppleWatchPushNitificationContentKey];
    } else {
        [self.pushMessageLabel setText:kAppleWatchPushNitificationContent];
        [[NSUserDefaults standardUserDefaults] setObject:kAppleWatchPushNitificationContent forKey:kAppleWatchPushNitificationContentKey];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    completionHandler(WKUserNotificationInterfaceTypeDefault);
}


@end



