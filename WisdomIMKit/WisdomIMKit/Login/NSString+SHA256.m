//
//  NSString+SHA256.m
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import "NSString+SHA256.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#include <Compression.h>

@implementation NSString (SHA256)
- (NSString*) sha256{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

+(NSString*)getSSkey{
    return @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4"\
    "A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF60"\
    "95179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF"\
    "747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B907"\
    "8717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB37861"\
    "60279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DB"\
    "FBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
}

-(NSString*)rangeWithlocation:(int)location {
    NSRange range;
    range.location = location;
    range.length = self.length - 3;
    NSString *SStr = [self substringWithRange:range];
    return SStr;
}

- (NSString*)phoneNumExamine {
    if (self.length == 0) {
        return @"请输入手机号";
    }else if (self.length != 11 ) {
        return @"请验证号码长度";
    }
//    for (int i = 0; i< self.length; i++) {
//       char a = [self characterAtIndex:i];
//       if ((a >='a' && a<='z') || (a >='A' && a<='Z')) {
//           return @"请验证号码格式";
//       }
//    }
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    if (![scan scanInt:&val] || ![scan isAtEnd]) {
        return @"手机号码必须全为数字";
    }
    return nil;
}

+(NSString *)return8LetterAndNumber{
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < 8; i++){
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    return result;
}

-(NSString *)sendShoppsNumVerificationWith:(NSString *)title {
    if (self.length == 0){
        return @"数量数字不能为空";
    }
    
//    char a = [self characterAtIndex:0];
//    if (a == '0') {
//        return @"数量首数字不能为'0'";
//    }
    
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    if (![scan scanInt:&val] || ![scan isAtEnd]) {
        return @"数量填写必须全为数字";
    }
    
    if (self.intValue > title.intValue ) {
        return @"数量不能大于总采购数量";
    }
    return nil;
}

- (NSString *)quotationVerification{
    NSMutableString * title = [[NSMutableString alloc] initWithString:self];
    if ([self containsString:MONEYEMPTY]) {
        NSRange range = [title rangeOfString:MONEYEMPTY];
        [title deleteCharactersInRange:range];
    }
    if (title.length == 0) {
        return @"含税单价不能为空";
    }
    
    for(int i=0; i< [title length];i++){
        int a = [title characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return @"含税单价不能含有中文";
        }
    }
    //NSScanner* scan = [NSScanner scannerWithString:title];
    //int val;
    //if (![scan scanInt:&val] || ![scan isAtEnd]) {
        //return @"含税单价必须全为数字";
    //}
    return  nil;
}
@end
