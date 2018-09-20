//
//  TestViewController.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        WisdomIMKitManager.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TestViewController: WisdomIMKitManagerDelegate{
    func didReadDataInfo(data: [Any]) {
        
    }
    
    func sessionSynchronUserInfo(info: [String:Any]) {
    
    }
}
