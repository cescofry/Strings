//
//  ZFLangFile.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import <Foundation/Foundation.h>
#import "ZFLangFile.h"

typedef enum {
    ZFTranslationFileConversionDriverSkip,
    ZFTranslationFileConversionDriverIOS,
    ZFTranslationFileConversionDriverAndorid
}  ZFTranslationFileConversionDriver;

@interface ZFTranslationFile : NSObject

@property (nonatomic, assign) ZFTranslationFileConversionDriver conversionDriver;

@property (nonatomic, strong) NSString *iOSName;
@property (nonatomic, strong) NSString *androidName;

@property (nonatomic, strong) NSMutableArray *translations;

@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) NSArray *allLanguages;

- (BOOL)addFileAtURL:(NSURL *) url;
- (BOOL)mergeWithFile:(ZFTranslationFile *)file;
- (void)finalizeMerge;

- (NSArray *)translationsByType:(ZFLangType)type andLanguageIdentifier:(NSString *)identifier;

@end
