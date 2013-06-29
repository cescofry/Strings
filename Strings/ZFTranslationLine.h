//
//  ZFTranslationLine.h
//  Strings
//
//  Created by Francesco on 29/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZFTranslationLineTypeString,
    ZFTranslationLineTypeFormattedString,
    ZFTranslationLineTypeComment
}ZFTranslationLineType;

@interface ZFTranslationLine : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) ZFTranslationLineType type;
@property (nonatomic, assign) NSUInteger position;

+(ZFTranslationLine *)line;

@end
