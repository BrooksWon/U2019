//
//  AppDelegate.swift
//  U
//
//  Created by Brooks on 16/5/4.
//  Copyright © 2016年 王建雨. All rights reserved.
//  API服务使用 http://open.yesapi.cn/?r=App/Mine , 绑定了QQ和qq邮箱

import UIKit
import AdSupport
import SCLAlertView
import LTMorphingLabel
import UserNotifications
import UserNotificationsUI
import SwiftyJSON
import iRate
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,iRateDelegate{
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // idfa
        _ = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        //定制光标
        UITextField.appearance().tintColor = UIColor.white
        UITextView.appearance().tintColor = UIColor.white
        
        // 版本更新
        DispatchQueue.global().async {
            (ATAppUpdater.sharedUpdater() as AnyObject).forceOpenNewAppVersion(true)
        }
        
        //configure iRate
        #if DEBUG
            iRate.sharedInstance().daysUntilPrompt = 1
            iRate.sharedInstance().usesCount = 1
            iRate.sharedInstance().eventsUntilPrompt = 1;
        #else
            let dateFormatter = DateFormatter.init()
            dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH-mm-sss")
            let startDate = dateFormatter.date(from: "2018-01-06 12-00-00")
            
            iRate.sharedInstance().firstUsed = startDate
        #endif
        iRate.sharedInstance().useAllAvailableLanguages = true;
        iRate.sharedInstance().promptForNewVersionIfUserRated = true
        
        if (iRate.sharedInstance().shouldPromptForRating() && !iRate.sharedInstance().ratedThisVersion) {
            DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 5, execute: {
                iRate.sharedInstance().promptForRating()
            })
        }
        
        //UM 统计
        let obj = UMAnalyticsConfig.sharedInstance()
        obj?.appKey = "572a0d0fe0f55a9dc1001e9d"
        obj?.ePolicy = REALTIME
        MobClick.start(withConfigure:obj);
        MobClick.setLogEnabled(true);
        MobClick.setCrashReportEnabled(false)
        MobClick.setAppVersion(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        
        // UM push
        UMessage.start(withAppkey: "572a0d0fe0f55a9dc1001e9d", launchOptions: launchOptions, httpsEnable: true)
        UMessage.registerForRemoteNotifications()
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [UNAuthorizationOptions.badge, UNAuthorizationOptions.alert, UNAuthorizationOptions.sound], completionHandler: { (flag, error) in
                if flag {
                    // 用户允许注册push消息
                } else {
                    // 用户不允许注册push消息
                }
            })
            
        } else {
            // Fallback on earlier versions
        }
        
        
        
        #if DEBUG
            UMessage.openDebugMode(true)
        #else
            UMessage.openDebugMode(false);
        #endif
        
        //bugly
         #if DEBUG
            //Bugly.startWithAppId("b75c4596bf")
         #else
        Bugly.start(withAppId: "b75c4596bf")
         #endif
        
        
        //3Dtouch
        if #available(iOS 9.0, *) {
            let shortitem = UIApplicationShortcutItem.init(type: NSLocalizedString("VoiceKey", comment: ""), localizedTitle: NSLocalizedString("VoiceKey", comment: ""), localizedSubtitle: nil, icon: UIApplicationShortcutIcon.init(templateImageName: "nahan"), userInfo: nil)
            
            let shortItems = NSArray.init(object: shortitem)
            
            
            UIApplication.shared.shortcutItems = shortItems as? [UIApplicationShortcutItem]
        } else {
            // Fallback on earlier versions
        }
        
        if (launchOptions != nil) {
            if let notification = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
                let msg = handlePushMessage(message: notification as NSDictionary)
                UserDefaults.standard.set(msg, forKey: "PUSH_MSG_KEY")
                UserDefaults.standard.synchronize()
            }
        }
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let rootNav = window?.rootViewController as! UINavigationController
        
        rootNav.show(MyVoiceViewController.init(), sender: nil)
        
        MobClick.event("3DTouch_btn")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UMessage.registerDeviceToken(deviceToken)
        MobClick.event("Register_success")
        
        let device_ns = NSData.init(data: deviceToken)
        
        var deviceTokenString:String = device_ns.description.trimmingCharacters(in:CharacterSet(charactersIn: "<>" ))
        deviceTokenString = deviceTokenString.replacingOccurrences(of: " ", with: "")
        
        print(deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //如果注册不成功
        MobClick.event("Register_Fail")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleUMPushMessage(message: userInfo as NSDictionary)
    }
    
    //iOS10新增：处理后台点击通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()))! {
            //应用处于后台时的远程推送接受
            //必须加这句代码
            handleUMPushMessage(message: userInfo as NSDictionary)
            // 代表从后台接受消息后进入app
            UIApplication.shared.applicationIconBadgeNumber = 0

        } else{
            //应用处于后台时的本地推送接受
        }
        
        completionHandler()
    }
    
    //iOS10新增：处理前台收到通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()))! {
            handleUMPushMessage(message: userInfo as NSDictionary)
        } else {
            //应用处于前台时的本地推送接受
        }
        
        completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound])
    }
    
    func showPushMsg(userInfo: NSDictionary) {
        
        MobClick.event("showPushMsg")
        
        let msg = handlePushMessage(message: userInfo)
        if (!msg.isKind(of: NSString.classForCoder()) && msg.length <= 0) {
            return
        }
        
        UserDefaults.standard.set(msg, forKey: "PUSH_MSG_KEY")
        UserDefaults.standard.synchronize()
        
        if !(msg.isEqual("")) {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 1)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton(NSLocalizedString("Push_Ok_Key", comment: "")) {
                let vc = (self.window?.rootViewController as! UINavigationController).viewControllers.last as! RootViewController
                vc.changeVoiceText()
                
                MobClick.event("dian_ji_hao_chan_kan_push")
                
            }
            alert.showWarning(NSLocalizedString("NotificationKey", comment: ""), subTitle: msg as String)
        }
    }
    
    func handleUMPushMessage(message:NSDictionary) -> Void {
        //关闭友盟自带的弹出框
        UMessage.setAutoAlert(false)
        
        UMessage.didReceiveRemoteNotification(message as? [AnyHashable : Any])
        
        showPushMsg(userInfo: message)
        
        MobClick.event("didReceiveRemoteNotification")
    }
    
    func handlePushMessage(message: NSDictionary) -> NSString {
        let jsonData = try? JSONSerialization.data(withJSONObject: message, options: [])
        
        let json = try? JSON(data: jsonData!)
        let bodyContent = json!["aps"]["alert"]["body"].string
        if (bodyContent != nil) {
            return bodyContent! as NSString;
        } else {
            print("解析push消息失败")
            return "" as NSString;
        }
    }
    
    func iRateShouldOpenAppStore() -> Bool {
        return true
    }
    
    func iRateShouldPromptForRating() -> Bool {
        return true
    }
}

