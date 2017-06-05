//
//  ECPServerOrder.h
//  ApplePaySDKExample
//
//  Created by Ecpay on 2017/6/5.
//  Copyright © 2017年 Ecpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ECPServerOrder : NSObject

+(AFHTTPSessionManager *)create:(id)parameters
                         action:(void (^)(id responseObject, NSError *error))block;


@end
