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
#import "ZFStringsConverter.h"
#import "ZFUtils.h"
#import "Config.h"

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
    
    switch (langFile.type) {
        case ZFLangTypeIOS:
            if (!self.iOSName) {
                self.iOSName = langFile.fileName;
                _rootIOSURL = [[langFile.url URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
            }
            break;
        case ZFLangTypeAndorid:
            if (!self.androidName) {
                self.androidName = langFile.fileName;
                _rootAndroidURL = [[langFile.url URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
            }
            break;
        default:
            break;
    }

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
    __block NSInteger iOSLangCount, androidLangCount = 0;
    
    [self.translations enumerateObjectsUsingBlock:^(ZFLangFile *lang, NSUInteger idx, BOOL *stop) {
        if (![allLanguages containsObject:lang.language]) [allLanguages addObject:lang.language];
        [lang.translations.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([allKeys containsObject:key]) return;
            [allKeys addObject:key];
        }];
        
        if (lang.type == ZFLangTypeIOS) iOSLangCount++;
        else androidLangCount++;
        
    }];
    
    if (iOSLangCount == 0 || androidLangCount == 0) self.conversionDriver = ZFTranslationFileConversionDriverSkip;
    else self.conversionDriver = (iOSLangCount >= androidLangCount)? ZFTranslationFileConversionDriverIOS : ZFTranslationFileConversionDriverAndorid;
    
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


#pragma mark - writing 

/*!
 @abstract
 Generate the missing file URL extrapolated form the reference file
 
 @param langFile the receiving file to be chnaged
 
 @param referenceLangFile reference to generate the url
 
 */

- (void)convertURLForLanguage:(ZFLangFile *)langFile fromLangFile:(ZFLangFile *)referenceLangFile {
    if (langFile.url) return;
    
    if (referenceLangFile.type == ZFLangTypeIOS) {
        NSString *dir = [NSString stringWithFormat:ZF_LANG_DIR_ANDROID_, referenceLangFile.language];
        NSString *name = [referenceLangFile.fileName stringByAppendingPathExtension:ZF_LANG_EXTENSION_ANDROID_];
        langFile.url = [[self.rootAndroidURL URLByAppendingPathComponent:dir] URLByAppendingPathComponent:name];
    }
    else {
        NSString *dir = [NSString stringWithFormat:ZF_LANG_DIR_IOS_, referenceLangFile.language];
        NSString *name = [referenceLangFile.fileName stringByAppendingPathExtension:ZF_LANG_EXTENSION_IOS_];
        langFile.url = [[self.rootIOSURL URLByAppendingPathComponent:dir] URLByAppendingPathComponent:name];
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:[langFile.url URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
}

/*!
 @abstract
 Takes all the translations and write the files accordingly to the driven option
 
 @return BOOL if the process succeded or not
 
 @discussion At the moment the process is only generating the non-driven file. However this is wrong. Because the list of transaltion is merged between iOS and Android, and the driven file would not receive the new keys.
 
 */

- (BOOL)writeAllTranslations {
    
    if (self.conversionDriver == ZFTranslationFileConversionDriverSkip) return NO;
    
    ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];

    NSMutableDictionary *couplingLanguages = [NSMutableDictionary dictionary];
    [self.translations enumerateObjectsUsingBlock:^(ZFLangFile *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *files = [couplingLanguages objectForKey:obj.language];
        if (!files) files = [NSMutableDictionary dictionary];
        [files setObject:obj forKey:[NSNumber numberWithInt:obj.type]];
        [couplingLanguages setObject:files forKey:obj.language];
    }];
    
    __block BOOL succeded = YES;
    [couplingLanguages enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *files, BOOL *stop) {
        ZFLangFile *objIOS = [files objectForKey:[NSNumber numberWithInt:ZFLangTypeIOS]];
        ZFLangFile *objAndorid = [files objectForKey:[NSNumber numberWithInt:ZFLangTypeAndorid]];
        
        if (!objIOS && objAndorid) {
            objIOS = [[ZFLangFile alloc] init];
            [self convertURLForLanguage:objIOS fromLangFile:objAndorid];
        }
        if (!objAndorid && objIOS) {
            objAndorid = [[ZFLangFile alloc] init];
            [self convertURLForLanguage:objAndorid fromLangFile:objIOS];
        }

        NSError *error = nil;
        
        if (self.conversionDriver == ZFTranslationFileConversionDriverIOS) {
            NSString *textOutput = [converter xmlStringFromDictionary:objIOS.translations];
            [textOutput writeToURL:objAndorid.url atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        else {
            NSString *textOutput = [converter stringsStringFromDictionary:objAndorid.translations];
            [textOutput writeToURL:objIOS.url atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        if (error) {
            succeded = NO;
            NSLog(@"Error: %@", error.debugDescription);
        }
        
    }];
    
    return succeded;
}



#pragma mark - sorting

/*!
 @abstract
 sorted array of languages by type and language identifier
 
 @param type to be searched. Must not be ignored
 
 @param identifier to be searched. Can be nil
 
 @return NSArray of translations
 
 @discussion The tye argument is compulsory amd setting it to 0 will trigger iOS results. To be ammended in the future.
 
 */

- (NSArray *)translationsByType:(ZFLangType)type andLanguageIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %d && language = %@", type, identifier];
    return [self.translations filteredArrayUsingPredicate:predicate];
}

@end
