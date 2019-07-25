//
//  GLViewController.swift
//  U
//
//  Created by Brooks on 16/5/22.
//  Copyright © 2016年 王建雨. All rights reserved.
//

import UIKit

class GLViewController: UIViewController {
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBAction func backBtnAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.noteTextView.text = NSLocalizedString("NoteTextKey", comment: "")
        self.noteTextView.textColor = UIColor.white
        self.noteTextView.font = UIFont.systemFont(ofSize: 14.0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
