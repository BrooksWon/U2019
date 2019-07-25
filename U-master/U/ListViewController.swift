//
//  ListViewController.swift
//  U
//
//  Created by Brooks on 2019/7/25.
//  Copyright © 2019 王建雨. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh

class ListViewController: UIViewController {
    @IBOutlet weak var _tableView: UITableView!
    
    // 顶部刷新
    let _header = MJRefreshNormalHeader()
    // 底部刷新
    let _footer = MJRefreshAutoNormalFooter()
    
    var _messages = NSMutableArray()
    
    var _pageIndex = ""
    
    
    
    @IBAction func backBtnAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 在iOS11 Self-Sizing自动打开后，contentSize和contentOffset都可能发生改变。可以通过以下方式禁用
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        
        //创建一个重用的单元格
        _tableView.register(UINib(nibName:"MessageCell", bundle:nil),
                                    forCellReuseIdentifier:"MessageCell")
        
        // 下拉刷新
        _header.setRefreshingTarget(self, refreshingAction: #selector(ListViewController.headerRefresh))
        // 现在的版本要用mj_header
        _tableView.mj_header = _header
        
        // 上拉刷新
        _footer.setRefreshingTarget(self, refreshingAction: #selector(ListViewController.footerRefresh))
        _tableView.mj_footer = _footer
        
        _tableView.mj_header.beginRefreshing()
    }
    
    
    @objc func headerRefresh() {
        sendMyApiRequest(page: "1")
    }
    
    @objc func footerRefresh() {
        let index = Int.init(_pageIndex)!+1
        
        sendMyApiRequest(page: String.init(format: "%ld", index))
    }

    
    func sendMyApiRequest(page: String) {
        /**
         读列表数据
         get http://ce610.api.yesapi.cn/
         */
        
        // Add URL parameters
        var urlParams : [String:String] = [
            "service":"App.Table.FreeQuery",
            "model_name":"okayapi_message",
            "where":"[[\"id\", \">\", \"1\"]]",
            "order":"[\"id DESC\"]",
            "app_key":"F02583604DD041FE98587855E8F2DEE0"
        ]
        
        urlParams["page"] = page
        urlParams["perpage"] = "5"

        
        let sign = SignTools.createSign(urlParams)
        
        urlParams["sign"] = sign
        
        // Fetch Request
        Alamofire.request("http://ce610.api.yesapi.cn/", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    debugPrint("HTTP Response Body: \(response.data)")
                    
                    if let messages = [Message].deserialize(from: String(data: response.data!, encoding: String.Encoding.utf8)!, designatedPath:"data.list") {
                        messages.forEach({ (message) in
                            print(message!.message_content!)
                        })
                        
                        if (Int(page)==1){
                            self._messages.removeAllObjects()
                            self._messages.addObjects(from: messages as [Any])
                            self._tableView.reloadData()
                        }else {
                            self._messages.addObjects(from: messages as [Any])
                            self._tableView.reloadData()
                        }
                        
                        self._tableView.mj_footer.resetNoMoreData()
                        self._tableView.mj_header.endRefreshing()
                        
                        self._pageIndex = page
                    }
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error)")
                }
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = _messages[indexPath.row] as! Message
        
        return message.cellHeight(name: message.message_nickname! as NSString, content: message.message_content!  as NSString)
    }
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MessageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")
            as! MessageCell
        let message = _messages[indexPath.row] as! Message
        
        cell.fillData(name: message.message_nickname!, content: message.message_content!)

        return cell
    }
    
}
