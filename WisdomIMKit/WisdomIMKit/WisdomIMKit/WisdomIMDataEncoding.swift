//
//  WisdomIMDataEncoding.swift
//  WisdomIMDataEncoding
//
//  Created by 汤建锋 on 2017/12/19.
//  Copyright © 2017年 ZHInvest. All rights reserved.
//

import UIKit

struct WisdomIMDataEncoding {
    /** 加 */
    mutating func AESAndGZip(payload: Data) -> (Data,UInt8,UInt8,UInt16){
        let uInt8s = aes(payload: payload)
        if uInt8s != nil{
           let data = GZip(uInt8s: uInt8s!)
           return (data,03,02,03)
        }else{
           return (payload,01,01,01)
        }
    }
    
    /** 解 */
    mutating func unGZipAndUnAES(payload: [UInt8], optrOption : UInt16,need : Bool) -> Data{
        let bit1 = optrOption & 1
        let bit2 = optrOption & 2
        if bit2 == 2 {
            var unPayload = unGZip(payload: payload)//解压缩
            if bit1 == 1{
                unPayload = unAes(payload: unPayload)//解密
            }
            return Data(bytes: unPayload)
        }else if need{
            var unPayload = unGZip(payload: payload)//解压缩
            unPayload = unAes(payload: unPayload)//解密
            return Data(bytes: unPayload)
        }else{
            var unPayload = payload
            if bit1 == 1{
                unPayload = unAes(payload: unPayload)//解密
            }
            return Data(bytes: unPayload)
        }
    }
    
    /** AES-ECB128加密 */
    private mutating func aes(payload : Data) -> [UInt8]? {
        let strPayload = String.init(data: payload, encoding: String.Encoding.utf8)
        do {
            let key = WisdomIMKitManager.shared.randomKey
            //.pkcs5
            let aes = try AES(key: key.bytes, blockMode: .ECB)
            let encrypted = try aes.encrypt((strPayload?.bytes)!)
            //print("加密结果(base64)：\(encrypted.toBase64()!)")
            return encrypted
        } catch {
        }
        return nil
    }
   
    private mutating func unAes(payload : [UInt8]) -> [UInt8] {
        do{
            let key = WisdomIMKitManager.shared.randomKey
            let aes = try AES(key: key.bytes, blockMode: .ECB)
            let decrypted = try aes.decrypt(payload)
            //print("解密结果：\(String(data: Data(decrypted), encoding: .utf8)!)")
            return decrypted
        }catch{
        }
        return payload
    }
    
    private func GZip(uInt8s : [UInt8]) -> Data {
        let data = Data.init(bytes: uInt8s)
        let compressedData = try! data.gzipped()
        //print("压缩前的大小：\(data.count)字节")
        //print("压缩后的大小：\(compressedData.count)字节")
        return compressedData
    }
    
    private mutating func unGZip(payload:[UInt8]) -> [UInt8]{
        let compressedData = Data.init(bytes: payload)
        if compressedData.isGzipped {
            let originalData = try! compressedData.gunzipped()
            return [UInt8](originalData)
        }
        return payload
    }
}

