//
//  NSString+SHA256.h
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MONEYEMPTY @"¥ "

@interface NSString (SHA256)
- (NSString *) sha256;
+ (NSString *) getSSkey;
- (NSString *)rangeWithlocation:(int)location;
- (NSString *)phoneNumExamine;
+ (NSString *)return8LetterAndNumber;
- (NSString *)sendShoppsNumVerificationWith:(NSString *)title;
- (NSString *)quotationVerification;
@end
