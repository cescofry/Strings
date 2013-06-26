//
//  ZFLangFile.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFLangFile.h"
#import "ZFStringsConverter.h"
#import "ZFUtils.h"

#define FAV_LANG    @"en"

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

- (NSArray *)hashKeys {
    if (!_hashKeys) {
        
        NSDictionary *source = (self.iOStranslations.count > 0)? self.iOStranslations : self.androidTranslations;
        NSString *key = ([[source allKeys] containsObject:@"en"])? @"en" : [[source allKeys] lastObject];
        
        NSArray *keys = [[[source objectForKey:key] allKeys] sortedArrayUsingSelector:@selector(compare:)];
        _hashKeys = [keys subarrayWithRange:NSMakeRange(0, MIN(5, keys.count))];
    }
    return _hashKeys;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return [super isEqual:object];
    
    __block int count = 0;
    [self.hashKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([[(ZFLangFile *)object hashKeys] containsObject:obj]) count++;
        *stop = (count >= 3);
    }];
    
    return (count >= 3);
}


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
