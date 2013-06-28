//
//  ZFLangFile.m
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFLangFile.h"
#import "ZFStringsConverter.h"

@implementation ZFLangFile


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
        NSDictionary *translations = (isIOS)? [converter translationsForStringsAtURL:url] : [converter translationsForXMLAtURL:url];
        
        _translations = [NSMutableDictionary dictionaryWithDictionary:translations];
    }
    return self;

}

@end
