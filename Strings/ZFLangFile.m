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
        
        _url = url;
        _fileName = [url lastPathComponent];
        _type = (isIOS)? ZFLangTypeIOS : ZFLangTypeAndorid;
        _language = lang;
        
        ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
        NSArray *translations = (isIOS)? [converter translationsForStringsAtURL:url] : [converter translationsForXMLAtURL:url];
        
        _translations = [NSMutableArray arrayWithArray:translations];
    }
    return self;

}

#pragma  mark - keys

- (void)extractKeys {
    _keysAndComments = [self.translations valueForKey:@"key"];
    if (!_keysAndComments) _keysAndComments = [NSArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self BEGINSWITH %@)", @"*"];
    _allKeys = [self.keysAndComments filteredArrayUsingPredicate:predicate];
    if (!_allKeys) _allKeys = [NSArray array];
}

- (NSArray *)keysAndComments {
    if (!_keysAndComments) [self extractKeys];
    return _keysAndComments;
}

- (NSArray *)allKeys {
    if (!_allKeys) [self extractKeys];
    return _allKeys;
}

- (ZFTranslationLine *)lineForKey:(NSString *)key {
    NSUInteger index = [self.keysAndComments indexOfObject:key];
    if (index == NSNotFound) return nil;
    return [self.translations objectAtIndex:index];
}

@end
