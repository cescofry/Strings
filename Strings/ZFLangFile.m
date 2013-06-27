//
//  ZFLangFile.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFLangFile.h"
#import "ZFStringsConverter.h"
#import "ZFUtils.h"

#define FAV_LANG            @"en"
#define KEY_COMAPARISON      5

@interface ZFLangFile ()

@property (nonatomic, strong) NSArray *hashKeys;

@end


@implementation ZFLangFile

- (id)init {
    self = [super init];
    if (self) {
        self.iOStranslations = [NSMutableDictionary dictionary];
        self.androidTranslations = [NSMutableDictionary dictionary];
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
            NSDictionary *source = (self.iOStranslations.count > 0)? self.iOStranslations : self.androidTranslations;
            NSString *key = ([[source allKeys] containsObject:@"en"])? @"en" : [[source allKeys] lastObject];
            
            NSArray *keys = [[[source objectForKey:key] allKeys] sortedArrayUsingSelector:@selector(compare:)];
            _hashKeys = [keys subarrayWithRange:NSMakeRange(0, MIN(KEY_COMAPARISON, keys.count))];
        }
        
    }
    return _hashKeys;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return [super isEqual:object];
    
    __block int count = 0;
    [self.hashKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([[(ZFLangFile *)object hashKeys] containsObject:obj]) count++;
        *stop = (count >= KEY_COMAPARISON);
    }];
    
    return (count >= MIN(KEY_COMAPARISON, self.hashKeys.count));
}


/*!
 @abstract
 Preferred method to convert a file at URL to ZFLangFile
 
 @param url of the file in the disk
 
 @return YES if the operation of adding result succesfull No otherwise
 
 @discussion This method covnert the url in a dictioanry of keys and transaltions to be addedd to the translations for the relative language identifier
 
 */

- (BOOL)addFileAtURL:(NSURL *)url {
    BOOL isIOS;
    NSString *lang = [[ZFUtils sharedUtils] langFromURL:url isIOS:&isIOS];
    if (!lang) return NO;
    
    BOOL alreadyExists = (isIOS)? ([self.iOStranslations objectForKey:lang] != nil) : ([self.androidTranslations objectForKey:lang] != nil);
    if (alreadyExists) return NO;
    
    if (isIOS && !self.iOSName) self.iOSName = [url lastPathComponent];
    if (!isIOS && !self.androidName) self.androidName = [url lastPathComponent];
    
    ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
    NSDictionary *translations = (isIOS)? [converter translationsForStringsAtURL:url] : [converter translationsForXMLAtURL:url];
    if (!translations || translations.count == 0) return NO;
    if (isIOS) {
        [self.iOStranslations setObject:translations forKey:lang];
    }
    else {
        [self.androidTranslations setObject:translations forKey:lang];
    }
    
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

- (BOOL)mergeWithFile:(ZFLangFile *)file {
    if (![self isEqual:file]) return NO;
    
    __block BOOL mergeIOS = NO;
    [file.iOStranslations enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if ([self.iOStranslations.allKeys containsObject:key]) return;
        
        [self.iOStranslations setObject:obj forKey:key];
        mergeIOS = YES;
    }];
    
    __block BOOL mergeAndroid = NO;
    [file.androidTranslations enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if ([self.androidTranslations.allKeys containsObject:key]) return;
        
        [self.androidTranslations setObject:obj forKey:key];
        mergeAndroid = YES;
    }];
    
    BOOL didMerge = (mergeIOS || mergeAndroid);
    if (didMerge) {
        self.allKeys = nil;
        self.allLanguages = nil;
    }
    return didMerge;
}

/*!
 @abstract
 Fill the blanks in languages and translation keys
 
 @discussion Used to generate the getters for allKeys and allLanguages. Those two get constantly nilled by addFileAtURL and mergeWithFile, so they may become source of problems (dead loops in primis)
 
 */

- (void)fillGaps {
    NSMutableArray *allKeys = [NSMutableArray array];
    NSMutableArray *allLanguages = [NSMutableArray array];
    
    [self.iOStranslations enumerateKeysAndObjectsUsingBlock:^(NSString *lang, NSDictionary *translation, BOOL *stop) {
        if (![allLanguages containsObject:lang]) [allLanguages addObject:lang];
        [translation.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([allKeys containsObject:key]) return;
            [allKeys addObject:key];
        }];
    }];
    
    [self.androidTranslations enumerateKeysAndObjectsUsingBlock:^(NSString *lang, NSDictionary *translation, BOOL *stop) {
        if (![allLanguages containsObject:lang]) [allLanguages addObject:lang];
        [translation.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
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

@end
