//
//  ZFLangFile.m
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFLangFile.h"
#import "ZFStringsConverter.h"
#import "Config.h"

@interface ZFLangFile ()

@property (nonatomic, strong) NSRegularExpression *iOSLangRegEx;
@property (nonatomic, strong) NSRegularExpression *androidLangRegEx;
@property (nonatomic, strong) NSRegularExpression *CSVLangRegEx;

@end

@implementation ZFLangFile

@synthesize allKeys = _allKeys;



#pragma mark Getters

- (NSRegularExpression *)iOSLangRegEx {
    if (!_iOSLangRegEx) {
        NSError *error = nil;
        _iOSLangRegEx = [[NSRegularExpression alloc] initWithPattern:ZF_LANG_DIR_IOS_REGEX options:0 error:&error];
    }
    return _iOSLangRegEx;
}

- (NSRegularExpression *)androidLangRegEx {
    if (!_androidLangRegEx) {
        NSError *error = nil;
        _androidLangRegEx = [[NSRegularExpression alloc] initWithPattern:ZF_LANG_DIR_ANDROID_REGEX options:0 error:&error];
    }
    return _androidLangRegEx;
}

- (NSRegularExpression *)CSVLangRegEx {
    if (!_CSVLangRegEx) {
        NSError *error = nil;
        _CSVLangRegEx = [[NSRegularExpression alloc] initWithPattern:ZF_LANG_CSV_REGEX options:0 error:&error];
    }
    return _CSVLangRegEx;
}

#pragma mark - Lang utils

/*!
 @abstract
 Checks the URL path for the language identifier and recognise if it's and iOS or Andorid path
 
 @param url, the url to be checked
 @param type, reference to the ZFLangType that will be found
 @return NSString with the language identifier. Ex: en, it, de, fr, es ...
 
 */


- (NSString *)langFromURL:(NSURL *)url ofType:(ZFLangType *)type {
    *type = ZFLangTypeIOS;
    NSArray *matches = [self.iOSLangRegEx matchesInString:url.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, url.absoluteString.length)];
    
    if (!matches || matches.count == 0) {
        matches = [self.androidLangRegEx matchesInString:url.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, url.absoluteString.length)];
        *type = ZFLangTypeAndorid;
    }
    if (!matches || matches.count == 0) {
        matches = [self.CSVLangRegEx matchesInString:url.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, url.absoluteString.length)];
        *type = ZFLangTypeCSV;
    }
    
    if (!matches || matches.count == 0) return nil;
    
    NSRange langMatchRange = [[matches objectAtIndex:0] rangeAtIndex:1];
    NSString *lang = [url.absoluteString substringWithRange:langMatchRange];
    
    return lang;
}



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
        ZFLangType type;
        NSString *lang = [self langFromURL:url ofType:&type];
        if (!lang) return nil;
        
        self.url = url;
        _fileName = [url lastPathComponent];
        _type = type;
        _idiom = lang;
        _isDirty = NO;
        
        ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
        NSArray *translations;
        switch (_type) {
            case ZFLangTypeIOS:
                translations = [converter translationsForStringsAtURL:url];
                break;
            case ZFLangTypeAndorid:
                translations = [converter translationsForXMLAtURL:url];
                break;
            case ZFLangTypeCSV:
                translations = [converter translationsFromCSVAtURL:url idiom:lang];
                break;
            default:
                break;
        }
        
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
        _idiom = langfile.idiom;
        _translations = [langfile.translations mutableCopy];
        _isDirty = YES;
    }
    return self;
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    _fileName = [_url lastPathComponent];
}

#pragma mark isEqual

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return [super isEqual:object];
    
    __block int count = 0;
    [self.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([[(ZFLangFile *)object allKeys] containsObject:obj]) count++;
        *stop = (count >= KEY_COMAPARISON);
    }];
    
    return (count >= MIN(KEY_COMAPARISON, self.allKeys.count));
}

#pragma  mark - keys


- (NSArray *)allKeys {
    if (!_allKeys) [self sortTranslations];
    return _allKeys;
}

- (ZFTranslationLine *)lineForKey:(NSString *)key {
    NSUInteger index = [self.allKeys indexOfObject:key];
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
    
    _allKeys = [self.translations valueForKey:@"key"];
    if (!_allKeys) _allKeys = [NSArray array];
    
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@ %d %@ %ld keys", self.fileName, self.type, self.idiom, (unsigned long)[self.allKeys count]];
}


@end
