//
//  MeViewController.swift
//  U
//
//  Created by Brooks on 16/5/4.
//  Copyright © 2016年 王建雨. All rights reserved.
//

import UIKit
import MessageUI
import LLSwitch

class MeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    
    var voiceText:String!
    
    var llSwitch: LLSwitch!
    func setupLLSwitch() -> LLSwitch {
        if nil == llSwitch {
            llSwitch = LLSwitch.init(frame:CGRect(x: 0, y: 0, width: 60, height: 30))
        }
        llSwitch.delegate = self
        return llSwitch
    }
    
    
    @IBAction func backBtnAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    let items = [NSLocalizedString("MessageKey", comment: ""), NSLocalizedString("EncourageKey", comment: ""), NSLocalizedString("ShareKey", comment: ""), NSLocalizedString("ExplanationKey", comment: ""), NSLocalizedString("FeedbackKey", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = (NSString(format: "%@ %@", NSLocalizedString("CurrentVersionKey", comment: ""),version)) as String
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
}

extension MeViewController: UITableViewDelegate {
}

extension MeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell!
        
        if (0 == (indexPath as NSIndexPath).row) {
            let cellID1 = "cellID1"
            cell = tableView.dequeueReusableCell(withIdentifier: cellID1)
            if (nil == cell) {
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellID1)
                cell?.accessoryType = UITableViewCellAccessoryType.none
                cell?.textLabel?.textColor = UIColor.white
                cell?.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell?.backgroundColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 28/255.0, alpha: 1.0)
                for subView in (cell?.subviews)! {
                    (subView as UIView).backgroundColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 28/255.0, alpha: 1.0)
                }
                
                cell?.addSubview(self.setupLLSwitch())
                llSwitch.frame = CGRect(x: cell!.frame.size.width-30/2.0, y: (cell!.frame.size.height-30)/2.0, width: 60, height: 30)
            }
            
            
            cell!.textLabel?.text = items[(indexPath as NSIndexPath).row]
            
            llSwitch.on = isPushturnOn()
            
        }else {
            let cellID2 = "cellID2"
            cell = tableView.dequeueReusableCell(withIdentifier: cellID2)
            if (nil == cell) {
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellID2)
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell?.textLabel?.textColor = UIColor.white
                cell?.selectionStyle = UITableViewCellSelectionStyle.gray
                
                cell?.backgroundColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 28/255.0, alpha: 1.0)
                for subView in (cell?.subviews)! {
                    (subView as UIView).backgroundColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 28/255.0, alpha: 1.0)
                }
            }
            
            
            cell!.textLabel?.text = items[(indexPath as NSIndexPath).row]
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break;
        case 1:
            MobClick.event("pingfen_click")
            
            //评分
            UIApplication.shared.openURL(URL.init(string: "https://itunes.apple.com/us/app/u./id1110613814?l=zh&ls=1&mt=8")!)
            break;
        case 2:
            MobClick.event("share_click")
            
            //分享
            self.share2Other()
            break;
        case 3:
            MobClick.event("gonglue_click")
            
            //攻略
            self.navigationController?.pushViewController(GLViewController.init(), animated: true)
            break;
        case 4:
            MobClick.event("feedback_click")
            
            let mail = MFMailComposeViewController.init()
            mail.setSubject("i wanna hear you say it")
            mail.setToRecipients(["open.self.now@gmail.com"])
            mail.setCcRecipients([])
            mail.setBccRecipients([])
            mail.mailComposeDelegate = self
            
            self.present(mail, animated: true, completion: nil)
        default: break
        }
    }
    
    func share2Other() -> Void {
        
        let description = self.voiceText
        let url = NSURL.init(string: "https://itunes.apple.com/us/app/u./id1110613814?l=zh&ls=1&mt=8")
        let image = UIImage.init(named: "Icon1024x1024")
        
        
        
        let activityVC = UIActivityViewController.init(activityItems: [url!,
                                                                       image!,
                                                                       description!],
                                                       applicationActivities: nil)
        //设置不出现的项目
        //        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact]
        self.present(activityVC, animated: true, completion: {
            //分享回调
        })
    }
    
    
    func isPushturnOn() -> Bool {
        let setting = UIApplication.shared.currentUserNotificationSettings
        if(UIUserNotificationType() != setting!.types) {
            MobClick.event("push_on")
            return true
        }
        MobClick.event("push_off")
        return false
    }
    
}

extension MeViewController: LLSwitchDelegate {
    func didTap(_ llSwitch:LLSwitch) {
        if llSwitch.on {
            MobClick.event("pushON_click")
        }else {
            MobClick.event("pushOFF_click")
        }
    }
    func animationDidStop(for  llSwitch:LLSwitch) {
        if llSwitch.on {
            let setting = UIApplication.shared.currentUserNotificationSettings
            if(UIUserNotificationType() == setting!.types) {
                let url = URL.init(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                    MobClick.event("push_tiaozhuan")
                }
            }
        }
    }
}

extension MeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //todo
        controller.dismiss(animated: true, completion: nil)
    }
}
