//
//  ZFLangFile.h
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFTranslationLine.h"

typedef enum {
    ZFLangTypeIOS,
    ZFLangTypeAndorid
} ZFLangType;

@interface ZFLangFile : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, assign, readonly) ZFLangType type;
@property (nonatomic, strong, readonly) NSString *language;
@property (nonatomic, strong, readonly) NSArray *allKeys;
@property (nonatomic, strong, readonly) NSMutableArray *translations;
@property (nonatomic, assign, readonly) BOOL isDirty;

- (id)initWithURL:(NSURL *)url;
- (id)initWithCouplingLanguage:(ZFLangFile *)langfile;
- (ZFTranslationLine *)lineForKey:(NSString *)key;

- (void)addLine:(ZFTranslationLine *)line;

@end
