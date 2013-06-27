//
//  ZFStringsToXML.h
//  Strings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFStringsConverter : NSObject

- (void)convertStringsAtURL:(NSURL *)stringsURL toXMLAtURL:(NSURL *)XMLURL  __deprecated;
- (void)convertXMLAtURL:(NSURL *)XMLURL toStringsAtURL:(NSURL *)stringsURL  __deprecated;


- (NSDictionary *)translationsForXMLAtURL:(NSURL *)XMLURL;
- (NSString *)xmlStringFromDictionary:(NSDictionary *)dictionary;

- (NSString *)stringsStringFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)translationsForStringsAtURL:(NSURL *)stringsURL;

- (NSString *)convertFormatForString:(NSString *)input isIOS:(BOOL)isIOS;

@end
