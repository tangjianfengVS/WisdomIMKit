//
//  ZHInvestSupAliasVO.swift
//  ZHInvestBusinessiOS
//
//  Created by 汤建锋 on 2018/6/26.
//  Copyright © 2018年 ZHInvest. All rights reserved.
//

import UIKit

class ZHInvestSupAliasVO: NSObject {
    private(set) var custInfoId: String=""
    private(set) var custName: String=""
    private(set) var alias: String=""
    private(set) var isCurrentUser: Bool=false

    init(dict: [String:Any]) {
        custInfoId = (dict["custInfoId"] as? String) ?? ""
        custName = (dict["custName"] as? String) ?? ""
        alias = (dict["alias"] as? String) ?? ""
        if let res = dict["isSelected"] as? Int {
            isCurrentUser = res == 1 ? true:false
        }
    }
    
    func updateSelected() {
        isCurrentUser = true
    }
}
