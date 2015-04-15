//
//  RTMPClient.m
//  RTMPTest
//
//  Created by Mao on 15/4/13.
//  Copyright (c) 2015年 AppGame. All rights reserved.
//

#import "RTMPClient.h"
#import "GCDAsyncSocket.h"
#import "AdobeAMF.h"
#import "RTMPChunk.h"

@interface RTMPClient()<GCDAsyncSocketDelegate>
@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* application;
@property (nonatomic, copy) NSString* stream;
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, assign) long int dataTag;
@property (nonatomic, strong) NSData *s0;
@property (nonatomic, strong) NSData *s1;
@property (nonatomic, strong) NSData *s2;
@property (nonatomic, strong) NSData *connectResultData;
@end
@implementation RTMPClient
- (instancetype)initWithHost:(NSString*)host application:(NSString*)application stream:(NSString*)stream{
    self = [self init];
    if (self) {
        _host        = host;
        _application = application;
        _stream      = stream;
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}
- (NSString*)tcUrl{
    return [NSString stringWithFormat:@"rtmp://%@/%@", self.host, self.application];
}
- (void)connect{
    if (!_asyncSocket.isConnected) {
        NSError *error;
        if (![_asyncSocket connectToHost:self.host onPort:1935 error:&error]) {
            NSLog(@"%@", error);
        }
    }
}
- (void)sendData:(NSData*)data{
    
}
-(void)disconnect{
    
}
- (void)startHandShake{
    [self handShake0];
}
- (void)handShake0{
    uint8_t c = 0x03;
    NSData *c0 = [NSData dataWithBytes:&c length:1];
    [_asyncSocket writeData:c0 withTimeout:-1 tag:0];
    NSLog(@"hand shake 0:%@", c0);
    [self handShake1];
}
- (void)handShake1{
    NSMutableData *c1 = [NSMutableData data];
    uint64_t zero = 0;
    [c1 appendBytes:&zero length:8];
    for (NSInteger i = 0; i < 1528; ++i) {
        char c = 0;
        [c1 appendBytes:&c length:1];
    }
    [_asyncSocket writeData:c1 withTimeout:-1 tag:0];
    [_asyncSocket readDataToLength:1 withTimeout:-1 tag:0];
    [_asyncSocket readDataToLength:1536 withTimeout:-1 tag:0];
    NSLog(@"hand shake 1:%@", c1);
}
- (void)handShake2{
    NSMutableData *c2 = [NSMutableData data];
    char *time = (char*)self.s1.bytes;
    [c2 appendBytes:time length:4];
    uint32_t zero = 0;
    [c2 appendBytes:&zero length:4];
    NSData *echoData = [self.s1 subdataWithRange:NSMakeRange(8, self.s1.length-8)];
    [c2 appendData:echoData];
    [_asyncSocket writeData:c2 withTimeout:-1 tag:0];
    [_asyncSocket readDataToLength:1536 withTimeout:-1 tag:0];
    NSLog(@"hand shake 2:%@", c2);
}
- (void)sendConnectPacket{
    AdobeAMF *amf = [[AdobeAMF alloc] init];
    [amf addString:@"connect"];
    [amf addNumber:1.];
    [amf addObject:@{@"app":self.application,@"type":@"nonprivate",@"tcUrl":[self tcUrl]}];
    uint32_t timeStamp = {0};
    uint32_t messageLength = {(int)amf.data.length};
    RTMPChunk0 *chunk0 = [[RTMPChunk0 alloc] initWithChunkStreamId:3 timeStamp:timeStamp messageLength:messageLength messageTypeId:RTMP_PT_INVOKE messageStreamId:0 extendediTimeStamp:0 chunkData:amf.data];
    [_asyncSocket writeData:chunk0.data withTimeout:-1 tag:0];
    [_asyncSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"%@", chunk0.data);
}
- (void)sendReleaseStream{
    
}
- (void)sendFCPublish{
    
}
- (void)sendCreateStream{
    
}
- (void)sendPublish{
    
}
#pragma mark - GCDAsyncSocketDelegate

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%@ %d", host, port);
    [self startHandShake];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"received:%@", data);
    if (!self.s0) {
        self.s0 = data;
        
        if (self.s0.length == 1 ) {
            char *c = (char*)self.s0.bytes;
            if (c[0] != 0x03) {
                NSLog(@"error s0");
            }
            
        }
    }else if (!self.s1){
        self.s1 = data;
        if (self.s1.length == 1536) {
            [self handShake2];
        }
    }else if (!self.s2){
        self.s2 = data;
        if (self.s2.length == 1536) {
            NSLog(@"握手成功");
            [self sendConnectPacket];
        }
    }else if (!self.connectResultData){
        self.connectResultData = data;
        RTMPChunk *chunk = [[RTMPChunk alloc] initWithRawData:self.connectResultData];
    }
    
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"writed");
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}


/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%@", err);
}
@end
