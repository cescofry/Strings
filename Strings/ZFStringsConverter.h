//
//  ZFStringsToXML.h
//  Strings
//
//  Created by Francesco on 25/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import <Foundation/Foundation.h>

@interface ZFStringsConverter : NSObject

- (NSArray *)translationsForXMLAtURL:(NSURL *)XMLURL;
- (NSString *)xmlStringFromTranslations:(NSArray *)translations;

- (NSString *)stringsStringFromTranslations:(NSArray *)translations;
- (NSArray *)translationsForStringsAtURL:(NSURL *)stringsURL;

- (NSString *)convertFormatForString:(NSString *)input isIOS:(BOOL)isIOS;

@end
