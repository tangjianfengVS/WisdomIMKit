//
//  SRPContants.h
//  json-rpc-demo
//
//  Created by shenpukeji on 16/7/29.
//  Copyright © 2016年 Demiurgic Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInteger.h"
@interface SRPContants : NSObject
@property (nonatomic,retain)NSArray *N_2048;

@property (nonatomic,assign)BigInteger *N;
@property (nonatomic,assign)BigInteger *g;
@property (nonatomic,assign)BigInteger *k;
-(id)init;
@end
