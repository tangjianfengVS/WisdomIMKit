//
//  WisdomUserinfo.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

/**
 *  WisdomIMKit 验证登录的数据模型
 *  用于用户IM登录，并且同步获取数据
 */

public class WisdomUserinfo: NSObject {
    
    private(set) var Uin: String!
    private(set) var Sid: String!
    private(set) var Skey: String!
    private(set) var DeviceID: String!

    @objc init(Uin: String, Sid: String, Skey: String, DeviceID: String) {
        self.Uin = Uin
        self.Sid = Sid
        self.Skey = Skey
        self.DeviceID = DeviceID
    }
    
    @objc func toDic() -> [String:String] {
        var dict: [String:String] = [:];
        dict["Uin"] = Uin
        dict["Sid"] = Sid
        dict["Skey"] = Skey
        dict["DeviceID"] = DeviceID
        return dict
    }
}
