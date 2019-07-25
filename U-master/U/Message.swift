//
//  Message.swift
//  swift-demo
//
//  Created by Brooks on 2019/7/23.
//  Copyright © 2019 Brooks. All rights reserved.
//

import UIKit
import HandyJSON

class Message: HandyJSON {

    var id: String?
    var uuid: String?
    var add_time: String?
    var update_time: String?
    var ext_data: String?
    var message_nickname: String?
    var message_content: String?
    var message_post_time: String?
    var message_pid: String?
    var message_key: String?
    
    required init() {}
    
    
    public func cellHeight(name:NSString, content:NSString) -> CGFloat {
        let contansHeight = 5*2+10+14
        var height = CGFloat(contansHeight)
        
        let dic = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17.0)]
        let contenHeight = content.boundingRect(with: CGSize.init(width: UIScreen.main.bounds.size.width-5*2, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dic as [NSAttributedStringKey : Any], context: nil).size.height as CGFloat
        
        height += ceil(contenHeight)
        
        return CGFloat(height)
    }
}
