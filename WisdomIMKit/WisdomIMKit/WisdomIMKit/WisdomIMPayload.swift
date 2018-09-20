//
//  WisdomIMPayload.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

struct WisdomIMPayload {
    
    private(set) var BaseRequest: WisdomUserinfo?
    private(set) var ClientVersion: UInt32?
    private(set) var SyncKey: [Dictionary<String,Any>]?
    
    init(userinfo: WisdomUserinfo) {
        BaseRequest = userinfo
        ClientVersion = UInt32(131841)
    }
    
    func toDic() -> [String:Any] {
        var dict: [String:Any] = [:];
        dict["BaseRequest"] = BaseRequest!.toDic()
        dict["ClientVersion"] = ClientVersion
        
        if SyncKey != nil && SyncKey!.count > 0 {
            dict["SyncKey"] = SyncKey
        }
        return dict
    }
    
    mutating func updateSyncKey(SyncKey: [Dictionary<String,Any>]) {
        self.SyncKey = SyncKey
    }
}
