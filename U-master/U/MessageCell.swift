//
//  MessageCell.swift
//  U
//
//  Created by Brooks on 2019/7/25.
//  Copyright © 2019 王建雨. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillData(name:String, content:String) {
        contentLabel.text = content
        nameLabel.text = name
    }    
}
