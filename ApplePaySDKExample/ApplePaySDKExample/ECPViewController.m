//
//  ECPViewController.m
//  ApplePaySDKExample
//
//  Created by Ecpay on 2017/6/5.
//  Copyright © 2017年 Ecpay. All rights reserved.
//

#import "ECPViewController.h"
#import "ECPServerOrder.h"

@interface ECPViewController ()
{
    BOOL canLoadData;
}

@end

@implementation ECPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (IBAction)BuyWithApplePay:(id)sender {
    
    if([PKPaymentAuthorizationViewController canMakePayments]) {
        
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"手機20元"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"40"]];
        
        PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"隨身碟60元"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"60"]];
        
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total"
                                                                          amount:[NSDecimalNumber decimalNumberWithString:@"100"]];
        
        request.paymentSummaryItems = @[widget1, widget2, total];
        request.countryCode = @"TW"; //國家代碼
        request.currencyCode = @"TWD"; //貨幣代碼
        request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
        request.merchantIdentifier = @""; //你的merchantId
        request.merchantCapabilities = PKMerchantCapability3DS;
        
        PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentPane.delegate = self;
        
        if (paymentPane) {
            [self presentViewController:paymentPane animated:TRUE completion:nil];
        }else{
            NSLog(@"此裝置不能使用apple pay");
        }
        
        
    } else {
        NSLog(@"此裝置不能使用apple pay");
    }
    
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    // hide the payment window
    [controller dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    
    NSData *data = payment.token.paymentData;
    NSDictionary *dicFormatToken = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    //組payment token for server
    NSMutableDictionary *paymentMethod = [NSMutableDictionary new];
    paymentMethod[@"network"] = payment.token.paymentMethod.network;
    paymentMethod[@"type"] = [self changePaymentType:payment.token.paymentMethod.type];
    paymentMethod[@"displayName"] = payment.token.paymentMethod.displayName;
    
    NSMutableDictionary *sendPayment = [NSMutableDictionary new];
    sendPayment[@"paymentData"] = dicFormatToken;
    sendPayment[@"paymentMethod"] = paymentMethod;
    
    NSMutableDictionary *sendPaymentToken = [NSMutableDictionary new];
    sendPaymentToken[@"token"] = sendPayment;
    
    
    //======================================================================================================
    //以下是自己server與綠界溝通
    //======================================================================================================
    
    //收到信用卡資料後，送到server進行付款動作
    if(canLoadData){
        return;
    }
    canLoadData = YES;
    
    NSMutableDictionary *attributes = [@{
                                         @"MerchantTradeNo"     : [self getRadomTradeNo],  //廠商交易編號
                                         @"MerchantTradeDate"   : [self getDataString],  //廠商交易時間
                                         @"TotalAmount"         : @100,                   //交易金額
                                         @"CurrencyCode"        : @"TWD",                   //幣別
                                         @"ItemName"            : @"手機20元X2#隨身碟60元X1"  ,//商品名稱
                                         @"TradeDesc"           : @"ECpay商城購物",         //交易描述
                                         } mutableCopy];
    
    attributes[@"PaymentToken"] = sendPaymentToken;
    
    
    [ECPServerOrder create:attributes
                    action:^(id responseObject, NSError *error){
                        
                        canLoadData = NO;
                        
                        if(error){
                            NSLog(@"Error: %@", error);
                            
                            completion(PKPaymentAuthorizationStatusFailure);
                            
                            // do something to let the user know the status
                            NSLog(@"Payment was unsuccessful");
                            
                        }else{
                            NSLog(@"%@" ,responseObject);
                            
                            if ([[responseObject objectForKey:@"RtnCode"] integerValue] == 1) {
                                completion(PKPaymentAuthorizationStatusSuccess);
                                NSLog(@"Payment was successful");
                            }else{
                                completion(PKPaymentAuthorizationStatusFailure);
                                NSLog(@"Payment was unsuccessful");
                            }
                        }
                    }];
}

#pragma mark - Utils
//隨機產生交易序號
-(NSString *)getRadomTradeNo
{
    //這是範例隨機自定的，請使用自己定義的交易序號
    return [NSString stringWithFormat:@"ECPSDK%lld",[@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue] ];
    
}

-(NSString *)getDataString
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", dateString);
    
    return dateString;
}

-(NSString *)changePaymentType:(PKPaymentMethodType)type{
    switch (type) {
        case 0:
            return @"debit";
            break;
        case 1:
            return @"credit";
            break;
        case 2:
            return @"prepaid";
            break;
        default:
            return @"";
            break;
    }
}

@end
