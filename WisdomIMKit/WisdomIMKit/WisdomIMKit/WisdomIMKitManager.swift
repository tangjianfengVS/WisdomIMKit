//
//  WisdomIMKitManager.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

public class WisdomIMKitManager: NSObject {
    
    fileprivate(set) var toHost: String=""
    
    fileprivate(set) var onPort: Int=0
    
    fileprivate(set) var timeOut: TimeInterval=15
    
    fileprivate(set) var randomKey: String=""
    
    fileprivate(set) var seqId: UInt32?
    
    public static let shared = WisdomIMKitManager()
    
    public var delegate: WisdomIMKitManagerDelegate?
    
    fileprivate(set) var taskEvent: WisdomSessionTaskEvent = .commonEvent
    
    fileprivate let reachability = WisdomReachability()
    
    fileprivate var clientSocket: GCDAsyncSocket!
    
    fileprivate var header: WisdomIMHeader?
    
    fileprivate var payload: WisdomIMPayload?
    
    fileprivate lazy var payloadVO = WisdomIMDataVO()
    
    fileprivate var heartBeatSucceed: Bool=false
    
    fileprivate var pullOut: Bool=true
    
    /** 重新连接次数 */
    fileprivate var reconnectionCount = kMaxReconnection_time
    
    /** 心跳定时 */
    fileprivate var beatTimer: Timer!
    
    /** 心跳间隔时间 */
    fileprivate var currentHeartBeat = heartBeatTimeMin
    
    /** 连接成功回调 */
    fileprivate var successTask: (()->())?
    
    /** 连接失败回调 */
    fileprivate var falesTask: ((Error?)->())?
    
    /** Invoke消息回调 */
    fileprivate var invokeHandleTask: (([String:Any])->())?
    
    /** Send消息回调 */
    fileprivate var sendChatHandleTask: (([String:Bool])->())?

    /** 网络状态变更通知 */
    @objc fileprivate(set) var sessionType: WisdomSessionType = .sessionNone {
        didSet{
            if oldValue != sessionType {
                NotificationCenter.default.post(name: NSNotification.Name.init(WisdomSessionChangeNotificationKey), object: sessionType, userInfo: nil)
            }
        }
    }
    
    /** IM状态变更通知，处理重连机制 */
    @objc fileprivate(set) var iMConnectType: WisdomIMConnectType = .UnConnect {
        didSet{
            if iMConnectType == .FalesConnect {
                currentHeartBeat = heartBeatTimeMin
                
                if payload != nil && payload!.SyncKey != nil{
                    payload!.updateSyncKey(SyncKey: [])
                }
                
                if sessionType != .sessionNone && reconnectionCount > 0 {
                    reconnectionCount = reconnectionCount - 1
                    creatSocketToConnectServer()
                }
            }
            
            if oldValue != iMConnectType {
                NotificationCenter.default.post(name: NSNotification.Name.init(WisdomIMConnectChangeNotificationKey), object: iMConnectType, userInfo: nil)
            }
        }
    }
    
    override private init() {
        super.init()
        clientSocket = GCDAsyncSocket()
        clientSocket.delegate = self
        clientSocket.delegateQueue = DispatchQueue.main

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        
        do{
            try reachability!.startNotifier()
        }catch{
            print("error")
        }
    }
    
    /**
     *  【建立连接接口】
     *   toHost:               服务Host
     *   onPort:               服务端口号
     *   timeOut:              设置连接超时时间
     *   successConnect:       连接成功回调
     *   falesTask:            连接失败回调
     */
    @objc func connect(toHost: String,
                       onPort: Int,
                      timeOut: TimeInterval,
               successConnect: @escaping (()->()),
                 falesConnect: @escaping ((Error?)->())) {
        pullOut = false
        self.toHost = toHost
        self.onPort = onPort
        self.timeOut = timeOut
        
        successTask = successConnect
        falesTask = falesConnect
        creatSocketToConnectServer()
    }
    
    /**
     *  【用户信息验证登录接口】
     *   userinfo:             WisdomUserinfo模型, 传递登录必须的属性值
     *   mode:                 当前调用环境设置(区分开发和测试环境)，和后台协调设置
     *   service:              当前调用服务类型，和后台协调设置
     *   randomKey:            处理payload数据加密key，和后台协调设置
     *   seqId:                处理headers数据加密key，和后台协调设置
     */
    @objc func synchronUserInfo(userinfo: WisdomUserinfo,
                                    mode: Int,
                                 service: Int,
                               randomKey: String,
                                   seqId: UInt32) {
        self.randomKey = randomKey
        self.seqId = seqId
        
        header = WisdomIMHeader(mode: UInt8(mode), service: UInt8(service))
        payload = WisdomIMPayload(userinfo: userinfo)
        
        var VO = WisdomIMDataVO.init(payload: payload!, header: header!)
        VO.optrType = 1
        let data = VO.toByteBuf()
        clientSocket.write(data, withTimeout: -1, tag: WisdomIMConnectType.SynchronUserInfo.hashValue)
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: WisdomIMConnectType.SynchronUserInfo.hashValue)
    }
    
    /**
     *  用于应用从后台回调到前台手动Push，或者其他手动Push调用
     */
    @objc func push() -> Bool{
        if payload == nil || payload!.SyncKey == nil || payload!.SyncKey!.count == 0{
            return false
        }
        
        header!.update(service: UInt8(1))
        var vo = WisdomIMDataVO.init(payload: payload!, header: header!)
        vo.optrType = 0x7F01
        let data = vo.toByteBuf()
        clientSocket.write(data, withTimeout: -1, tag: 1)
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 1)
        return true
    }
    
    /**
     *   Invoke: IM自定义主动指令，主动调用，等待事件
     *
     *
     *
     */
    @objc func invokeToServer(payloadDic: Dictionary<String, Any>?,
                              headersDic: Dictionary<String, UInt8>?,
                                 closure: @escaping (([String:Any])->())) {
        let res = getRequestError()
        if res.0 {
            taskEvent = .invokeEvent
//            var vo = ZHInvestIMVO.init(payloadDic: payloadDic, headersDic: headersDic)
//            vo.optrType = UInt16(0x15)//21不能改
//            let data = vo.toByteBuf()
//            clientSocket.write(data, withTimeout: -1, tag: tag)
//            clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: tag)
            invokeHandleTask = closure
        }else{
            closure([:])
        }
    }
    
    /**
     *   send: IM自定义主动指令，主动调用，非等待事件
     *   应用: 聊天信息
     *
     *
     */
    @objc func sendChatToServer(payloadDic: [String:Any],
                                  needShow: Bool,
                                   closure: @escaping (([String:Bool])->())) {
        let res = getRequestError()
        if res.0 {
            taskEvent = .sendChatEvent
            header!.update(service: UInt8(1))
//            var vo = ZHInvestIMVO.init(payloadDic: payloadDic, headersDic: self.header)
            //vo.optrType = UInt16(0x0111)//273不能改
            //let data = vo.toByteBuf()
//            if needShow{
//                SVProgressHUD.show()
//            }
//            clientSocket.write(data, withTimeout: -1, tag: tag)
//            clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: tag)
            
            //self.header["service"] = UInt8(1)
            //init(payload: payload!, header: header!)
            var vo = WisdomIMDataVO.init(payload: payloadDic, header: header!)//init(payloadDic: payloadDic, headersDic: self.header)
            vo.optrType = UInt16(0x0111)//273不能改
            let data = vo.toByteBuf()

            clientSocket.write(data, withTimeout: -1, tag: taskEvent.hashValue)
            clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: taskEvent.hashValue)
            sendChatHandleTask = closure
        }else{
            closure(["SendMsg": false])
        }
    }
    
    /**
     *   退出IM连接接口
     */
    @objc func disconnect(){
        pullOut = true
        successTask = nil
        falesTask = nil
        invokeHandleTask = nil
        sendChatHandleTask = nil
        taskEvent = .commonEvent
        
        timerInvalidate(timer: beatTimer)
        clientSocket.disconnect()
    }
    
    deinit {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
}

extension WisdomIMKitManager {
    /** 心跳包设置 */
    fileprivate func socketConnectBeginSendBeat() -> Void {
        beatTimer = Timer.scheduledTimer(timeInterval: TimeInterval(currentHeartBeat),
                                         target: self,
                                         selector: #selector(sendBeat),
                                         userInfo: nil,
                                         repeats: true)
        RunLoop.current.add(beatTimer, forMode: RunLoopMode.commonModes)
    }
    
    @objc fileprivate func sendBeat() {
        if heartBeatSucceed && currentHeartBeat + heartBeatTimeMin <= heartBeatTimeMax{
            beatTimer.invalidate()
            currentHeartBeat = currentHeartBeat + heartBeatTimeMin
            socketConnectBeginSendBeat()
        }else if !heartBeatSucceed && currentHeartBeat - heartBeatTimeMin >= heartBeatTimeMin{
            beatTimer.invalidate()
            currentHeartBeat = currentHeartBeat - heartBeatTimeMin
            socketConnectBeginSendBeat()
        }
        print("当前心跳间隔: " + String(currentHeartBeat) + " s")
        let data = WisdomIMDataVO().toByteBuf()
        heartBeatSucceed = false
        clientSocket.write(data, withTimeout: -1, tag: 0)
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1,tag: 0)
    }
    
    fileprivate func timerInvalidate(timer: Timer!) -> Void {
        guard let inTimer = timer else {
            return
        }
        inTimer.invalidate()
    }
    
    /** error处理 */
    fileprivate func error(dic: Dictionary<String,Any>) -> Bool {
        if let baseResponse = dic["BaseResponse"] as? Dictionary<String,Any>{
            let ret = baseResponse["Ret"] as? NSNumber
            let errMsg = baseResponse["ErrMsg"] as? String
            if (errMsg != nil && errMsg!.count > 0) || ret?.intValue != 0 {
                
                if errMsg!.contains(NotAuthorized) {
                    delegate?.synchronUserInfo(info: ["Error":NotAuthorized],result: false)
                }else if ret?.intValue == -1{
                    print("后台服务未开启。。。。")
                }
                return true
            }
        }
        return false
    }
    
    /** SyncKey过滤 */
    fileprivate func synchronousPush(syncKey:[Dictionary<String,Any>]) {
        for item in syncKey {
            if let Val = item["Val"] as? String{
                if Val != "0"{
                    let _ = push()
                    return
                }
            }
        }
    }
    
    @objc fileprivate func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! WisdomReachability
        switch reachability.connection {
        case .cellular:
            sessionType = .sessionCellular
        case .wifi:
            sessionType = .sessionWifi
        case .none:
            sessionType = .sessionNone
        }
    }
    
    fileprivate func creatSocketToConnectServer() -> Void {
        do {
            iMConnectType = .ConnectRequest
            try clientSocket.connect(toHost: toHost, onPort: UInt16(onPort), withTimeout: TimeInterval(timeOut))
        }catch{
            iMConnectType = .UnConnect
        }
    }
    
    /** IM当前连接状态获取 */
    fileprivate func getRequestError() -> (Bool,String){
        if sessionType == .sessionNone {
            print("请检查网络")
            return (false,"请检查网络")
        }
        switch iMConnectType {
        case .UnConnect:
            print("未连接")
            return (false,"未连接")
        case .ConnectRequest:
            print("正在连接")
            return (false,"正在连接")
        case .SuccessConnect:
            print("连接成功")
            return (false,"连接成功")
        case .FalesConnect:
            print("连接失败")
            return (false,"连接失败")
        case .SynchronUserInfo:
            print("正在同步")
            return (false,"正在同步")
        case .SuccessSynchronUserInfo:
            print("同步成功")
            return (true,"同步成功")
        }
    }
}

extension WisdomIMKitManager: GCDAsyncSocketDelegate{
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        iMConnectType = .SuccessConnect
        socketConnectBeginSendBeat()
        
        if successTask != nil {
            successTask!()
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let resList = payloadVO.rawPacket(buf: data)
        if !resList.1 {
            return
        }
        //Sync129
        if payloadVO.optrType == UInt32(0x81) {
            clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1,tag: 0)
            let _ = push()
        //heartBeat
        }else if resList.0.count == 0 && data.count == 18{
            heartBeatSucceed = true
        }else{
            clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1,tag: 0)
            DispatchQueue.global().async {
                self.jsonPayloadData(payload : resList.0, tag: tag)
            }
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if pullOut {
            iMConnectType = .UnConnect
        }else{
            iMConnectType = .FalesConnect
        }
        
        if falesTask != nil {
            falesTask!(err)
        }
    }
}

extension WisdomIMKitManager{
    /** jsonPayload */
    fileprivate func jsonPayloadData(payload : Data,tag : Int){
        do{
            let strPayload = String.init(data: payload, encoding: String.Encoding.utf8)
            let jsonData:Data = strPayload!.data(using: .utf8)!
            let jsonRes = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            if let dic = jsonRes as? [String:Any] {
                if error(dic: dic){
                    if (taskEvent == .invokeEvent) {
                        if invokeHandleTask != nil{
                            invokeHandleTask!([:])
                        }
                    }else if (taskEvent == .sendEvent) {
                        if sendHandleTask != nil{
                            sendHandleTask!(["SendMsg": false])
                        }
                    }
                    return
                }
                
                //SynchronUserInfo
                if tag == WisdomIMConnectType.SynchronUserInfo.hashValue{
                    if let SyncKey = dic["SyncKey"] as? [Dictionary<String,Any>] {
                        print(SyncKey)
                        self.payload!.updateSyncKey(SyncKey: SyncKey)
                        reconnectionCount = kMaxReconnection_time
                        iMConnectType = .SuccessSynchronUserInfo
                        
                        var resultDic: [String:Any] = dic
                        resultDic.removeValue(forKey: "SyncKey")
                        delegate?.synchronUserInfo(info: resultDic,result: true)
                        synchronousPush(syncKey: SyncKey)
                    }
                //pull(消息列表数据)
                }else if let SyncKey = dic["SyncKey"] as? [Dictionary<String,Any>] {
                    if self.payload!.SyncKey == nil || self.payload!.SyncKey!.count == 0 {
                        print(SyncKey)
                        self.payload!.updateSyncKey(SyncKey: SyncKey)
                        reconnectionCount = kMaxReconnection_time
                        iMConnectType = .SuccessSynchronUserInfo
                        
                        var resultDic: [String:Any] = dic
                        resultDic.removeValue(forKey: "SyncKey")
                        delegate?.synchronUserInfo(info: resultDic,result: true)
                        synchronousPush(syncKey: SyncKey)
                    }
                    
                    let msg = dic["Msg"] as? [Any]
                    self.delegate?.didReadDataInfo(data:(msg != nil) ? msg!:[])
                //Invoke
                }else if taskEvent == .invokeEvent{
                    taskEvent = .commonEvent
                    if let invokeList = dic["InvokeList"] as? [String:Any] {
                        if invokeHandleTask != nil{
                            invokeHandleTask!(invokeList)
                        }
                    }else if let invokeList = dic["InvokeList"] as? [Any] {
                        let dict = ["InvokeList" : invokeList]
                        if invokeHandleTask != nil{
                            invokeHandleTask!(dict)
                        }
                    }
                //SendMsg
                }else if let _ = dic["LocalID"] {
                    taskEvent = .commonEvent
                    if let _ = (dic["BaseResponse"] as! Dictionary<String,Any>)["Ret"] {
                        if sendHandleTask != nil {
                            sendHandleTask!(["SendMsg":true])
                        }
                    }else{
                        if sendHandleTask != nil {
                            sendHandleTask!(["SendMsg":false])
                        }
                    }
                }
            }
        }catch{
            
        }
    }
}
