//
//  RTMPChunk.h
//  RTMPTest
//
//  Created by Mao on 15/4/14.
//  Copyright (c) 2015年 AppGame. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, RTMPChunkType) {
    RTMPChunkType0 = 0x0,
    RTMPChunkType1 = 0x1,
    RTMPChunkType2 = 0x2,
    RTMPChunkType3 = 0x3
};

typedef NS_ENUM(uint8_t, RTMPMessageType) {
    RTMP_PT_CHUNK_SIZE   = 0x1,
    RTMP_PT_BYTES_READ   = 0x3,
    RTMP_PT_PING         = 0x4,
    RTMP_PT_SERVER_WINDOW= 0x5,
    RTMP_PT_PEER_BW      = 0x6,
    RTMP_PT_AUDIO        = 0x8,
    RTMP_PT_VIDEO        = 0x9,
    RTMP_PT_FLEX_STREAM  = 0xF,
    RTMP_PT_FLEX_OBJECT  = 0x10,
    RTMP_PT_FLEX_MESSAGE = 0x11,
    RTMP_PT_NOTIFY       = 0x12,
    RTMP_PT_SHARED_OBJ   = 0x13,
    RTMP_PT_INVOKE       = 0x14,
    RTMP_PT_METADATA     = 0x16,
};

@interface RTMPChunk : NSObject{
    NSMutableData *_rawData;
}
- (instancetype)initWithRawData:(NSData*)rawData;
@property (nonatomic, assign) RTMPChunkType chunkType;
@property (nonatomic, assign) uint16_t chunkStreamId;
@property (nonatomic, assign) uint32_t timeStamp;
@property (nonatomic, assign) uint32_t messageLegth;
@property (nonatomic, assign) uint8_t messageTypeId;
@property (nonatomic, assign) uint32_t messageStreamId;
@property (nonatomic, assign) uint32_t extendedTimeStamp;
@property (nonatomic, assign) NSData *chunkData;
- (NSData*)data;
@end

@interface RTMPChunk0 : RTMPChunk
- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId timeStamp:(uint32_t)timeStamp messageLength:(uint32_t)messageLegth messageTypeId:(uint8_t)messageTypeId messageStreamId:(uint32_t)messageStreamId extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData;
@end

@interface RTMPChunk1 : RTMPChunk
- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId timeStampDelta:(uint32_t)timeStampDelta messageLength:(uint32_t)messageLegth messageTypeId:(uint8_t)messageTypeId extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData;
@end

@interface RTMPChunk2 : RTMPChunk
- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId timeStampDelta:(uint32_t)timeStampDelta extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData;
@end

@interface RTMPChunk3 : RTMPChunk
- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId;
@end