//
//  SignTools.m
//  swift-demo
//
//  Created by Brooks on 2019/7/24.
//  Copyright © 2019 Brooks. All rights reserved.
//

#import "SignTools.h"

#import <CommonCrypto/CommonCrypto.h>

#define kAppKey @"F02583604DD041FE98587855E8F2DEE0"
#define KBaseURL @"http://ce610.api.yesapi.cn/"
#define app_secrect @"5qOO2Wb1KqyRjDnJAsO9Ihh5ywLX1J8GucvmTkYdv9a0tYtAKCYAm6n97s4B9JiiiyOuH0agaToltq"

@implementation SignTools
+ (NSString *)createSign:(NSDictionary<NSString*,NSString*> *)para {
    NSMutableDictionary *paraDic = para.mutableCopy;
    
    //1.将全部参数名字将按字典排序后
    NSArray *sortKeys = [para.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    //2.把对应的参数值依次拼接起来（此时不需要URL编码）
    NSMutableString *paraString = [NSMutableString stringWithCapacity:0];
    for (NSString *key in sortKeys) {
        [paraString appendFormat:@"%@", [para objectForKey:key]];
    }
    
    //3.在最后追加app_secrect
    [paraString appendFormat:@"%@", app_secrect];
    
    //4.进行md5，生成签名sign
    NSString *md5 = [self md5String:paraString];
    
    //5.全部转换成大写
    NSString *sign = [md5 uppercaseString];
    
    //6.最后，追加sign参数
    [paraDic setObject:sign forKey:@"sign"];
    
    return sign;
}

+(NSString *)md5String:(NSString *)sourceString{
    if(!sourceString){
        return nil;//判断sourceString如果为空则直接返回nil。
    }
    //MD5加密都是通过C级别的函数来计算，所以需要将加密的字符串转换为C语言的字符串
    const char *cString = sourceString.UTF8String;
    //创建一个C语言的字符数组，用来接收加密结束之后的字符
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //MD5计算（也就是加密）
    //第一个参数：需要加密的字符串
    //第二个参数：需要加密的字符串的长度
    //第三个参数：加密完成之后的字符串存储的地方
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    //将加密完成的字符拼接起来使用（16进制的）。
    //声明一个可变字符串类型，用来拼接转换好的字符
    NSMutableString *resultString = [[NSMutableString alloc]init];
    //遍历所有的result数组，取出所有的字符来拼接
    for (int i = 0;i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString  appendFormat:@"%02x",result[i]];
        //%02x：x 表示以十六进制形式输出，02 表示不足两位，前面补0输出；超出两位，不影响。当x小写的时候，返回的密文中的字母就是小写的，当X大写的时候返回的密文中的字母是大写的。
    }
    //打印最终需要的字符
    NSLog(@"resultString === %@",resultString);
    return resultString;
}

@end
