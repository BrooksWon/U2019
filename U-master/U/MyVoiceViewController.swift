//
//  MyVoiceViewController.swift
//  U
//
//  Created by Brooks on 16/5/4.
//  Copyright © 2016年 王建雨. All rights reserved.
//

import UIKit
import SCLAlertView
import Alamofire
import MBProgressHUD

class MyVoiceViewController: UIViewController {
    
    @IBOutlet weak var voiceTextView: DZMTextViewPlaceholder!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commitBtn: UIButton!

    @IBAction func backBtnAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
            
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        self.voiceTextView.placeholder = NSLocalizedString("YourWordsKey", comment: "")
        self.voiceTextView.placeholderColor = UIColor.white
        self.nameTextField.placeholder = NSLocalizedString("WhoAreYouKey", comment: "")
        self.nameTextField.text = NSLocalizedString("WhoAreYouKey", comment: "")
        self.commitBtn.setTitle(NSLocalizedString("SayToTheWorldKey", comment: ""), for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MobClick.endLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }


    @IBAction func commitBtnAction(_ sender: AnyObject) {
        self.view.endEditing(true)
        if (voiceTextView.text.compare(NSLocalizedString("YourWordsKey", comment: "")) == ComparisonResult.orderedSame) || (nameTextField.text!.compare(NSLocalizedString("WhoAreYouKey", comment: "")) == ComparisonResult.orderedSame) || voiceTextView.text.isEmpty || nameTextField.text!.isEmpty {
            MobClick.event("tiaojiaoEmpty_btn")
            return
        }
        
        showSuccess(sender)
        
//        // 利用UM功能统计作为数据提交的api
//        MobClick.event("Feedback", attributes: ["who:":nameTextField.text!,"words:":voiceTextView.text!])
        
        // 利用[http://open.yesapi.cn/?r=Data/MyModelsShowData&model_name=okayapi_message]作为数据提交的api
        sendMyApi2Request(nickname: nameTextField.text!, content: voiceTextView.text!)
        
        // 毛玻璃
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight)) as UIVisualEffectView
        visualEffectView.frame = view.bounds
        visualEffectView.tag = 10086
        view.addSubview(visualEffectView)
    }
    

    @IBAction func showSuccess(_ sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton(NSLocalizedString("ShouDao_Done_Key", comment: "")) {
            self.navigationController?.popViewController(animated: true)
            self.view.viewWithTag(10086)?.removeFromSuperview()
            MobClick.event("tiaojiaoHao_btn")
        }
        alert.addButton(NSLocalizedString("ShouDao_Again_Key", comment: "")) {
            MobClick.event("tiaojiaoAgin_btn")
            self.view.viewWithTag(10086)?.removeFromSuperview()
        }
        alert.showSuccess(NSLocalizedString("ShouDaoKey", comment: ""), subTitle: "")
    }
    
    @objc func hideKeyboardTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        MobClick.event("shou_qi_jian_pan_shou_shi")
    }
    
    
    func sendMyApi2Request(nickname:String, content:String) {
        /**
         写数据
         get http://ce610.api.yesapi.cn/
         */
        
        // Add URL parameters
        var urlParams = [
            "service":"App.Table.Create",
            "model_name":"okayapi_message",
            "app_key":"F02583604DD041FE98587855E8F2DEE0"
        ]
        
        urlParams["data"] = String.init(format: "{\"message_nickname\":\"%@\",\"message_content\":\"%@\"}", nickname,content)
        
        let sign = SignTools.createSign(urlParams)
        
        urlParams["sign"] = sign
        
        // hud
//        let hud = MBProgressHUD.init(view: self.view.window!)
//        hud.animationType = MBProgressHUDAnimation.fade
//        hud.mode = MBProgressHUDMode.indeterminate
//        hud.show(animated: true)
        
        // Fetch Request
        Alamofire.request("http://ce610.api.yesapi.cn/", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    debugPrint("HTTP Response Body: \(response.data)")
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error)")
                }
                
//                hud.hide(animated: true)
        }
    }

}
