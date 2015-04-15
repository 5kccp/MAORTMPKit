//
//  RTMPChunk.m
//  RTMPTest
//
//  Created by Mao on 15/4/14.
//  Copyright (c) 2015年 AppGame. All rights reserved.
//

#import "RTMPChunk.h"

@implementation RTMPChunk
- (instancetype)initWithRawData:(NSData*)rawData{
    if (rawData.length) {
        uint8_t *bytes = (uint8_t*)rawData.bytes;
        uint8_t firstByte = bytes[0];
        uint8_t headerType = (firstByte & 0xC0) >> 6;
        switch (headerType) {
            case RTMPChunkType0:
                return [[RTMPChunk0 alloc] initWithRawData:rawData];
                break;
            case RTMPChunkType1:
                return [[RTMPChunk1 alloc] initWithRawData:rawData];
                break;
            case RTMPChunkType2:
                return [[RTMPChunk2 alloc] initWithRawData:rawData];
                break;
            case RTMPChunkType3:
                return [[RTMPChunk3 alloc] initWithRawData:rawData];
                break;
            default:
                break;
        }
    }
    return nil;
}
- (NSData*)data{
    return nil;
}
@end

@implementation RTMPChunk0
- (instancetype)initWithRawData:(NSData*)rawData{
    self = [super init];
    if (self) {
        
        uint8_t *bytes = (uint8_t*)rawData.bytes;
        uint8_t firstByte = bytes[0];
        uint8_t chunkStreamIdType = firstByte & 0x3F;
        self.chunkType = RTMPChunkType0;
        if (chunkStreamIdType == 0) { //2字节
            uint8_t sencodeByte = bytes[1];
            self.chunkStreamId = sencodeByte + 64;
            bytes+=2;
        }else if(chunkStreamIdType == 1){//3字节
            uint8_t sencodeByte = bytes[1];
            uint8_t thirdByte = bytes[2];
            self.chunkStreamId = thirdByte * 256 + sencodeByte + 64;
            bytes+=3;
        }else{//1字节
            self.chunkStreamId = chunkStreamIdType;
            bytes++;
        }
        uint32_t timeStamp = 0;
        memcpy(&timeStamp, bytes, 3);
        bytes+=3;
        uint32_t messageLength = 0;
        memcpy(&messageLength, bytes, 3);
        bytes+=3;
        uint8_t messageTypeId = 0;
        memcpy(&messageTypeId, bytes, 1);
        bytes++;
        uint32_t messageStreamId = 0;
        memcpy(&messageStreamId, bytes, 4);
        bytes+=4;
        if (timeStamp == 0xFFFFFF) {
            uint32_t extendedTimeStamp = 0;
            memcpy(&extendedTimeStamp, bytes, 4);
            bytes+=4;
        }
        self.chunkData = [NSData dataWithBytes:bytes length:messageLength];
    }
    return self;
}
- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId timeStamp:(uint32_t)timeStamp messageLength:(uint32_t)messageLegth messageTypeId:(uint8_t)messageTypeId messageStreamId:(uint32_t)messageStreamId extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData{
    self = [super init];
    if (self) {
        self.chunkType = RTMPChunkType0;
        self.chunkStreamId = chunkStreamId;
        _rawData = [[NSMutableData alloc] init];
        if (chunkStreamId > 2 && chunkStreamId < 64) {
            uint8_t chunkBasicHeader = chunkStreamId;
            [_rawData appendBytes:&chunkBasicHeader length:1];
        }else if (chunkStreamId > 63 && chunkStreamId < 320){
            uint16_t chunkBasicHeader = chunkStreamId - 64;
            chunkBasicHeader = htons(chunkBasicHeader);
            [_rawData appendBytes:&chunkBasicHeader length:2];
        }else if (chunkStreamId > 63 && chunkStreamId < 320){
            uint32_t chunkBasicHeader = 0x010000 + chunkStreamId - 64;
            chunkBasicHeader = htonl(chunkBasicHeader);
            chunkBasicHeader = chunkBasicHeader >> 8;
            [_rawData appendBytes:&chunkBasicHeader length:3];
        }
        self.timeStamp = timeStamp;
        uint32_t bigEndianTimeStamp = htonl(timeStamp);
        bigEndianTimeStamp = bigEndianTimeStamp >> 8;
        [_rawData appendBytes:&bigEndianTimeStamp length:3];
        if (timeStamp == 0xFFFFFF) {
            self.extendedTimeStamp = extendedTimeStamp;
        }
        self.messageLegth = messageLegth;
        uint32_t bigEndianMessageLength = htonl(messageLegth);
        bigEndianMessageLength = bigEndianMessageLength >> 8;
        [_rawData appendBytes:&bigEndianMessageLength length:3];
        self.messageTypeId = messageTypeId;
        [_rawData appendBytes:&messageTypeId length:1];
        self.messageStreamId = messageStreamId;
        uint32_t bigEndianMessageStreamId = htonl(messageStreamId);
        bigEndianMessageStreamId = bigEndianMessageStreamId >> 8;
        [_rawData appendBytes:&bigEndianMessageStreamId length:4];
        if (self.extendedTimeStamp > 0) {
            uint32_t bigEndianExtendedTimeStamp = htonl(extendedTimeStamp);
            bigEndianExtendedTimeStamp = bigEndianExtendedTimeStamp >> 8;
            [_rawData appendBytes:&bigEndianExtendedTimeStamp length:4];
        }
        self.chunkData = chunkData;
        [_rawData appendData:chunkData];
    }
    return self;
}
- (NSData*)data{
    return _rawData;
}
@end

@implementation RTMPChunk1

- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId timeStampDelta:(uint32_t)timeStampDelta messageLength:(uint32_t)messageLegth messageTypeId:(uint8_t)messageTypeId extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData{
    return self;
}
- (NSData*)data{
    return nil;
}
@end

@implementation RTMPChunk2

- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId timeStampDelta:(uint32_t)timeStampDelta extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData{
    return self;
}
- (NSData*)data{
    return nil;
}
@end

@implementation RTMPChunk3

- (instancetype)initWithChunkStreamId:(uint16_t)chunkStreamId extendediTimeStamp:(uint32_t)extendedTimeStamp chunkData:(NSData*)chunkData{
    return self;
}
- (NSData*)data{
    return nil;
}
@end
