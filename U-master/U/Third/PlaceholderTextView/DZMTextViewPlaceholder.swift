//
//  DZMTextViewPlaceholder.swift
//  DZMTextViewPlaceholder
//
//  Created by haspay on 16/3/16.
//  Copyright © 2016年 DZM. All rights reserved.
//

import UIKit

class DZMTextViewPlaceholder: UITextView {
    
    /// placeholder
    var placeholder:String?{
        didSet{
            if placeholderLabel != nil {
                placeholderLabel.text = placeholder
                setNeedsLayout()
            }
        }
    }
    
    /// placeholderColor
    var placeholderColor:UIColor! = UIColor.lightGray {
        didSet{
            if placeholderLabel != nil {
                placeholderLabel.textColor = placeholderColor
            }
        }
    }
    
    /// placeholderFont
    var placeholderFont:UIFont! = UIFont.systemFont(ofSize: 14) {
        didSet{
            if placeholderLabel != nil {
                placeholderLabel.font = placeholderFont
                setNeedsLayout()
            }
        }
    }
    
    fileprivate var placeholderLabel:UILabel!
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: nil)
        addNotificationCenter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addNotificationCenter()
    }
    
    
    func addNotificationCenter() {
        
        placeholderLabel = UILabel()
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DZMTextViewPlaceholder.textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    deinit {
        
        debugPrint("DZMTextViewPlaceholder 释放了")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if placeholder != nil {
            
            let spaceX:CGFloat = 6

            let maxW = frame.size.width - textContainerInset.left - textContainerInset.right - spaceX
            let maxH = frame.size.height - textContainerInset.top - textContainerInset.bottom
            
            let placeholderLabelSize = (placeholder! as NSString).boundingRect(with: CGSize(width: maxW,height: maxH), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: placeholderFont!], context: nil)
            
            placeholderLabel.frame = CGRect(x: textContainerInset.left + spaceX, y: textContainerInset.top, width: placeholderLabelSize.width, height: placeholderLabelSize.height)
        }
    }
    
    
    // 文本输入监听  如果是插入 attributedText  则需要在插入的地方调用该方法进行监听 比如输入框自定义做的表情插入
    @objc func textDidChange() {
        
        if placeholder != nil && text.isEmpty {
            placeholderLabel.isHidden = false
        }else{
            placeholderLabel.isHidden = true
        }
    }
}
