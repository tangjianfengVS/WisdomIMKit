//
//  SRPClientSession.m
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import "SRPClientSession.h"

@implementation SRPClientSession
{
    NSString *_I;  //用户名
    NSString *_P;   //密码
    BigInteger *_s;
    BigInteger *_A;
     BigInteger *_B;
     BigInteger *_S_c;
     BigInteger *_K_c;
     SRPContants *_fContants;
     BigInteger *_u;
     BigInteger *_x;
     BigInteger *_a;
     BigInteger *_M_c;
    
}


-(id)initWithSRPContants:(SRPContants *)SRPContant andUsername:(NSString *)username andPassword:(NSString *)password;
{
    self=[super init];
    if (self) {

        _fContants=SRPContant;
        _I=username;
        _P=password;
        
    }
    return self;
}


-(void)setSalt_s:(BigInteger *)salt
{
 

    _s=salt;

    _a=[SRPUtils random:_fContants];
    

    BigInteger *N=[[BigInteger alloc]initWithString:@"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4"\
                   "A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF60"\
                   "95179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF"\
                   "747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B907"\
                   "8717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB37861"\
                   "60279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DB"\
                   "FBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73"
                                              radix:16];
    
     BigInteger *g=[[BigInteger alloc]initWithString:@"2" radix:16];
    _A=[g exp:_a modulo:N];
    
    NSString *SStr=[salt toRadix:10];
    
    NSString *IStr=[[SRPUtils hash:[NSString stringWithFormat:@"%@:%@",_I,_P]] toRadix:10];

    NSLog(@"nima::%@",[NSString stringWithFormat:@"%@:%@",SStr,IStr]);
    _x=[SRPUtils hash:[NSString stringWithFormat:@"%@:%@",SStr,IStr]];
}

-(void)setServerPublicKey:(BigInteger *)publicKey_B
{
    if (!_A) {
        NSLog(@"确实A");
    }
    _B=publicKey_B;
    _u=[SRPUtils hash:[NSString stringWithFormat:@"%@:%@",[_A toRadix:10],[_B toRadix:10]]];
   
    BigInteger *N=[[BigInteger alloc]initWithString:@"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4"\
                   "A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF60"\
                   "95179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF"\
                   "747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B907"\
                   "8717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB37861"\
                   "60279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DB"\
                   "FBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73"
                                              radix:16];
    
    BigInteger *g=[[BigInteger alloc]initWithString:@"2" radix:16];
    NSString *str=[NSString stringWithFormat:@"%@:%@",[N toRadix:10],[g toRadix:10]];
    BigInteger *k=[SRPUtils hash:str];
   
    
    BigInteger *P1=[_B sub:[k multiply:[g exp:_x modulo:N]]];

    BigInteger *P2=[_a add:[_u multiply:_x]];

    _S_c=[P1 exp:P2 modulo:N];
    _K_c=[SRPUtils hash:[_S_c toRadix:10]];
    
 
    P1=[[SRPUtils hash:[N toRadix:10]] bitwiseXor:[SRPUtils hash:[g toRadix:10]]];
    
   
    NSString *r=[NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[P1 toRadix:10],[[SRPUtils hash:_I] toRadix:10],[_s toRadix:10],[_A toRadix:10],[_B toRadix:10],[_K_c toRadix:10]];
    
    _M_c=[SRPUtils hash:r];
    NSLog(@"_M_c::%@",[_M_c toRadix:16]);
    
}
-(BigInteger *)getEvidenceValue_M1
{
    return _M_c;
}

-(BOOL)isValidateServerEvidenceValue_M2:(BigInteger *)evidenceValueFromServer_M2
{
    BigInteger *M_S=[SRPUtils hash:[NSString stringWithFormat:@"%@:%@:%@",[_A toRadix:10],[_M_c toRadix:10],[_K_c toRadix:10]]];
    if ([M_S isEqualToBigInteger:evidenceValueFromServer_M2]) {
        return true;
    }else{
        return false;
    }
    
}
-(BigInteger *)getA
{
    return _A;
}
-(SRPContants *)getContants
{
    return _fContants;
}

@end
