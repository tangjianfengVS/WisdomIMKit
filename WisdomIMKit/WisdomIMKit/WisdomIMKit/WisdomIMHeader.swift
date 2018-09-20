//
//  WisdomIMHeader.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

class WisdomIMHeader: NSObject {
 
    private var numcmp: UInt8 = 01;  //压缩编号  1不加密   2加密
    private var encrypt: UInt8 = 01; //加密编号  1 压缩    2不压缩
    private var mode: UInt8 = 01;    //模式. ——————环境模式
    private var service: UInt8 = 1;  //服务类型
    
    init(mode: UInt8, service: UInt8) {
        self.mode = mode
        self.service = service
    }
    
    func toDic() -> [String:UInt8] {
        var dict: [String:UInt8] = [:];
        dict["numcmp"] = numcmp
        dict["encrypt"] = encrypt
        dict["mode"] = mode
        dict["service"] = service
        return dict
    }
    
    func update(service: UInt8) {
        self.service = service
    }
}
