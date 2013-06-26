//
//  ZFLangFile.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFLangFile : NSObject

@property (nonatomic, strong) NSString *iOSName;
@property (nonatomic, strong) NSString *androidName;

@property (nonatomic, strong) NSMutableDictionary *iOStranslations;
@property (nonatomic, strong) NSMutableDictionary *androidTranslations;

@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) NSArray *allLanguages;

- (BOOL)addFileAtURL:(NSURL *) url;
- (BOOL)mergeWithFile:(ZFLangFile *)file;
- (void)finalizeMerge;

@end
