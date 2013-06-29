//
//  ZFTranslationLine.m
//  Strings
//
//  Created by Francesco on 29/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFTranslationLine.h"

@implementation ZFTranslationLine

+(ZFTranslationLine *)line {
    ZFTranslationLine *line = [[ZFTranslationLine alloc] init];
    return line;
}

- (void)setValue:(NSString *)value {
    _value = value;
    self.type = ([_value rangeOfString:@"%"].location == NSNotFound)? ZFTranslationLineTypeString : ZFTranslationLineTypeFormattedString;
}

- (void)setType:(ZFTranslationLineType)type {
    _type = type;
    if (_type == ZFTranslationLineTypeComment && ![self.key hasPrefix:@"*"]) {
        self.key = [NSString stringWithFormat:@"*%@", self.key];
    }
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@"%@: %@", self.key, self.value];
}

@end
