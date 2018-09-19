//
//  SRPUtils.m
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import "SRPUtils.h"
#import "NSString+SHA256.h"

@implementation SRPUtils
+(BigInteger *)hash:(NSString *)str
{
    return [[BigInteger alloc]initWithString:[self hashToBytes:str] radix:16];
}

+(NSString *)hashToBytes:(NSString *)s{
    NSString *str;
    str=[s sha256];
    return str;
}




+(BigInteger *)hashWithBigInteger:(BigInteger *)i
{
    NSString *Str=[self hashToBytesWithBigInteger:i];
    BigInteger *l=[[BigInteger alloc]initWithString:Str radix:16];
    return l;

}

+(NSString *)hashToBytesWithBigInteger:(BigInteger *)i
{
  return [[i toRadix:16] sha256];
    
}


+(BigInteger *)random:(SRPContants *)fContants
{
    
    BigInteger *p=[[BigInteger alloc]initWithString:@"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4"\
                   "A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF60"\
                   "95179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF"\
                   "747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B907"\
                   "8717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB37861"\
                   "60279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DB"\
                   "FBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73"
                                              radix:16];
    int numberOfBytes=([p bitCount]+([p bitCount]-1))/8;
    
   
    //在这个范围里面获得一个更安全的随机数
    
    BigInteger *i=[[BigInteger alloc]initWithRandomNumberOfSize:numberOfBytes exact:NO];
    
    BigInteger *two=[[BigInteger alloc]initWithString:@"2" radix:10];

    BigInteger *max=[p sub:two];
    
   //取模运算
    BigInteger *lop=[[BigInteger alloc]initWithString:@"1" radix:16];
    BigInteger *Result=[i exp:lop modulo:max];

    return [Result add:two];
  
}

+(BigInteger *)mackPrivateKey:(NSString *)username password:(NSString *)password salt:(NSString *)salt
{
    
    NSString *str=[NSString stringWithFormat:@"%@:%@:%@",username,password,salt];
    BigInteger *l=[[BigInteger alloc]initWithString:str radix:16];
    return l;
}

+(BigInteger *)calc_i:(BigInteger *)A and:(BigInteger *)B
{
    NSString *Str=[NSString stringWithFormat:@"%@:%@",[A toRadix:10],[B toRadix:10]];
    return [self hash:Str];
}

+(BigInteger *)calcM1WithSRPContants:(SRPContants *)fContants StrWithfUsername:(NSString *)fUsername BigIntegerA:(BigInteger *)fPublickKey_A BigIntegerB:(BigInteger *)fPublickKey_B fCommonValueK:(BigInteger *)fCommonValue_K andfsalt:(BigInteger *)fsalt
{

    NSString *HNG=[[[self hash:[fContants.N toRadix:16]] bitwiseXor:[self hashWithBigInteger:fContants.g]] toRadix:10];
    NSString *HU=[self hashToBytes:fUsername];
    NSString *HS=[fsalt toRadix:10];
    NSString *HA=[fPublickKey_A toRadix:10];
    NSString *HB=[fPublickKey_B toRadix:10];
    NSString *HK=[fCommonValue_K toRadix:10];
    
    NSString *Str=[NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",HNG,HU,HS,HA,HB,HK];
    
    return [self hash:Str];
}

@end
