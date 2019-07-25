//
//  SignTools.h
//  swift-demo
//
//  Created by Brooks on 2019/7/24.
//  Copyright © 2019 Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignTools : NSObject
+ (NSString *)createSign:(NSDictionary<NSString*,NSString*> *)para;

@end

NS_ASSUME_NONNULL_END
