 //
//  UserinfoVO.swift
//  ZHInvestBusinessiOS
//
//  Created by 汤建锋 on 2017/11/11.
//  Copyright © 2017年 ZHInvest. All rights reserved.
//
import UIKit
import AdSupport
 
enum UserinfoSafetyType {
    case overdue
    case safety
    case imSafetyOverdue
}

let UnQuotedPrice = "未报价"
let YetQuotedPrice = "已报价"
let NoneTitle = "未设置"
let None = "None"
let DeviceID = "DeviceID"
 
struct UserinfoVO {
    static var shard = UserinfoVO()
//    private let ZHInvestSYNCKEY = "ZHInvestSYNCKEY"
//    private let PYQUANPIN = "PYQUANPIN"
//    private let SUPALIAS = "SUPALIAS"
//    private let USERHEADER = "USERHEADER"
//    private let NICKNAME = "NICKNAME"
//    private let ZHInvestEMAIL = "ZHInvestEMAIL"
//    private let IDENTIFICATION = "IDENTIFICATION"
//    private let HYADDRESS = "HYADDRESS"
//    private let CANMESSAGENOTI = "CANMESSAGENOTI"
    
//    private(set) var USERNAME_KEY = USERNAME
//    private(set) var MOBILE_KEY = MOBILE
//    private(set) lazy var USERHEADER_KEY = USERHEADER
//    private(set) lazy var NICKNAME_KEY = NICKNAME
//    private(set) lazy var IDENTIFICATION_KEY = IDENTIFICATION
//    private(set) lazy var ZHInvestEMAIL_KEY = ZHInvestEMAIL
//    private(set) lazy var HYADDRESS_KEY = HYADDRESS
//    var contactsClosure: (()->())?
//    var pullOutClosure: (()->())?
    private(set) var uidStr: String?       //注册,登录            UID
    private(set) var cer_pass: String?     //注册,登录            CERPASSWORD
    private(set) var cer_expired: String?  //注册,登录过期日       CEREXPIRED
    private(set) var isactivate: String?   //注册,登录有返回       ISACTIVATE
    private(set) var userpassword: String? //注册,登录有返回       USERPASSWORD
    private(set) var user_expired: String? //登录过期日           USEREXPIRED
    //security
    private(set) var loginId: String?
    private(set) var m1: String?
    private(set) var randomKey: String?
    private(set) var seqId: UInt32?
    private(set) var sid: String?
    private(set) var skey: String?
    private(set) var uin: String?
    private(set) var userId: String?
    private(set) var userName: String?{
        didSet{
            //UserDefaults.standard.set(userName, forKey: USERNAME_KEY)
        }
    }
    private(set) var mobile: String?{
        didSet{
            //UserDefaults.standard.set(mobile, forKey: MOBILE_KEY)
        }
    }
    var deviceId: String?{
        didSet{
            UserDefaults.standard.set(deviceId, forKey: DeviceID)
            UserDefaults.standard.synchronize()
        }
    }
    //updateRegist
    mutating func updateRegistData()  {
//       let defaults = UserDefaults.standard
//       uidStr = defaults.string(forKey: UID)
//       cer_pass = defaults.string(forKey: CERPASSWORD)
//       cer_expired = defaults.string(forKey: CEREXPIRED)
//       isactivate = defaults.string(forKey: ISACTIVATE)
//       userpassword = defaults.string(forKey: USERPASSWORD)
    }
    //updateLogin
    mutating func updateLoginData()  {
//        let defaults = UserDefaults.standard
//        userId = defaults.string(forKey: USERID)
//        if userId != nil && (userId?.count)! > 0 {
//           USERNAME_KEY = userId! + "_" + USERNAME
//           MOBILE_KEY = userId! + "_" + MOBILE
//        }
//        userName = defaults.string(forKey: USERNAME_KEY)
//        mobile = defaults.string(forKey: MOBILE_KEY)
//        uidStr = defaults.string(forKey: UID)
//        cer_pass = defaults.string(forKey: CERPASSWORD)
//        cer_expired = defaults.string(forKey: CEREXPIRED)
//        isactivate = defaults.string(forKey: ISACTIVATE)
//        userpassword = defaults.string(forKey: USERPASSWORD)
//        user_expired = defaults.string(forKey: USEREXPIRED)
//        loginId = defaults.string(forKey: LOGINID)
//        m1 = defaults.string(forKey: M1)
//        randomKey = defaults.string(forKey: RANDOMKEY)
//        seqId = defaults.object(forKey: SEQID) as? UInt32
//        sid = defaults.string(forKey: SID)
//        skey = defaults.string(forKey: SKEY)
//        uin = defaults.string(forKey: UIN)
        
//        if uin != nil && sid != nil && skey != nil {
//            let deviceId = UserDefaults.standard.string(forKey: DeviceID)
//            let asIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//            //baseRequest = ["DeviceID":(deviceId?.count > 0 ? deviceId!:asIdentifier), "Uin": uin!,"Sid": sid!,"Skey": skey!]
//        }
    }
    //centerUserinfo
//    private(set) lazy var ownSessageList: [Dictionary<String,Any>] = {
//        var ownSessageRray = [Dictionary<String, String>]()
//        ownSessageRray.append(["头像": UserDefaults.standard.string(forKey: USERHEADER_KEY) ?? MasterIocn])
//        ownSessageRray.append(["名字": setOwnShowName()])
//        ownSessageRray.append(["手机号": UserDefaults.standard.string(forKey: MOBILE_KEY) ?? NoneTitle])
//        ownSessageRray.append(["身份证": UserDefaults.standard.string(forKey: IDENTIFICATION_KEY) ?? NoneTitle])
//        ownSessageRray.append(["性别": isMan ? "男":"女"])
//        ownSessageRray.append(["邮箱": UserDefaults.standard.string(forKey: ZHInvestEMAIL_KEY) ?? NoneTitle])
//        ownSessageRray.append(["通信地址": UserDefaults.standard.string(forKey: HYADDRESS_KEY) ?? NoneTitle])
//        return ownSessageRray
//    }()
    //synchronData
    private(set) var isMan: Bool = true         //性别
    private(set) var contactFlag: String?       //用户类别
    private(set) var identification: String?{   //身份证
       didSet{
           let title = (identification == None ? NoneTitle:identification)
           //ownSessageList[3]["身份证"] = title
           //UserDefaults.standard.set(title, forKey: IDENTIFICATION_KEY)
       }
    }
    private(set) var nickName: String?{
        didSet{
            let title = (nickName == None ? NoneTitle:nickName)
            //ownSessageList[1]["名字"] = title
            //UserDefaults.standard.set(title, forKey: NICKNAME_KEY)
        }
    }
    //email
    private(set) var email: String?{
        didSet{
            let title = (email == None ? NoneTitle:email)
            //ownSessageList[5]["邮箱"] = title
            //UserDefaults.standard.set(title, forKey: ZHInvestEMAIL_KEY)
        }
    }
    //PYQuanPin
    private(set) var pyQuanPin: String?{
        didSet{
            //UserDefaults.standard.set(nickName, forKey: PYQUANPIN)
        }
    }
    //address
    private(set) var address: String?{
        didSet{
            let title = (address == None ? NoneTitle:address)
            //ownSessageList[6]["通信地址"] = title
            //UserDefaults.standard.set(title, forKey: HYADDRESS_KEY)
        }
    }
    //UserHeader
//    private(set) var userHeader: String?{
//        didSet{
//            if userHeader != None && userHeader != MasterIocn {
//                let str = loadFile(str: userHeader!)
//                let url = URL(string: str)
//                SDWebImageManager.shared().loadImage(with: url, options: SDWebImageOptions.transformAnimatedImage,progress: nil, completed: {(image, data, error, cacheType, res, urlStr) in
//                    if (image != nil){
//                        print("头像本地已缓存")
//                    }
//                })
//                ownSessageList[0]["头像"] = userHeader
//                UserDefaults.standard.set(userHeader, forKey: USERHEADER_KEY)
//            }else{
//                ownSessageList[0]["头像"] = MasterIocn
//                UserDefaults.standard.set(MasterIocn, forKey: USERHEADER_KEY)
//            }
//        }
//    }
    
//    func loadFile(str: String) -> String {
//        let str = LoadFileBaseURL + str + "?access_token=" + m1!.sha256() + "&uid=" + mobile!
//        return str
//    }
    
//    func loadSupAliasList() -> [ZHInvestSupAliasVO] {
//        let list = ZHInvestFMDBManager.shared.searchSupAliasAll()
//        return list
//    }
    
//    func seletedSupAlias(newCustInfoId: String, oldCustInfoId: String){
//        ZHInvestFMDBManager.shared.updateSupAlias(newCustInfoId: newCustInfoId, oldCustInfoId: oldCustInfoId)
//    }
    
    //MRAK : SYNC
    mutating func synchronousData(dict: Dictionary<String ,Any>) {
        if let user = dict["User"] as? Dictionary<String,Any> {
//            let Username = user["Username"] as? String
//            let Mobile = user["Mobile"] as? String
//            contactFlag = user["ContactFlag"] as? String
//            nickName = (user["NickName"] as? String) ?? NoneTitle
//            email = (user["Email"] as? String) ?? NoneTitle
//            identification = (user["Identification"] as? String) ?? NoneTitle
//            userHeader = user["UserHeader"] as? String ?? MasterIocn
//            address = user["Address"] as? String ?? NoneTitle
//            pyQuanPin = user["PYQuanPin"] as? String
//            if Username?.count > 0 {
//                userName = Username
//            }
//            if Mobile?.count > 0 {
//                mobile = Mobile
//            }
        }
        //supAliasRray
//        if let SupAlias = dict["SupAlias"] as? [[String:Any]]{
//            if SupAlias.count > 0 {
//                print("***********有供应商信息***********")
//                ZHInvestFMDBManager.shared.updateSupAlias(SupAlias: SupAlias)
//             }
//        }
        UserDefaults.standard.synchronize()
        //contactArray
//        if let contactList = dict["ContactList"] as? [Dictionary<String,Any>] {
//            if contactList.count > 0{
//                var dictContacts = Dictionary<String, Dictionary<String,Any>>()
//                for item in contactList {
//                    let userId = item["UserID"] as! String
//                    dictContacts[userId] = item
//                }
//                ZHInvestFMDBManager.shared.deleteContactsAll()
//                for value in dictContacts.values {
//                    ZHInvestFMDBManager.shared.insertsContacts(dict: value)
//                }
//                if contactsClosure != nil{
//                    contactsClosure!()
//                }
//            }
//        }
    }

    //MRAK : out
    mutating func pullOut() {
//        uidStr = nil
//        cer_pass = nil
//        cer_expired = nil
//        isactivate = nil
//        userpassword = nil
//        user_expired = nil
//        loginId = nil
//        m1 = nil
//        randomKey = nil
//        seqId = nil
//        sid = nil
//        skey = nil
//        uin = nil
//        userId = nil
//        deviceId = nil
//        let defaults = UserDefaults.standard
//        defaults.removeObject(forKey: UID)
//        defaults.removeObject(forKey: CERPASSWORD)
//        defaults.removeObject(forKey: CEREXPIRED)
//        defaults.removeObject(forKey: ISACTIVATE)
//        defaults.removeObject(forKey: USERPASSWORD)
//        defaults.removeObject(forKey: USEREXPIRED)
//        defaults.removeObject(forKey: LOGINID)
//        defaults.removeObject(forKey: M1)
//        defaults.removeObject(forKey: RANDOMKEY)
//        defaults.removeObject(forKey: SEQID)
//        defaults.removeObject(forKey: SID)
//        defaults.removeObject(forKey: SKEY)
//        defaults.removeObject(forKey: UIN)
//        defaults.removeObject(forKey: USERID)
//        defaults.removeObject(forKey: DeviceID)
//        UserDefaults.standard.synchronize()
//        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: ZHInvestLoginInVC())
//        UIApplication.shared.applicationIconBadgeNumber = 0
//        if pullOutClosure != nil{
//            pullOutClosure!()
//        }
    }
    
    var hasAccount: UserinfoSafetyType{
        mutating get{
            updateLoginData()
            if userName != nil && uidStr != nil && cer_pass != nil && cer_expired != nil &&
               isactivate != nil && userpassword != nil && user_expired != nil &&
               loginId != nil && m1 != nil && mobile != nil && randomKey != nil &&
               seqId != nil && sid != nil && skey != nil && uin != nil && userId != nil {
                return timeLimitWith(futureTime :cer_expired)
            }
            return .overdue
        }
    }
    
    //MRAK : 期效
    private func timeLimitWith(futureTime : String!) -> UserinfoSafetyType{
        var expiredDate = stringTakeDate(futureTime : user_expired, index: true)
        let newDate = Date()
        expiredDate = expiredDate?.addingTimeInterval(TimeInterval.init(60 * 60 * 8 - 300))
        if newDate.compare(expiredDate!) == ComparisonResult.orderedDescending{
            return .imSafetyOverdue
        }
        expiredDate = stringTakeDate(futureTime : futureTime, index: false)
        if expiredDate?.compare(newDate) == ComparisonResult.orderedDescending{
            return .safety
        }
        return .overdue
    }
    
    private func stringTakeDate(futureTime : String!,index : Bool)->Date?{
        let dateformatter = DateFormatter()
        if index {
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: futureTime)
            return date
        }else{
            let str = futureTime.replacingOccurrences(of: " ", with: "")
            dateformatter.dateFormat = "yyyy-MM-dd"
            let date = dateformatter.date(from: str)
            return date
        }
    }
    
//    mutating func setUserInfo(type: UserInfoType,title : String) {
//        switch type {
//        case .nameType:
//            nickName = title
//        case .emailType:
//            email = title
//        case .identificationType:
//            identification = title
//        case .iocnType:
//            userHeader = title
//        case .addressType:
//            address = title
//        default: break
//        }
//    }
    
    //昵称，username，手机号
//    mutating func setOwnShowName() -> String {
//        var name: String = ""
//        let str = UserDefaults.standard.string(forKey: NICKNAME_KEY)
//        if str?.count > 0 && str != NoneTitle{
//            name = str!
//        }else if userName?.count > 0{
//            name = userName!
//        }else if mobile?.count > 0{
//            name = UserinfoVO.shard.mobile!
//        }else{
//            name = None
//        }
//        return name
//    }
    
//    private mutating func setOwnSessageList(){
//        if userId?.count > 0 {
//            setUserInfoKey(userId: userId!)
//            var ownSessageRray = [Dictionary<String, String>]()
//            ownSessageRray.append(["头像": UserDefaults.standard.string(forKey: USERHEADER_KEY) ?? MasterIocn])
//            ownSessageRray.append(["名字": setOwnShowName()])
//            ownSessageRray.append(["手机号": UserDefaults.standard.string(forKey: MOBILE_KEY) ?? NoneTitle])
//            ownSessageRray.append(["身份证": UserDefaults.standard.string(forKey: IDENTIFICATION_KEY) ?? NoneTitle])
//            ownSessageRray.append(["性别": isMan ? "男":"女"])
//            ownSessageRray.append(["邮箱": UserDefaults.standard.string(forKey: ZHInvestEMAIL_KEY) ?? NoneTitle])
//            ownSessageRray.append(["通信地址": UserDefaults.standard.string(forKey: HYADDRESS_KEY) ?? NoneTitle])
//            ownSessageList = ownSessageRray
//        }
//    }
    
//    private mutating func setUserInfoKey(userId: String){
//        USERNAME_KEY = userId + "_" + USERNAME
//        USERHEADER_KEY = userId + "_" + USERHEADER
//        NICKNAME_KEY = userId + "_" + NICKNAME
//        MOBILE_KEY = userId + "_" + MOBILE
//        IDENTIFICATION_KEY = userId + "_" + IDENTIFICATION
//        ZHInvestEMAIL_KEY = userId + "_" + ZHInvestEMAIL
//        HYADDRESS_KEY = userId + "_" + HYADDRESS
//    }
}
