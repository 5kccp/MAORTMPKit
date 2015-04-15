//
//  AdobeAMF.m
//  RTMPTest
//
//  Created by Mao on 15/4/14.
//  Copyright (c) 2015年 AppGame. All rights reserved.
//

#import "AdobeAMF.h"

@implementation AdobeAMF
- (instancetype)init
{
    self = [super init];
    if (self) {
        _rawData = [[NSMutableData alloc] init];
    }
    return self;
}
- (instancetype)initWithRawData:(NSData*)rawData{
    self = [super init];
    if (self) {
        _rawData = [[NSMutableData alloc] initWithData:rawData];
    }
    return self;
}
- (void)addNumber:(double)number{
    CFSwappedFloat64 tmp = CFConvertFloat64HostToSwapped(number);
    uint8_t type = AdobeAMFDataTypeNumber;
    [_rawData appendBytes:&type length:1];
    [_rawData appendBytes:&tmp length:8];
}
- (void)addBoolean:(BOOL)boolean{
    uint8_t type = AdobeAMFDataTypeBoolean;
    [_rawData appendBytes:&type length:1];
    uint8_t tmp = boolean;
    [_rawData appendBytes:&tmp length:1];
}
- (void)addString:(NSString*)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 0xFFFF) {
        uint8_t type = AdobeAMFDataTypeString;
        [_rawData appendBytes:&type length:1];
        uint16_t length = htons((uint16_t)data.length);
        [_rawData appendBytes:&length length:2];
    }else{
        uint8_t type = AdobeAMFDataTypeLongString;
        [_rawData appendBytes:&type length:1];
        uint32_t length = htonl((uint32_t)data.length);
        [_rawData appendBytes:&length length:4];
    }
    [_rawData appendData:data];
}
- (void)addObject:(NSDictionary*)object{
    uint8_t type1 = AdobeAMFDataTypeObject;
    [_rawData appendBytes:&type1 length:1];
    
    for (NSString *each in object.allKeys) {
        if ([each isKindOfClass:[NSString class]]) {
            NSObject *value = object[each];
            if ([value isKindOfClass:[NSString class]]) {
                NSString *s = (NSString*)value;
                [self addName:each];
                [self addString:s];
            }else if ([value isKindOfClass:[NSNumber class]]){
                [self addName:each];
                NSNumber *n = (NSNumber*)value;
                if (strcmp(n.objCType, @encode(BOOL))) {
                    [self addBoolean:n.boolValue];
                }else{
                    [self addNumber:n.doubleValue];
                }
            }
        }
    }
    uint16_t zero = 0;
    [_rawData appendBytes:&zero length:2];
    uint8_t type2 = AdobeAMFDataTypeObjectEnd;
    [_rawData appendBytes:&type2 length:1];
}
- (void)addName:(NSString*)name{
    NSData *data = [name dataUsingEncoding:NSUTF8StringEncoding];
    uint16_t length = htons((uint16_t)data.length);
    [_rawData appendBytes:&length length:2];
    [_rawData appendData:data];
}
- (NSData*)data{
    return _rawData;
}
@end
