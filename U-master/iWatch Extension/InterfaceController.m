//
//  InterfaceController.m
//  iWatch Extension
//
//  Created by Brooks on 2017/12/31.
//  Copyright © 2017年 王建雨. All rights reserved.
//

#import "InterfaceController.h"
#import "Header.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController ()<WCSessionDelegate>
@property (nonatomic, readwrite, strong) WCSession *session;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *contentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *likeButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *hateButton;

@end


@implementation InterfaceController
- (IBAction)hateButtonAction {
    [self.session sendMessage:@{@"sayKey":@"hate"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        NSLog(@"replyMessage = %@", replyMessage);
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
    [self.hateButton setBackgroundImageNamed:@"hate_disable"];
    [self.hateButton setEnabled:NO];
    [self.likeButton setBackgroundImageNamed:@"like_normal"];
    [self.likeButton setEnabled:YES];
    
}
- (IBAction)likeButtonAction {
    [self.session sendMessage:@{@"sayKey":@"like"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        NSLog(@"replyMessage = %@", replyMessage);
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
    
    [self.likeButton setBackgroundImageNamed:@"like_disbale"];
    [self.likeButton setEnabled:NO];
    [self.hateButton setBackgroundImageNamed:@"hate_normal"];
    [self.hateButton setEnabled:YES];
    
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    if (WCSession.isSupported) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    NSString *content = [[NSUserDefaults standardUserDefaults] objectForKey:kAppleWatchPushNitificationContentKey];
    if (content.length <= 0) {
        content = kAppleWatchPushNitificationContent;
    }
    [self.contentLabel setText:content];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    
}

- (void)session:(WCSession *)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(NSError *)error {
    
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void (^)(NSData * _Nonnull))replyHandler {
    
}


@end



