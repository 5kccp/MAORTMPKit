//
//  AdobeAMF.h
//  RTMPTest
//
//  Created by Mao on 15/4/14.
//  Copyright (c) 2015年 AppGame. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, AdobeAMFDataType) {
    AdobeAMFDataTypeNumber = 0,
    AdobeAMFDataTypeBoolean,
    AdobeAMFDataTypeString,
    AdobeAMFDataTypeObject,
    AdobeAMFDataTypeMovieClip,		/* reserved, not used */
    AdobeAMFDataTypeNull,
    AdobeAMFDataTypeUndefined,
    AdobeAMFDataTypeReference,
    AdobeAMFDataTypeEMCAArray,
    AdobeAMFDataTypeObjectEnd,
    AdobeAMFDataTypeStrictArray,
    AdobeAMFDataTypeDate,
    AdobeAMFDataTypeLongString,
    AdobeAMFDataTypeUnsupported,
    AdobeAMFDataTypeRecordSet,		/* reserved, not used */
    AdobeAMFDataTypeXmlDoc,
    AdobeAMFDataTypeTypedObject,
    AdobeAMFDataTypeAvmPlus,		/* switch to AMF3 */
    AdobeAMFDataTypeInvalid = 0xff
};

@interface AdobeAMF : NSObject{
    NSMutableData *_rawData;
}
- (instancetype)initWithRawData:(NSData*)rawData;
- (void)addNumber:(double)number;
- (void)addBoolean:(BOOL)boolean;
- (void)addString:(NSString*)string;
- (void)addObject:(NSDictionary*)object;
- (NSData*)data;
@end
