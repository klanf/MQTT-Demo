//
//  FCMQTTManager.m
//  AGV
//
//  Created by jaime on 2019/4/29.
//  Copyright © 2019 qinghua.ios. All rights reserved.
//

#import "FCMQTTManager.h"
#import "MQTTSessionManager.h"
#import "MQTTLog.h"
#import "MQTTClient.h"

@interface FCMQTTManager () <MQTTSessionManagerDelegate>

@property MQTTSessionManager *sessionManager;
@property NSString *vendorIdentifier;
@property NSTimer *timer;

@end

@implementation FCMQTTManager

#pragma mark - Singleton Pattern
+ (FCMQTTManager *)sharedManager {
    
    static FCMQTTManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initSharedManager];
    });
    
    return sharedManager;
}

- (instancetype)init {
    
    return nil;
}

- (instancetype)initSharedManager {
    
    self = [super init];
    if (self) {
        // Do any other initialisation stuff here
        [MQTTLog setLogLevel:0];
        
        //注册唯一标识符
        self.vendorIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"VendorIdentifier"];
        if (!self.vendorIdentifier) {
            self.vendorIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:self.vendorIdentifier forKey:@"VendorIdentifier"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return self;
}


- (void)connectToBroker {
    
    if (!self.sessionManager) {
        self.sessionManager = [[MQTTSessionManager alloc] init];
        self.sessionManager.delegate = self;
        //订阅接收到topic
        self.sessionManager.subscriptions =
        @{
          @"topic1": @(MQTTQosLevelExactlyOnce),
          @"topic2": @(MQTTQosLevelExactlyOnce),
          @"topic3": @(MQTTQosLevelExactlyOnce),
          };
        //初始化MQTT
        [self.sessionManager connectTo:@"your host"
                                  port:6666 //@"your port"
                                   tls:NO
                             keepalive:60
                                 clean:YES
                                  auth:true //需要账号密码就设置为true
                                  user:@"user"
                                  pass:@"pass"
                                  will:NO
                             willTopic:nil
                               willMsg:nil
                               willQos:MQTTQosLevelExactlyOnce
                        willRetainFlag:NO
                          withClientId:[NSString stringWithFormat:@"iOS_%@", self.vendorIdentifier] //唯一标识符
                        securityPolicy:nil
                          certificates:nil
                         protocolLevel:MQTTProtocolVersion311
                        connectHandler:^(NSError *error) {
                            if (error) {
                                NSLog(@"sessionManager connectToBroker error: %@", error);
                            }
                        }];
    } else {
        [self.sessionManager connectToLast:^(NSError *error) {
            if (error) {
                NSLog(@"sessionManager connectToLast error: %@", error);
            }
        }];
    }
}

#pragma mark - <MQTTSessionManagerDelegate>
//输出连接状态信息
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    
    switch (newState) {
        case MQTTSessionManagerStateStarting:
            NSLog(@"MQTTSessionManager didChangeState:, MQTTSessionManagerStateStarting");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"MQTTSessionManager didChangeState:, MQTTSessionManagerStateConnecting");
            break;
        case MQTTSessionManagerStateError:
            NSLog(@"MQTTSessionManager didChangeState:, MQTTSessionManagerStateError");
            break;
        case MQTTSessionManagerStateConnected:
            NSLog(@"MQTTSessionManager didChangeState:, MQTTSessionManagerStateConnected");
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"MQTTSessionManager didChangeState:, MQTTSessionManagerStateClosing");
            break;
        case MQTTSessionManagerStateClosed:
            NSLog(@"MQTTSessionManager didChangeState:, MQTTSessionManagerStateClosed");
            break;
            
        default:
            break;
    }
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    
    //解除超时
    [self.timer invalidate];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    //判断请求结果是否符合需求(这要根据具体业务决定需不需要)
//    NSNumber *statusCode = json[@"status_code"];
//    if (statusCode.integerValue != 200) {
//        //返回错误的回调信息
//        if ([self.delegate respondsToSelector:@selector(sessionManagerDidFailureCode:errorMessage:onTopic:)]) {
//            [self.delegate sessionManagerDidFailureCode:statusCode.integerValue errorMessage:json[@"data"] onTopic:topic];
//        }
//        return ;
//    }
    
    //返回正确的回调信息
    if ([self.delegate respondsToSelector:@selector(sessionManager:didReceiveMessage:onTopic:)]) {
        [self.delegate sessionManager:sessionManager didReceiveMessage:json onTopic:topic];
    }
}


/** 发送消息(以发送json为例) **/
- (void)sendMsgWithJson:(NSDictionary *)json topic:(NSString *)topic {
    
    NSData *bodyJsonData = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
    
    [self.sessionManager sendData:bodyJsonData
                            topic:topic
                              qos:MQTTQosLevelExactlyOnce
                           retain:FALSE];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:20 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        //超时处理
    }];
}


@end
