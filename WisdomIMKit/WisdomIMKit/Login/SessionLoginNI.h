//
//  SessionNIOC.h
//  ZHInvestBusinessiOS
//
//  Created by 汤建锋 on 2017/11/14.
//  Copyright © 2017年 ZHInvest. All rights reserved.
//

#import <Foundation/Foundation.h>
#define USERNAME @"username"
#define USERPASSWORD @"userpassword"    //登录M
#define CERPASSWORD @"password"         //证书M
#define UID @"uid"
#define CEREXPIRED @"cert_expired"
#define DEVICETOKEN @"devicetoken"
#define ISREGISTER @"isregister"
#define ISACTIVATE @"isactivate"
#define USEREXPIRED @"user_expired"
#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define E @"00100000001"
#define MODE @"PRD"
#define e @"00100000001"
#define LOGINID @"loginId"
#define M1 @"m1"
#define MOBILE @"mobile"
#define RANDOMKEY @"randomKey"
#define SEQID @"seqId"
#define SID @"sid"
#define SKEY @"skey"
#define UIN @"uin"
#define USERID @"userId"

@interface SessionLoginNI : NSObject
@property(nonatomic,assign) BOOL needShowSVP;
//MARK : 登录
-(void)loginWithUserName:(NSString *)userName Password:(NSString *)password
             Devicemodel:(NSString *)devicemodel Deviceid:(NSString *)deviceid
             finishBlock:(void(^)(BOOL))finishBlock;
//MARK : 注册-检测用户
-(void)registWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock;
//MARK : 注册-获取验证码
-(void)registAccountGetCodeWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock;
//MARK : 注册-发送验证码
-(void)registAccountTestSetCodeWithPhoneNum:(NSString *)phoneNum num:(NSString *)number finishBlock: (void(^)(BOOL))finishBlock;
//MARK : 修改密码
-(void)updataPasswordWithPhoneNum:(NSString *)phoneNum finishBlock: (void(^)(BOOL))finishBlock;
@end
