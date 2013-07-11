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
        self.languages = [NSMutableArray array];
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
            
            [self.languages enumerateObjectsUsingBlock:^(ZFLangFile *obj, NSUInteger idx, BOOL *stop) {
                _hashKeys = [obj.translations valueForKey:@"key"];
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
    
    [self.languages addObject:lang];
    [self checkUpNameForLang:lang];
    
    self.allKeys = nil;
    self.allIdioms = nil;
    
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
    
    
    [self.languages addObjectsFromArray:file.languages];
    
    
    ZFLangFile *lastLang = [file.languages lastObject];
    [self checkUpNameForLang:lastLang];
    
    if (lastLang) {
        self.allKeys = nil;
        self.allIdioms = nil;
    }
    
    return (lastLang != nil);
}

/*!
 @abstract
 Fill the blanks in languages and translation keys
 
 @discussion Used to generate the getters for allKeys and allLanguages. Those two get constantly nilled by addFileAtURL and mergeWithFile, so they may become source of problems (dead loops in primis)
 
 */

- (void)fillGaps {
    NSMutableDictionary *uniqueLines = [NSMutableDictionary dictionary];
    NSMutableArray *allIdentifiers = [NSMutableArray array];
    __block NSInteger iOSLangCount, androidLangCount = 0;
    
    [self.languages enumerateObjectsUsingBlock:^(ZFLangFile *lang, NSUInteger idx, BOOL *stop) {
        if (![allIdentifiers containsObject:lang.idiom]) [allIdentifiers addObject:lang.idiom];
        [lang.translations enumerateObjectsUsingBlock:^(ZFTranslationLine *line, NSUInteger idx, BOOL *stop) {
            if ([uniqueLines objectForKey:line.key]) return;
            [uniqueLines setObject:line forKey:line.key];
        }];
        
        if (lang.type == ZFLangTypeIOS) iOSLangCount++;
        else androidLangCount++;
        
    }];
    
    [uniqueLines enumerateKeysAndObjectsUsingBlock:^(NSString *key, ZFTranslationLine *checkLine, BOOL *stop) {
        [self.languages enumerateObjectsUsingBlock:^(ZFLangFile *lang, NSUInteger idx, BOOL *stop) {
            ZFTranslationLine *line = [lang lineForKey:key];
            if (line) return;
            
            line = [checkLine copy];
            line.type = ZFTranslationLineTypeUntranslated;
            [lang addLine:line];
        }];
    
    }];
    
    
    if (iOSLangCount == 0 || androidLangCount == 0) self.conversionDriver = ZFTranslationFileConversionDriverSkip;
    else self.conversionDriver = (iOSLangCount >= androidLangCount)? ZFTranslationFileConversionDriverIOS : ZFTranslationFileConversionDriverAndorid;
    
    _allKeys = [uniqueLines.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    _allIdioms = [allIdentifiers sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if ([obj1 isEqualToString:FAV_LANG]) return NSOrderedAscending;
        else if ([obj2 isEqualToString:FAV_LANG]) return NSOrderedDescending;
        else return [obj1 compare:obj2];
    }];
}

- (NSArray *)allKeys {
    if (!_allKeys) [self fillGaps];
    return _allKeys;
}

- (NSArray *)allIdioms {
    if (!_allIdioms) [self fillGaps];
    return _allIdioms;
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
        NSString *dir = [NSString stringWithFormat:ZF_LANG_DIR_ANDROID_, referenceLangFile.idiom];
        NSString *name = [referenceLangFile.fileName stringByAppendingPathExtension:ZF_LANG_EXTENSION_ANDROID_];
        langFile.url = [[self.rootAndroidURL URLByAppendingPathComponent:dir] URLByAppendingPathComponent:name];
    }
    else {
        NSString *dir = [NSString stringWithFormat:ZF_LANG_DIR_IOS_, referenceLangFile.idiom];
        NSString *name = [referenceLangFile.fileName stringByAppendingPathExtension:ZF_LANG_EXTENSION_IOS_];
        langFile.url = [[self.rootIOSURL URLByAppendingPathComponent:dir] URLByAppendingPathComponent:name];
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:[langFile.url URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
}


/*!
 @abstract
 Perform the actual conversion from translations to files
 
 @param fromLang from which the translations are taken
 
 @param toLang to take the url of the file to write
 
 @param checkDirty set to YES to check if the toLang has keys to be converted to the fromLang
 
 @param error reference to the error
 
 @return BOOL if the process succeded or not
 
 @discussion The function writes to the toLAng file URL and if the checkDirty is set to YES will also the the difference in keys between fromLang and toLang in order to also get the fromLang up to date
 
 */


- (BOOL)writeFromLang:(ZFLangFile *)fromLang toLang:(ZFLangFile *)toLang checkDirty:(BOOL)checkDirty error:(NSError **)error{
    
    ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
    
    NSString *textOutput = (fromLang.type == ZFLangTypeIOS)? [converter xmlStringFromTranslations:fromLang.translations] : [converter stringsStringFromTranslations:fromLang.translations];

    BOOL succeded = [textOutput writeToURL:toLang.url atomically:YES encoding:NSUTF8StringEncoding error:error];
    
    if (!checkDirty) return succeded;
    
    if (fromLang.isDirty) {
        succeded = [self writeFromLang:toLang toLang:fromLang checkDirty:NO error:error];
    }

    return succeded;
}

/*!
 @abstract
 Takes all the translations and write the files accordingly to the driven option
 
 @return BOOL if the process succeded or not

 
 */

- (BOOL)writeAllTranslationsError:(NSError **)error {
    
    if (self.conversionDriver == ZFTranslationFileConversionDriverSkip) return NO;
    
    

    NSMutableDictionary *couplingLanguages = [NSMutableDictionary dictionary];
    
    [self.languages enumerateObjectsUsingBlock:^(ZFLangFile *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *files = [couplingLanguages objectForKey:obj.idiom];
        if (!files) files = [NSMutableDictionary dictionary];
        [files setObject:obj forKey:[NSNumber numberWithInt:obj.type]];
        [couplingLanguages setObject:files forKey:obj.idiom];
    }];
    
    __block BOOL succeded = YES;
    [couplingLanguages enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *files, BOOL *stop) {
        ZFLangFile *objIOS = [files objectForKey:[NSNumber numberWithInt:ZFLangTypeIOS]];
        ZFLangFile *objAndorid = [files objectForKey:[NSNumber numberWithInt:ZFLangTypeAndorid]];
        
        if (!objIOS && !objAndorid) return;
        
        if (!objIOS) {
            objIOS = [[ZFLangFile alloc] initWithCouplingLanguage:objAndorid];
            [self convertURLForLanguage:objIOS fromLangFile:objAndorid];
        }

        if (!objAndorid) {
            objAndorid = [[ZFLangFile alloc] initWithCouplingLanguage:objIOS];
            [self convertURLForLanguage:objAndorid fromLangFile:objIOS];
        }

        
        if (self.conversionDriver == ZFTranslationFileConversionDriverIOS) {
            succeded = [self writeFromLang:objIOS toLang:objAndorid checkDirty:YES error:error];
        }
        else {
            succeded = [self writeFromLang:objAndorid toLang:objIOS checkDirty:YES error:error];
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
 
 @discussion The type argument is compulsory amd setting it to 0 will trigger iOS results. To be ammended in the future.
 
 */

- (NSArray *)translationsByType:(ZFLangType)type andLanguageIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %d && idiom = %@", type, identifier];
    return [self.languages filteredArrayUsingPredicate:predicate];
}

@end
