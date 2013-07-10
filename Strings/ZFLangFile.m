//
//  ZFLangFile.m
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFLangFile.h"
#import "ZFStringsConverter.h"

@interface ZFLangFile ()

@property (nonatomic, strong) NSArray *keysAndComments;

@end

@implementation ZFLangFile

@synthesize allKeys = _allKeys;


/*!
 @abstract
 Preferred method to convert a file at URL to ZFLangFile
 
 @param url of the file in the disk
 
 @return YES if the operation of adding result succesfull No otherwise
 
 @discussion This method covnert the url in a dictioanry of keys and transaltions to be addedd to the translations for the relative language identifier
 
 */

- (id)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        BOOL isIOS;
        NSString *lang = [[ZFUtils sharedUtils] langFromURL:url isIOS:&isIOS];
        if (!lang) return nil;
        
        self.url = url;
        _fileName = [url lastPathComponent];
        _type = (isIOS)? ZFLangTypeIOS : ZFLangTypeAndorid;
        _language = lang;
        _isDirty = NO;
        
        ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
        NSArray *translations = (isIOS)? [converter translationsForStringsAtURL:url] : [converter translationsForXMLAtURL:url];
        
        _translations = [NSMutableArray arrayWithArray:translations];
        [self sortTranslations];
    }
    return self;

}

/*!
 @abstract
 Generate Lang file as opposite of the given one
 
 @param langFile the langfile to opposite copy
 
 @return instance of the lang file
 
 @discussion Used before converting a file from one ty to the other, as a reference of an existing file needs to exists
 
 */

- (id)initWithCouplingLanguage:(ZFLangFile *)langfile {
    self = [self init];
    if (self) {
        _type = (langfile.type == ZFLangTypeIOS)? ZFLangTypeAndorid : ZFLangTypeIOS;
        _language = langfile.language;
        _translations = [langfile.translations copy];
        _isDirty = YES;
    }
    return self;
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    _fileName = [_url lastPathComponent];
}

#pragma  mark - keys


- (NSArray *)keysAndComments {
    if (!_keysAndComments) [self sortTranslations];
    return _keysAndComments;
}

- (NSArray *)allKeys {
    if (!_allKeys) [self sortTranslations];
    return _allKeys;
}

- (ZFTranslationLine *)lineForKey:(NSString *)key {
    NSUInteger index = [self.keysAndComments indexOfObject:key];
    if (index == NSNotFound) return nil;
    return [self.translations objectAtIndex:index];
}



- (void)addLine:(ZFTranslationLine *)line {
    
    ZFTranslationLine *aline = [self lineForKey:line.key];
    if (aline) return;
    
    [self.translations addObject:line];
    _isDirty = YES;
    
    [self sortTranslations];
}

- (void)sortTranslations {
    if (!self.translations || self.translations.count == 0) return;
    
    [self.translations sortUsingComparator:^NSComparisonResult(ZFTranslationLine *obj1, ZFTranslationLine *obj2) {
        if (obj1.range.location == obj2.range.location) return NSOrderedSame;
        else return (obj1.range.location < obj2.range.location)? NSOrderedAscending : NSOrderedDescending;
    }];
    
    _keysAndComments = [self.translations valueForKey:@"key"];
    if (!_keysAndComments) _keysAndComments = [NSArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type != %d", ZFTranslationLineTypeComment];
    _allKeys = [[self.translations filteredArrayUsingPredicate:predicate] valueForKey:@"key"];
    if (!_allKeys) _allKeys = [NSArray array];
    
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@ %d %@ %ld keys", self.fileName, self.type, self.language, (unsigned long)[self.allKeys count]];
}


@end
