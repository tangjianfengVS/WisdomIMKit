//
//  WisdomIMDataVO.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/9/19.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

struct WisdomIMDataVO {
    
    private lazy var encoding = WisdomIMDataEncoding()
    
    private let PACKETLENGTH_LENGTH : UInt32 = 4
    private let OPTRTYPE_LENGTH : UInt32 = 2
    private let OPTROPTION_LENGTH : UInt32 = 2
    private let VERSION_LENGTH : UInt32 = 2
    private let SEQID_LENGTH : UInt32 = 4
    private let HEADERLENGTH_LENGTH : UInt32 = 2
    private let OTHER_LENGTH : UInt32 = 2//\r\n
    private var packetLength : UInt32?
    //固定内容
    var optrType : UInt16 = 7//非定时任务0x15指令号
    private var version : UInt16 = 1
    private(set) var seqId : UInt32 = 1
    //可变内容,由c/s约定
    private var optrOption : UInt16 = 0 //约定位数及值
    private var headers : [UInt8] = []
    private var payload : [UInt8] = []
    //拼接payload
    private var payloadKing : [UInt8] = []
    private var beginKing : Int=0
    private var endKing : Int=0
    private var countRray : [Int]=[]
    
    init() {
        
    }
    
    init(payload: WisdomIMPayload, header: WisdomIMHeader) {
        var headersData = header.toDic()
        let payloadDic = payload.toDic()
        do {
            if payloadDic.count > 0{
                let data = try JSONSerialization.data(withJSONObject: payloadDic, options: .prettyPrinted)
                let list = encoding.AESAndGZip(payload: data)
                headersData["encrypt"] = UInt8(list.1)
                headersData["numcmp"] = UInt8(list.2)
                let bytes = [UInt8](list.0)
                optrOption = list.3
                self.payload = bytes
            }
            if headersData.count > 0 {
                var uint8 = int32toByteArray(value: WisdomIMKitManager.shared.seqId!)
                headers = headers + uint8
                var tmp = headersData["encrypt"]//加密编号
                var uint16 = UInt16(tmp!)
                uint8 = int16toByteArray(value: uint16)
                headers = headers + uint8
                tmp = headersData["numcmp"]    //压缩编号
                uint16 = UInt16(tmp!)
                uint8 = int16toByteArray(value: uint16)
                headers = headers + uint8
                tmp = headersData["mode"]      //模式
                headers.append(tmp!)
                tmp = headersData["service"]   //服务类型
                headers.append(tmp!)
            }
        } catch {
            print("失败")
        }
    }
    
    
    func toByteBuf() -> Data {
        var packetTotalLength = PACKETLENGTH_LENGTH + OPTRTYPE_LENGTH + OPTROPTION_LENGTH + VERSION_LENGTH + SEQID_LENGTH + OTHER_LENGTH + HEADERLENGTH_LENGTH  //\r\n
        if (headers.count > 0) {
            packetTotalLength = packetTotalLength + UInt32(headers.count)
        }
        if (payload.count > 0) {
            packetTotalLength = packetTotalLength + UInt32(payload.count)
        }
        let data = NSMutableData()
        var tmp = int32toByteArray(value: packetTotalLength)
        data.append(&tmp, length: Int(PACKETLENGTH_LENGTH))//4
        tmp = int16toByteArray(value: optrType)
        data.append(tmp, length: Int(OPTRTYPE_LENGTH))//2
        tmp = int16toByteArray(value: optrOption)
        data.append(tmp, length: Int(OPTROPTION_LENGTH))//2
        tmp = int16toByteArray(value: version)
        data.append(tmp, length: Int(VERSION_LENGTH))//2
        tmp = int32toByteArray(value: seqId)
        data.append(tmp, length: Int(SEQID_LENGTH))//4
        
        if (headers.count > 0) {
            tmp = int16toByteArray(value: UInt16(2 + self.headers.count))
            data.append(tmp, length: 2)
            data.append(self.headers, length: self.headers.count)
        } else {
            let h = int16toByteArray(value: 2)
            data.append(h, length: 2)
        }
        if (payload.count > 0) {
            data.append(Data(bytes: payload))
        }
        tmp = [0x0d]
        data.append(tmp, length:1)
        tmp = [0x0a]
        data.append(tmp, length:1)
        return data as Data
    }
    
    private mutating func setPayloadKing(begin : Int, end : Int,buf: Data) -> Bool {
        if endKing == 0 || beginKing == 0{
            beginKing = begin
            endKing = end
            countRray.append(buf.count)
            for i in Int(beginKing)..<buf.count {
                payloadKing.append(buf[i])
            }
            return false
        }else{
            countRray.append(buf.count)
            var res = 0
            for item in countRray{
                res += item
            }
            if (endKing + 2) == res{
                for i in 0..<(buf.count - 1) {
                    payloadKing.append(buf[i])
                }
                beginKing = 0
                endKing = 0
                countRray.removeAll()
                return true
            }else{
                for i in 0..<buf.count {
                    payloadKing.append(buf[i])
                }
            }
            return false
        }
    }
    
    //MRAK : Data解析
    mutating func rawPacket(buf: Data) -> (Data,Bool) {
        var packageBytes : [UInt8] = []
        var optrType : [UInt8] = []
        var optrOption : [UInt8] = []
        var version : [UInt8] = []
        var seqId : [UInt8] = []
        var headers : [UInt8] = []
        var payload : [UInt8] = []
        var tmp : [UInt8] = []
        
        for i in 0..<4 {
            packageBytes.append(buf[i])
        }
        for i in 4..<(4+2) {
            optrType.append(buf[i])
        }
        for i in 6..<(6+2) {
            optrOption.append(buf[i])
        }
        for i in 8..<(8+2) {
            version.append(buf[i])
        }
        for i in 10..<(10+4) {
            seqId.append(buf[i])
        }
        for i in 14..<(14+2) {
            tmp.append(buf[i])
        }
        
        let headerLength = byteaRraytoInt16(uint8s: tmp)
        if (headerLength > HEADERLENGTH_LENGTH) {
            let int32 = Int(headerLength - UInt16(HEADERLENGTH_LENGTH))
            for i in 16..<(16 + int32) {
                headers.append(buf[i])
            }
        }
        
        var value : UInt32 = 0
        var data = NSData(bytes: tmp, length: tmp.count)
        data = NSData(bytes: packageBytes, length: packageBytes.count)
        data.getBytes(&value, length: packageBytes.count)
        packetLength = UInt32(bigEndian: value)
        
        let uint32 : UInt32 = PACKETLENGTH_LENGTH + OPTRTYPE_LENGTH + OPTROPTION_LENGTH + VERSION_LENGTH + SEQID_LENGTH + OTHER_LENGTH
        let payloadLength = packetLength! - UInt32(headerLength) - uint32
        var need : Bool = false
        
        if (payloadLength > 0) {
            let begin = Int(headerLength) + 4 + 2 + 2 + 2 + 4
            let end = packetLength! - 2
            //分发
            if end >= buf.count {
                let res = setPayloadKing(begin: begin, end: Int(end), buf: buf)
                if res{
                    payload = payloadKing
                    payloadKing.removeAll()
                    need = true
                }else{
                    return (Data(),false)
                }
            }else{
                for i in Int(begin)..<Int(end) {
                    payload.append(buf[i])
                }
            }
        }
        
        self.optrType = byteaRraytoInt16(uint8s: optrType)
        self.optrOption = byteaRraytoInt16(uint8s: optrOption)
        self.version = byteaRraytoInt16(uint8s: version)
        value = 0
        data = NSData(bytes: seqId, length: seqId.count)
        data.getBytes(&value, length: seqId.count)
        self.seqId = UInt32(bigEndian: value)
        self.headers = headers
        self.payload = payload
        let finalData = encoding.unGZipAndUnAES(payload: self.payload,optrOption: self.optrOption,need : need)
        return (finalData,true)
    }
    
    private func byteaRraytoInt16(uint8s : [UInt8]) -> UInt16 {
        return UInt16(((uint8s[0] & 0xff) << 8) | (uint8s[1] & 0xff))
    }
    
    private func int16toByteArray(value : UInt16) -> Array<UInt8> {
        return [(UInt8)((value >> 8) & 0xFF), (UInt8)(value & 0xFF)]
    }

    private func int32toByteArray(value : UInt32) -> Array<UInt8> {
        return [(UInt8)((value >> 24) & 0xFF),
                (UInt8)((value >> 16) & 0xFF),
                (UInt8)((value >> 8) & 0xFF),
                (UInt8)(value & 0xFF)]
    }
}
