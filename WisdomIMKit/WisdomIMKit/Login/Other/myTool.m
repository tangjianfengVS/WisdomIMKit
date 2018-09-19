//
//  myTool.m
//  Guangdaxiangmu1
//
//  Created by shenpukeji on 15/5/21.
//  Copyright (c) 2015年 shenpukeji. All rights reserved.
//

#import "myTool.h"

@implementation myTool
+(UILabel *)lableWithTitle:(NSString *)title frame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.font = font;
    label.textColor = color;
    return label;
}
+(UIButton *)btnWithTitle:(NSString *)title frame:(CGRect)frame imageName:(NSString *)imageName tag:(NSInteger)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setFrame:frame];
    //    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    //    btn.titleLabel.textAlignment=NSTextAlignmentLeft;
    //    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    btn.tag = tag;
    return btn;
}
+(UIButton *)btnWithTitle:(NSString *)title frame:(CGRect)frame imageName:(NSString *)imageName tag:(NSInteger)tag andColor:(UIColor *)color TextSize:(NSInteger)size
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor=color;
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.frame=frame;
    
    
    [btn setTitle:title forState:UIControlStateNormal];
    
    btn.tag=tag;
    btn.titleLabel.font=[UIFont systemFontOfSize:size];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    return btn;
}



//  颜色数值转换:#ababab
+(UIColor *)changeColor:(NSString *)str{
    unsigned int red,green,blue;
    NSString * str1 = [str substringWithRange:NSMakeRange(0, 2)];
    NSString * str2 = [str substringWithRange:NSMakeRange(2, 2)];
    NSString * str3 = [str substringWithRange:NSMakeRange(4, 2)];
    
    NSScanner * canner = [NSScanner scannerWithString:str1];
    [canner scanHexInt:&red];
    
    canner = [NSScanner scannerWithString:str2];
    [canner scanHexInt:&green];
    
    canner = [NSScanner scannerWithString:str3];
    [canner scanHexInt:&blue];
    UIColor * color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return color;
}
+(NSString *)timeStringWithString:(NSString *)str
{
    NSString *timeStr = [[NSString alloc]init];
    int time = [str intValue];
    if (time >= 0 && time < 60) {
        timeStr = [NSString stringWithFormat:@"%d分钟",time];
    }else if (time >=60 && time < 60 * 24) {
        time = time/60;
        timeStr = [NSString stringWithFormat:@"%d小时",time];
    }else if (time >= 60 * 24 && time < 60 * 24 * 7) {
        time = time/(60 * 24);
        timeStr= [NSString stringWithFormat:@"%d天",time];
    }else if (time >= 60 * 24 * 7 && time < 60 * 24 * 7 * 5) {
        time = time/(60 * 24 * 7);
        timeStr = [NSString stringWithFormat:@"%d周",time];
    }else if (time >= 60 * 24 * 7 * 5 && time < 60 * 24 * 365) {
        time = time/(60 * 24 * 30);
        timeStr = [NSString stringWithFormat:@"%d月",time];
    }else if (time >= 60 * 24 * 365) {
        time = time/(60 * 24 * 365);
        timeStr = [NSString stringWithFormat:@"%d年",time];
    }
    return timeStr;
}

+(void)AlertTip:(NSString *)Tip andAlertBody:(NSString *)alertBody
{
    UIAlertView *aler=[[UIAlertView alloc]initWithTitle:Tip message:alertBody delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [aler show];
}

+(NSString *)getDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}

+(UIFont *)returnUIFont
{
//    if (ISFOREIPHONE5) {
//        return [UIFont systemFontOfSize:13];
//    }else if(ISFOREIPHONE6){
//        return [UIFont systemFontOfSize:15];
//    }else if(ISFOREIPHONE6P)
//    {
//        return [UIFont systemFontOfSize:16];
//    }
    return nil;
}
+(UIFont *)returnUIFontWithiphone5:(NSInteger)Iphone5Num Iphone6:(NSInteger)iphone6num andIphone6P:(NSInteger)iphone6Pnum
{
//    if (ISFOREIPHONE5) {
//        return [UIFont systemFontOfSize:Iphone5Num];
//    }else if(ISFOREIPHONE6){
//        return [UIFont systemFontOfSize:iphone6num];
//    }else if(ISFOREIPHONE6P)
//    {
//        return [UIFont systemFontOfSize:iphone6Pnum];
//    }
    return nil;
}

+(NSString *)ReturnStrWithResult:(id)Result
{
    NSString *Str=@"";
    if (![Result isKindOfClass:[NSNull class]]) {
        if ([Result isKindOfClass:[NSString class]]) {
            Str=Result;
        }
    }
    return Str;
}

+(NSString *)returnDateFromdateStr:(NSString *)Sting
{
    //根据字符串转换成一种时间格式 供下面解析
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* inputDate = [inputFormatter dateFromString:Sting];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeSTR=[inputFormatter stringFromDate:inputDate];
    return timeSTR;
}
@end
