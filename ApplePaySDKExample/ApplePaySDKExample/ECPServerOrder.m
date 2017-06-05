//
//  ECPServerOrder.m
//  ApplePaySDKExample
//
//  Created by Ecpay on 2017/6/5.
//  Copyright © 2017年 Ecpay. All rights reserved.
//

#import "ECPServerOrder.h"

//請填入您伺服器端的介接網址
#define ECP_STAGE_ServerOrder_URL_STRING @""

@implementation ECPServerOrder

+(AFHTTPSessionManager *)create:(id)parameters
                         action:(void (^)(id responseObject, NSError *error))block {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes =[[NSSet alloc] initWithObjects: @"text/html",@"text/plain", nil];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    
    [manager POST:ECP_STAGE_ServerOrder_URL_STRING parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if( [responseObject objectForKey:@"RtnCode"] && [responseObject objectForKey:@"RtnCode"] != [NSNull null]){
            if (block) {
                block(responseObject, nil);
            }
        }else{
            if (block) {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Parse Error" forKey:NSLocalizedDescriptionKey];
                
                NSError *error = [NSError errorWithDomain:@"tw.com.yourdomain" code:1000 userInfo:details];
                block(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
    
    return manager;
}

@end
