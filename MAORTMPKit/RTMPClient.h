//
//  RTMPClient.h
//  RTMPTest
//
//  Created by Mao on 15/4/13.
//  Copyright (c) 2015年 AppGame. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RTMPClient : NSObject
- (instancetype)initWithHost:(NSString*)host application:(NSString*)application stream:(NSString*)stream;
- (void)connect;
- (void)sendData:(NSData*)data;
-(void)disconnect;
@end
