//
//  SRPClientSession.h
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInteger.h"
#import "SRPContants.h"
#import "SRPUtils.h"
@interface SRPClientSession : NSObject

//@property (nonatomic,retain)SRPContants *fContants;

-(id)initWithSRPContants:(SRPContants *)SRPContant andUsername:(NSString *)username andPassword:(NSString *)password;
-(void)setSalt_s:(BigInteger *)salt;
-(void)setServerPublicKey:(BigInteger *)publicKey_B;
-(BigInteger *)getEvidenceValue_M1;
-(BOOL)isValidateServerEvidenceValue_M2:(BigInteger *)evidenceValueFromServer_M2;
-(BigInteger *)getA;
-(SRPContants *)getContants;
@end
