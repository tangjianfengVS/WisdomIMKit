//
//  SessionNIOC.m
//  ZHInvestBusinessiOS
//
//  Created by 汤建锋 on 2017/11/14.
//  Copyright © 2017年 ZHInvest. All rights reserved.
//

#import "SessionLoginNI.h"
#import "NSString+SHA256.h"
#import "SRPContants.h"
#import "SRPClientSession.h"
#import "ZKAFJSONRPCClient.h"
#import "myTool.h"
#import "SVProgressHUD.h"

@implementation SessionLoginNI {
    NSString *_m;
    NSString *_s;
    SRPContants *contants;
    SRPClientSession *clientSession;
    ZKAFJSONRPCClient *client;
}

- (instancetype)init{
    if (self = [super init]) {
        self.needShowSVP = YES;
    }
    return self;
}

//MARK : 登录
-(void)loginWithUserName:(NSString *)userName
                Password:(NSString *)password
             Devicemodel:(NSString *)devicemodel
                Deviceid:(NSString *)deviceid finishBlock:(void(^)(BOOL))finishBlock{
    if (userName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入账号"];
        finishBlock(NO);
        return;
    }else if (userName.length == 0){
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        finishBlock(NO);
        return;
    }
    NSString *PasswordEncryStr = [password sha256];
    contants = [[SRPContants alloc]init];
    BigInteger *p=[[BigInteger alloc]initWithString:[NSString getSSkey]radix:16];
    BigInteger *q=[[BigInteger alloc]initWithString:@"2" radix:16];
    contants.N = p;
    contants.g = q;
    NSString *str = [NSString stringWithFormat:@"%@:%@",[p toRadix:10],[q toRadix:10]];
    BigInteger *k = [SRPUtils hash:str];
    contants.k = k;
    client = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:[NSURL URLWithString:@"https://auth.cshuanyu.com"] AndClientP12fileName:nil andServerCerfileName:@"auth.cshuanyu.com" andP12Password:@"123456"];
    NSDictionary *params = @{@"userpk": userName, @"e":e ,@"deviceid": deviceid ,@"devicemodel": devicemodel};
    if (self.needShowSVP) {
        [SVProgressHUD showWithStatus:@" 正在登录 "];
    }
    __weak __typeof(self) weakSelf = self;
    [client invokeMethod:@"setUser" withParameters:params interface:@"auth" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
         __strong __typeof(self) strongSelf = weakSelf;
        if ([responseObject[@"success"] isEqualToString:@"false"]) {
            if (strongSelf.needShowSVP) {
                [SVProgressHUD showErrorWithStatus:@"请检查账号"];
            }
            finishBlock(NO);
            return;
        }
        NSArray *data=responseObject[@"data"];
        NSDictionary *dict = data[0];
        _m = dict[@"m"];
        _s = dict[@"s"];
        clientSession = [[SRPClientSession alloc]initWithSRPContants:contants andUsername:_m andPassword:PasswordEncryStr];
        NSString *SStr = [_s rangeWithlocation:2];
        BigInteger *S = [[BigInteger alloc]initWithString:SStr radix:16];
        [clientSession setSalt_s:S];
        //得到A
        BigInteger *A = [clientSession getA];
        NSString *AV = [A toRadix:16];
        [strongSelf loginPasswordSession:userName password:password av:AV finishBlock:finishBlock];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.needShowSVP) {
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
        }
        finishBlock(NO);
    }];
}

//MARK : 密码验证
-(void)loginPasswordSession:(NSString *)userName password:(NSString *)password av:(NSString *)av finishBlock:(void(^)(BOOL))finishBlock{
    NSDictionary *params=@{@"userpk": userName,@"Av":av};
    __weak __typeof(self) weakSelf = self;
    [client invokeMethod:@"setA" withParameters:params interface:@"auth" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSArray *data = responseObject[@"data"];
        NSDictionary *dict = data[0];
        NSString *BB = dict[@"B"];
        NSString *BStr = [BB rangeWithlocation:2];
        BigInteger *Bbig = [[BigInteger alloc]initWithString:BStr radix:16];
        [clientSession setServerPublicKey:Bbig];
        //得到了m1
        BigInteger *m1=[clientSession getEvidenceValue_M1];
        NSString *str=[m1 toRadix:16];
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf loginSETM1Session:userName password:password m1:str finishBlock:finishBlock];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.needShowSVP) {
            [SVProgressHUD showErrorWithStatus:@"请检查网络"];
        }
        finishBlock(NO);
    }];
}

//MARK : 获取数据
-(void)loginSETM1Session:(NSString *)userName  password:(NSString *)password m1:(NSString *)m1 finishBlock:(void(^)(BOOL))finishBlock{
    NSDictionary *params=@{@"userpk": userName ,@"M1v":m1};
    __weak __typeof(self) weakSelf = self;
    [client invokeMethod:@"setM1" withParameters:params interface:@"auth" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if ([responseObject[@"success"] isEqualToString:@"true"]) {
            NSArray *data=responseObject[@"data"];
            NSDictionary *dict=data[0];
            NSString *M2=dict[@"M2"];
            NSString *m2Str=[M2 rangeWithlocation:2];
            BigInteger *m22=[[BigInteger alloc]initWithString:m2Str radix:16];
            if([clientSession isValidateServerEvidenceValue_M2:m22]){
                NSDictionary *cerDataDict = responseObject[@"data"][0];
                NSDictionary *certDict = cerDataDict[@"cert"];
                NSString *cerDataStr = certDict[@"cert_content"];
                NSString *cer_pass = certDict[@"cert_pass"];
                NSString *cer_expired = certDict[@"cert_expired"];
                NSString *user_expired = cerDataDict[@"expired"];
                NSDictionary *security = cerDataDict[@"security"];
                NSString *uidStr=_m;
                [DEFAULTS setObject:uidStr forKey:UID];
                [DEFAULTS setObject:cer_pass forKey:CERPASSWORD];
                [DEFAULTS setObject:cer_expired forKey:CEREXPIRED];
                [DEFAULTS setObject:@"1" forKey:ISACTIVATE];
                [DEFAULTS setObject:password forKey:USERPASSWORD];
                [DEFAULTS setObject:user_expired forKey:USEREXPIRED];
                [DEFAULTS setObject:security[@"loginId"] forKey:LOGINID];
                [DEFAULTS setObject:security[@"m1"] forKey:M1];
                [DEFAULTS setObject:security[@"randomKey"] forKey:RANDOMKEY];
                [DEFAULTS setObject:security[@"seqId"] forKey:SEQID];
                [DEFAULTS setObject:security[@"sid"] forKey:SID];
                [DEFAULTS setObject:security[@"skey"] forKey:SKEY];
                [DEFAULTS setObject:security[@"uin"] forKey:UIN];
                [DEFAULTS setObject:security[@"userId"] forKey:USERID];
                NSString *username = [NSString stringWithFormat:@"%@_%@",security[@"userId"],USERNAME];
                NSString *mobile = [NSString stringWithFormat:@"%@_%@",security[@"userId"],MOBILE];
                [DEFAULTS setObject:userName forKey:username];
                [DEFAULTS setObject:security[@"mobile"] forKey:mobile];
                [DEFAULTS synchronize];
                NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:cerDataStr options:0];
                __strong __typeof(self) strongSelf = weakSelf;
                if([strongSelf saveData:nsdataFromBase64String P12FileName:uidStr]){
                    //[strongSelf pushDeviceTokenToService:finishBlock];
                    [SVProgressHUD dismiss];
                    finishBlock(YES);
                }
            }else{
                __strong __typeof(self) strongSelf = weakSelf;
                if (strongSelf.needShowSVP) {
                    [SVProgressHUD showErrorWithStatus:@"登录失败，请联系管理员"];
                }
                finishBlock(NO);
            }
        }else{
            __strong __typeof(self) strongSelf = weakSelf;
            if (strongSelf.needShowSVP) {
                [SVProgressHUD showErrorWithStatus:@"登录失败，请重新登录"];
            }
            finishBlock(NO);
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.needShowSVP) {
            [SVProgressHUD showErrorWithStatus:@"请检查网络"];
        }
        finishBlock(NO);
    }];
}

//MARK : 后台同步数据
-(void)pushDeviceTokenToService:(void(^)(BOOL))finishBlock {
    NSString *UIdStr = [DEFAULTS objectForKey:UID];
    NSString *Cer_password = [DEFAULTS objectForKey:CERPASSWORD];
    //NSLog(@"%@====%@====%@",UIdStr,Cer_password,[DEFAULTS objectForKey:DEVICETOKEN]);
    ZKAFJSONRPCClient *client1 = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:[NSURL URLWithString:@"https://api.cshuanyu.com"] AndClientP12fileName:UIdStr andServerCerfileName:@"api.cshuanyu.com" andP12Password:Cer_password];
    NSDictionary *params = @{@"dv":[myTool ReturnStrWithResult:[DEFAULTS objectForKey:DEVICETOKEN]]};
    [client1 invokeMethod:@"registerIOSDeviceToken" withParameters:params interface:@"user" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if([responseObject[@"success"] isEqualToString:@"true"]){
            [SVProgressHUD dismiss];
            finishBlock(YES);
        }else{
            [SVProgressHUD showErrorWithStatus:@"登录失败，请联系管理员"];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"请检查网络"];
    }];
}

//MARK : 注册-检测信息
-(void)registWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock{
    NSString *title = [phoneNum phoneNumExamine];
    if (title) {
        [SVProgressHUD showErrorWithStatus:title];
        return;
    }
    client = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:
                                 [NSURL URLWithString:@"https://api.cshuanyu.com"]
                                 AndClientP12fileName:@"trllojtej3cnd6cgclyw.6"
                                 andServerCerfileName:@"api.cshuanyu.com"
                                 andP12Password:@"i8GRPYmFfyDfHhKwkK"];
    NSDictionary *Dict = @{@"mobile": phoneNum, @"e": e};
    [SVProgressHUD showWithStatus:@"正在检测用户信息"];
    [client invokeMethod:@"validate_userinfo_exits" withParameters:Dict interface:@"validator" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if([responseObject[@"success"] isEqualToString:@"true"]){
            __weak __typeof(self) weakSelf = self;
            [weakSelf registAccountCreateWithPhoneNum:phoneNum finishBlock:finishBlock];
        }else{
            NSDictionary *errmsg=responseObject[@"errmsg"];
            [SVProgressHUD showErrorWithStatus:errmsg[@"data"]];
        }
    }failure:^(NSURLSessionDataTask *operation, NSError *error) {
        __weak __typeof(self) weakSelf = self;
        [weakSelf registAccountCreateWithPhoneNum:phoneNum finishBlock:finishBlock];
    }];
}

//MARK : 注册-创建用户
-(void)registAccountCreateWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock {
    client = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:
              [NSURL URLWithString:@"https://api.cshuanyu.com"]
                                      AndClientP12fileName:@"trllojtej3cnd6cgclyw.6"
                                      andServerCerfileName:@"api.cshuanyu.com"
                                            andP12Password:@"i8GRPYmFfyDfHhKwkK"];
    NSString *createPass = [NSString return8LetterAndNumber];
    NSDictionary *params = @{@"mobile": phoneNum, @"login_id": phoneNum,
                             @"password": createPass, @"e":e,
                             @"email": @"info@cshuanyu.com"};
    __weak __typeof(self) weakSelf = self;
    [client invokeMethod:@"addUser" withParameters:params interface:@"user" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if([responseObject[@"success"] isEqualToString:@"true"]){
            NSDictionary *cerDataDict=responseObject[@"data"][0];
            NSDictionary *certDict=cerDataDict[@"cert"];
            NSString *cerDataStr=certDict[@"cert_content"];
            NSString *cer_pass=certDict[@"cert_pass"];
            NSString *uidStr=cerDataDict[@"uid"];
            NSString *cer_expired=certDict[@"cert_expired"];
            [DEFAULTS setObject:phoneNum forKey:USERNAME];
            [DEFAULTS setObject:uidStr forKey:UID];
            [DEFAULTS setObject:cer_pass forKey:CERPASSWORD];
            [DEFAULTS setObject:cer_expired forKey:CEREXPIRED];
            [DEFAULTS setObject:createPass forKey:USERPASSWORD];
            [DEFAULTS synchronize];
            NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:cerDataStr options:0];
            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf saveData:nsdataFromBase64String P12FileName:uidStr];
            [SVProgressHUD showSuccessWithStatus:@" 激活成功 "];
            finishBlock(YES);
        }else{
            [SVProgressHUD showErrorWithStatus:@"手机号已注册"];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"请检查网络"];
    }];
}

//MARK : 注册-获取验证码
-(void)registAccountGetCodeWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock {
    NSString *UIdStr = [DEFAULTS objectForKey:UID];
    NSString *Cer_password = [DEFAULTS objectForKey:CERPASSWORD];
    client = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:[NSURL URLWithString:@"https://api.cshuanyu.com"] AndClientP12fileName:UIdStr andServerCerfileName:@"api.cshuanyu.com"
                                            andP12Password:Cer_password];
    NSDictionary *dict=@{@"userpk":phoneNum};
    [SVProgressHUD showWithStatus:@"正在获取验证码"];
    [client invokeMethod:@"fetch_validcode" withParameters:dict interface:@"user" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if([responseObject[@"success"] isEqualToString:@"true"]){
            [SVProgressHUD showSuccessWithStatus:@"获取成功，请查看短信"];
            finishBlock(YES);
        }else{
            [SVProgressHUD showErrorWithStatus:@"获取验证码失败"];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"获取验证码失败"];
    }];
}

//MARK : 注册-发送验证码
-(void)registAccountTestSetCodeWithPhoneNum:(NSString *)phoneNum num:(NSString *)number finishBlock: (void(^)(BOOL))finishBlock{
    if (number == nil) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }else if (number.length != 6){
        [SVProgressHUD showErrorWithStatus:@"验证码格式错误"];
        return;
    }
    NSString *UIdStr = [DEFAULTS objectForKey:UID];
    NSString *Cer_password = [DEFAULTS objectForKey:CERPASSWORD];
    client = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:[NSURL URLWithString:@"https://api.cshuanyu.com"] AndClientP12fileName:UIdStr andServerCerfileName:@"api.cshuanyu.com" andP12Password:Cer_password];
    NSDictionary *params = @{@"userpk":phoneNum,@"token":number};
    [SVProgressHUD showWithStatus:@"正在验证"];
    [client invokeMethod:@"activateUser" withParameters:params interface:@"user" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if([responseObject[@"success"] isEqualToString:@"true"]){
            [DEFAULTS setObject:phoneNum forKey:USERNAME];
            [DEFAULTS setObject:@"1" forKey:ISACTIVATE];
            [DEFAULTS synchronize];
            [SVProgressHUD showSuccessWithStatus:@" 验证成功 "];
            finishBlock(YES);
            //__strong __typeof(self) strongSelf = weakSelf;
            //[strongSelf JHPushDeviceTokenToService:finishBlock];
        }else{
            [SVProgressHUD showErrorWithStatus:@"用户注册失败，请联系管理员"];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"请检查网络"];
    }];
}


//MARK : 修改密码
-(void)updataPasswordWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock{
    NSString *title = [phoneNum phoneNumExamine];
    if (title) {
        [SVProgressHUD showErrorWithStatus:title];
        return;
    }
    client=[[ZKAFJSONRPCClient alloc]initWithEndpointURL:
                               [NSURL URLWithString:@"https://api.cshuanyu.com"]
                               AndClientP12fileName:@"trllojtej3cnd6cgclyw.6"
                               andServerCerfileName:@"api.cshuanyu.com"
                               andP12Password:@"i8GRPYmFfyDfHhKwkK"];
    NSDictionary *params=@{@"email":phoneNum};
    [SVProgressHUD showWithStatus:@" 正在处理 "];
    [client invokeMethod:@"forgetPassword" withParameters:params interface:@"user" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        if([responseObject[@"success"] isEqualToString:@"true"]){
            [SVProgressHUD showSuccessWithStatus:@"找回密码成功，请查看短信"];
            finishBlock(YES);
        }else{
            [SVProgressHUD showErrorWithStatus:@"找回密码失败"];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"找回密码失败"];
    }];
}

- (BOOL)saveData:(NSData *)data P12FileName:(NSString *)p12FileName{
    NSString *sandboxPath = NSHomeDirectory();
    NSString *documentPath = [sandboxPath stringByAppendingPathComponent:@"Documents"];
    NSString *fileName=[NSString stringWithFormat:@"%@.p12",p12FileName];
    NSString *FileName=[documentPath stringByAppendingPathComponent:fileName];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:FileName]) {
        NSError *error;
        if([fm removeItemAtPath:FileName error:&error]){
            NSLog(@"删除成功");
        }else{
            NSLog(@"删除失败");
        }
    }else{
        NSLog(@"不存在");
    }
    if([fm createFileAtPath:FileName contents:data attributes:nil]){
        NSLog(@"写入成功");
        return YES;
    }else{
        NSLog(@"写入失败");
        return NO;
    }
}

//MARK : 激活账号
-(void)JHPushDeviceTokenToService:(void(^)(BOOL))finishBlock {
    NSString *UIdStr = [DEFAULTS objectForKey:UID];
    NSString *Cer_password = [DEFAULTS objectForKey:CERPASSWORD];
    client = [[ZKAFJSONRPCClient alloc]initWithEndpointURL:[NSURL URLWithString:@"https://api.cshuanyu.com"] AndClientP12fileName:UIdStr andServerCerfileName:@"api.cshuanyu.com" andP12Password:Cer_password];
    NSDictionary *params = @{@"dv": [DEFAULTS objectForKey:DEVICETOKEN] };
    [client invokeMethod:@"registerIOSDeviceToken" withParameters:params interface:@"user" requestID:@"1" success:^(NSURLSessionDataTask *operation, id responseObject) {
        //NSLog(@"上传devicetoken===%@",responseObject);
        if([responseObject[@"success"] isEqualToString:@"true"]){
            [SVProgressHUD showSuccessWithStatus:@" 激活成功 "];
            finishBlock(YES);
        }else{
            [SVProgressHUD showErrorWithStatus:@"激活失败，请联系管理员"];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"请检查网络"];
    }];
}

- (void)dealloc{
    NSLog(@"LoginNI--释放");
}
@end
