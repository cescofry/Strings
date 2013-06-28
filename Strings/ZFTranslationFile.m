//
//  ZFLangFile.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFTranslationFile.h"
#import "ZFLangFile.h"
#import "ZFUtils.h"

#define FAV_LANG            @"en"
#define KEY_COMAPARISON      5

@interface ZFTranslationFile ()

@property (nonatomic, strong) NSArray *hashKeys;

@end


@implementation ZFTranslationFile

- (id)init {
    self = [super init];
    if (self) {
        self.translations = [NSMutableArray array];
        self.conversionDriver = ZFTranslationFileConversionDriverSkip;
    }
    return self;
}


/*!
 @abstract
 Generate a list of minimum 5 keys to be used for comparison
 
 @return NSArray of keys
 
 @discussion The method will first look at allKeys, then if missing or too small, will try to get them from either iOStranslation or androidTRanslations.
 
 */

- (NSArray *)hashKeys {
    if (!_hashKeys) {
        
        _hashKeys = [self allKeys];
        if (!_hashKeys || _hashKeys.count < KEY_COMAPARISON) {
                        
            [self.translations enumerateObjectsUsingBlock:^(ZFLangFile *obj, NSUInteger idx, BOOL *stop) {
                _hashKeys = obj.translations.allKeys;
                *stop = (_hashKeys.count >= KEY_COMAPARISON);
            }];
            
            _hashKeys = [_hashKeys subarrayWithRange:NSMakeRange(0, MIN(KEY_COMAPARISON, _hashKeys.count))];
        }
        
    }
    return _hashKeys;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return [super isEqual:object];
    
    __block int count = 0;
    [self.hashKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([[(ZFTranslationFile *)object hashKeys] containsObject:obj]) count++;
        *stop = (count >= KEY_COMAPARISON);
    }];
    
    return (count >= MIN(KEY_COMAPARISON, self.hashKeys.count));
}


/*!
 @abstract
 check lang file to add to the names
 
 @param langFile to be analized
 
 */

- (void)checkUpNameForLang:(ZFLangFile *)langFile {
    if (!langFile) return;
    if ((langFile.type == ZFLangTypeIOS) && !self.iOSName) self.iOSName = langFile.fileName;
    if ((langFile.type == ZFLangTypeAndorid) && !self.androidName) self.androidName = langFile.fileName;
    
    if (self.conversionDriver == ZFTranslationFileConversionDriverSkip) self.conversionDriver = (self.iOSName)? ZFTranslationFileConversionDriverIOS : ZFTranslationFileConversionDriverAndorid;
}


/*!
 @abstract
 Preferred method to convert a file at URL to ZFLangFile
 
 @param url of the file in the disk
 
 @return YES if the operation of adding result succesfull No otherwise
 
 @discussion This method covnert the url in a dictioanry of keys and transaltions to be addedd to the translations for the relative language identifier
 
 */

- (BOOL)addFileAtURL:(NSURL *)url {
    
    ZFLangFile *lang = [[ZFLangFile alloc] initWithURL:url];
    if (!lang) return NO;
    
    [self.translations addObject:lang];
    [self checkUpNameForLang:lang];
    
    self.allKeys = nil;
    self.allLanguages = nil;
    
    return YES;
}

/*!
 @abstract
 Tries to merge a given file if and only if the there is amtch between the keys
 
 @param file, the fiel to be merged
 
 @return YES if the file have been merged, NO otherwise
 
 @discussion The act of cross reference the keys and then merging the languages and the translations is expensive. Maybe need refactoring
 
 */

- (BOOL)mergeWithFile:(ZFTranslationFile *)file {
    if (![self isEqual:file]) return NO;
    
    [self.translations addObjectsFromArray:file.translations];
    
    ZFLangFile *lastLang = [file.translations lastObject];
    [self checkUpNameForLang:lastLang];
    
    if (lastLang) {
        self.allKeys = nil;
        self.allLanguages = nil;
    }
    
    return (lastLang != nil);
}

/*!
 @abstract
 Fill the blanks in languages and translation keys
 
 @discussion Used to generate the getters for allKeys and allLanguages. Those two get constantly nilled by addFileAtURL and mergeWithFile, so they may become source of problems (dead loops in primis)
 
 */

- (void)fillGaps {
    NSMutableArray *allKeys = [NSMutableArray array];
    NSMutableArray *allLanguages = [NSMutableArray array];
    
    [self.translations enumerateObjectsUsingBlock:^(ZFLangFile *lang, NSUInteger idx, BOOL *stop) {
        if (![allLanguages containsObject:lang.language]) [allLanguages addObject:lang.language];
        [lang.translations.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([allKeys containsObject:key]) return;
            [allKeys addObject:key];
        }];
    }];
    
    _allKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    _allLanguages = [allLanguages sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if ([obj1 isEqualToString:FAV_LANG]) return NSOrderedAscending;
        else if ([obj2 isEqualToString:FAV_LANG]) return NSOrderedDescending;
        else return [obj1 compare:obj2];
    }];
}

- (NSArray *)allKeys {
    if (!_allKeys) [self fillGaps];
    return _allKeys;
}

- (NSArray *)allLanguages {
    if (!_allLanguages) [self fillGaps];
    return _allLanguages;
}



- (NSArray *)translationsByType:(ZFLangType)type andLanguageIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %d && language = %@", type, identifier];
    return [self.translations filteredArrayUsingPredicate:predicate];
}

@end
