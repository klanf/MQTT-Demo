//
//  FCMQTTManager.h
//  AGV
//
//  Created by jaime on 2019/4/29.
//  Copyright © 2019 qinghua.ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MQTTSessionManager;

@protocol FCMQTTManagerDelegate <NSObject>

@required
- (void)sessionManager:(MQTTSessionManager *_Nonnull)sessionManager didReceiveMessage:(NSDictionary *_Nullable)massage onTopic:(NSString *_Nonnull)topic;
@optional
- (void)sessionManagerDidFailureCode:(NSInteger)errorCode errorMessage:(NSDictionary *_Nullable)massage onTopic:(NSString *_Nonnull)topic;

@end
NS_ASSUME_NONNULL_BEGIN
@interface FCMQTTManager : NSObject

@property (nonatomic ,weak) id<FCMQTTManagerDelegate>delegate;

+ (FCMQTTManager *)sharedManager;

- (void)connectToBroker; //可以在AppDelegate里调用

/** 发送消息(以发送json为例) **/
- (void)sendMsgWithJson:(NSDictionary *)json topic:(NSString *)topic;

@end

NS_ASSUME_NONNULL_END
