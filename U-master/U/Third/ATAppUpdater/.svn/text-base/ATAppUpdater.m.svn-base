/*
 Created by Jean-Pierre Fourie
 Copyright (c) 2015 Apptality Mobile Development <info@apptality.co.za>
 Web: http://www.apptality.co.za
 Git: https://github.com/apptality/ATAppUpdater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#import "ATAppUpdater.h"

@implementation ATAppUpdater


+ (id)sharedUpdater
{
    static ATAppUpdater *sharedUpdater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUpdater = [[ATAppUpdater alloc] init];
    });
    return sharedUpdater;
}


- (BOOL)hasConnection
{
    const char *host = "itunes.apple.com";
    BOOL reachable;
    BOOL success;
    
    // Needs SystemConfiguration.framework! <SystemConfiguration/SystemConfiguration.h>
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    reachable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    CFRelease(reachability);
    return reachable;
}

- (void)forceOpenNewAppVersion:(BOOL)force
{
    BOOL hasConnection = [self hasConnection];
    if (!hasConnection) return;
    
    [self checkNewAppVersionWithBlock:^(BOOL newVersion, NSString *appUrl, NSString *version, NSString*releaseNotes) {
        if (newVersion) {
            [[ATUpdateAlert alertUpdateForVersion:version
                                 withReleaseNotes:(NSString*)releaseNotes
                                          withURL:appUrl
                                        withForce:force] show];
        }
    }];
}

- (void)checkNewAppVersionWithBlock:(void(^)(BOOL newVersion, NSString *appUrl, NSString *version, NSString*releaseNotes))block
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [bundleInfo valueForKey:@"CFBundleIdentifier"];
    NSString *currentVersion = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    NSString  *countryCode = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
//    NSURL *lookupURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/CN/lookup?bundleId=%@", @"cn.tootoo.tuotuogongshe"]];
    NSURL *lookupURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/%@/lookup?bundleId=%@", countryCode, bundleIdentifier]];
    

//============================= 1.use sync =============================
//    NSData *lookupResults = [NSData dataWithContentsOfURL:lookupURL];
//    if (!lookupResults) {
//        block(NO, nil, currentVersion, nil);
//        return;
//    }
//
//    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:lookupResults options:0 error:nil];
//
//    NSUInteger resultCount = [[jsonResults objectForKey:@"resultCount"] integerValue];
//    if (resultCount){
//        NSDictionary *appDetails = [[jsonResults objectForKey:@"results"] firstObject];
//        NSString *appItunesUrl = [[appDetails objectForKey:@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"&uo=4" withString:@""];
//        NSString *latestVersion = [appDetails objectForKey:@"version"];
//        NSString *latestReleaseNotes = [appDetails objectForKey:@"releaseNotes"];
//        if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
//            block(YES, appItunesUrl, latestVersion, latestReleaseNotes);
//        } else {
//            block(NO, nil, currentVersion, nil);
//        }
//    } else {
//        block(NO, nil, currentVersion, nil);
//    }
    
//============================= 2.use GCD async =============================
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *lookupResults = [NSData dataWithContentsOfURL:lookupURL];
//        if (!lookupResults) {
//            block(NO, nil, currentVersion, nil);
//            return;
//        }
//        
//        NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:lookupResults options:0 error:nil];
//        
//        NSUInteger resultCount = [[jsonResults objectForKey:@"resultCount"] integerValue];
//        if (resultCount){
//            NSDictionary *appDetails = [[jsonResults objectForKey:@"results"] firstObject];
//            NSString *appItunesUrl = [[appDetails objectForKey:@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"&uo=4" withString:@""];
//            NSString *latestVersion = [appDetails objectForKey:@"version"];
//            NSString *latestReleaseNotes = [appDetails objectForKey:@"releaseNotes"];
//            if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
//                block(YES, appItunesUrl, latestVersion, latestReleaseNotes);
//            } else {
//                block(NO, nil, currentVersion, nil);
//            }
//        } else {
//            block(NO, nil, currentVersion, nil);
//        }
//    });
    
    
//============================= 3.use NSURLSession dataTaskWithURL =============================
    [[[NSURLSession sharedSession] dataTaskWithURL:lookupURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && CGFLOAT_MIN<data.length) {
            NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSUInteger resultCount = [[jsonResults objectForKey:@"resultCount"] integerValue];
            if (resultCount){
                NSDictionary *appDetails = [[jsonResults objectForKey:@"results"] firstObject];
                NSString *appItunesUrl = [[appDetails objectForKey:@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"&uo=4" withString:@""];
                NSString *latestVersion = [appDetails objectForKey:@"version"];
                NSString *latestReleaseNotes = [appDetails objectForKey:@"releaseNotes"];
                if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                    block(YES, appItunesUrl, latestVersion, latestReleaseNotes);
                } else {
                    block(NO, nil, currentVersion, nil);
                }
            } else {
                block(NO, nil, currentVersion, nil);
            }
        }
    }] resume];
//#warning 以上三种方法都很慢，原因是因为请求appstore本来很慢，这也就是很多app把版本更新request放在自己server的原因之一。
}

@end


@implementation ATUpdateAlert

NSString *appStoreURL = nil;

+ (UIAlertView *)alertUpdateForVersion:(NSString *)version
                      withReleaseNotes:(NSString*)releaseNotes
                               withURL:(NSString *)appUrl
                             withForce:(BOOL)force
{
    appStoreURL = appUrl;
    UIAlertView *alert = nil;
    NSString *tittle = [NSString stringWithFormat:@"发现新版本%@", version];
    NSString *latestReleaseNotes = [NSString stringWithFormat:@"%@", releaseNotes];
    NSString *msg    = [NSString stringWithFormat:@"%@", latestReleaseNotes];
    
    
    if (force) alert = [[UIAlertView alloc] initWithTitle:tittle message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
    else alert = [[UIAlertView alloc] initWithTitle:tittle message:msg delegate:self cancelButtonTitle:@"立即更新" otherButtonTitles:@"稍后再说", nil];
    return alert;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreURL]];
}

@end