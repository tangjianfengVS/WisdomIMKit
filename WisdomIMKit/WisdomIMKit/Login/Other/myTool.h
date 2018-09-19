//
//  myTool.h
//  Guangdaxiangmu1
//
//  Created by shenpukeji on 15/5/21.
//  Copyright (c) 2015年 shenpukeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface myTool : NSObject
+(UILabel *)lableWithTitle:(NSString *)title frame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color;
+(UIButton *)btnWithTitle:(NSString *)title frame:(CGRect)frame imageName:(NSString *)imageName tag:(NSInteger)tag;
+(UIButton *)btnWithTitle:(NSString *)title frame:(CGRect)frame imageName:(NSString *)imageName tag:(NSInteger)tag andColor:(UIColor *)color TextSize:(NSInteger)size;
// #aaa 十六进制
+(UIColor *)changeColor:(NSString *)str;

+(void)AlertTip:(NSString *)Tip andAlertBody:(NSString *)alertBody;

//时间转换，str为分钟数，按照不同情况转换为小时，天，周，月，年
+(NSString *)timeStringWithString:(NSString *)str;

+(NSString *)getDate;

+(UIFont *)returnUIFont;

+(UIFont *)returnUIFontWithiphone5:(NSInteger)Iphone5Num Iphone6:(NSInteger)iphone6num andIphone6P:(NSInteger)iphone6Pnum;
//判断是什么类型的
+(NSString *)ReturnStrWithResult:(id)Result;

+(NSString *)returnDateFromdateStr:(NSString *)Sting;

@end
