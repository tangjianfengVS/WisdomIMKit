//
//  SRPUtils.h
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInteger.h"
#import "SRPContants.h"
@interface SRPUtils : NSObject

@property (nonatomic,retain)BigInteger *TWO;



+(NSString *)hashToBytes:(NSString *)s;
+(BigInteger *)hash:(NSString *)str;


+(BigInteger *)hashWithBigInteger:(BigInteger *)i;
+(NSString *)hashToBytesWithBigInteger:(BigInteger *)i;

+(BigInteger *)random:(SRPContants *)contants;
+(BigInteger *)mackPrivateKey:(NSString *)username password:(NSString *)password salt:(NSString *)salt;
+(BigInteger *)calc_i:(BigInteger *)A and:(BigInteger *)B;
+(BigInteger *)calcM1WithSRPContants:(SRPContants *)contants StrWithfUsername:(NSString *)fUsername BigIntegerA:(BigInteger *)fPublickKey_A BigIntegerB:(BigInteger *)fPublickKey_B fCommonValueK:(BigInteger *)fCommonValue_K andfsalt:(BigInteger *)fsalt;

@end
