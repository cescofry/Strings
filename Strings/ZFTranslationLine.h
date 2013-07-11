//
//  ZFTranslationLine.h
//  Strings
//
//  Created by Francesco on 29/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZFTranslationLineTypeUnknown,
    ZFTranslationLineTypeString,
    ZFTranslationLineTypeFormattedString,
    ZFTranslationLineTypeComment,
    ZFTranslationLineTypeUntranslated
}ZFTranslationLineType;

@interface ZFTranslationLine : NSObject <NSCopying>

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) ZFTranslationLineType type;
@property (nonatomic, assign) NSUInteger position;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSArray *comments;

+(ZFTranslationLine *)line;

@end
