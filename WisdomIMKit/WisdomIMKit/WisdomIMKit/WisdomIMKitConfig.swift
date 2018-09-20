//
//  WisdomIMKitConfig.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

let heartBeatTimeMin = 10
let heartBeatTimeMax = 180
let kMaxReconnection_time = 6
let beatLimit = 5

//设备信号变化通知
let WisdomSessionChangeNotificationKey = "WisdomSessionChangeNotificationKey"
//IM连接状态变化通知
let WisdomIMConnectChangeNotificationKey = "WisdomIMConnectChangeNotificationKey"

//IM连接状态判断
enum WisdomIMConnectType: Int {
    case UnConnect = 0                    // 未连接
    case ConnectRequest = 1               // 连接请求中
    case SuccessConnect = 2               // 连接成功
    case FalesConnect = 3                 // 连接失败
    case SynchronUserInfo = 4             // 服务器同步数据中
    case SuccessSynchronUserInfo = 5      // 服务器同步数据成功
}

//网络信号状态判断
enum WisdomSessionType {
    case sessionNone      //无网络
    case sessionCellular  //移动网络
    case sessionWifi      //Wifi
}

//当前网络任务操作事件
enum WisdomSessionTaskEvent {
    case commonEvent     //无事件
    case invokeEvent     //invoke自定义主动事件
    case sendEvent       //send自定义主动事件
}

public protocol WisdomIMKitManagerDelegate  {
    //im用户数据同步协议
    func sessionSynchronUserInfo(info: [String:Any])
    
    //im聊天列表消息协议
    func didReadDataInfo(data: [Any])
}

