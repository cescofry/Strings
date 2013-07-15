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
#import "ZFLangFile.h"

@interface ZFStringsConverter : NSObject


// XML
- (NSArray *)translationsForXMLAtURL:(NSURL *)XMLURL;
- (NSString *)xmlStringFromLang:(ZFLangFile *)file;


// Strings
- (NSString *)stringsStringFromLang:(ZFLangFile *)file;
- (NSArray *)translationsForStringsAtURL:(NSURL *)stringsURL;

// CSV
- (NSString *)csvFromFromLang:(ZFLangFile *)file defaultLang:(ZFLangFile *)defaultFile missingOnly:(BOOL)isMissingOnly;
- (NSArray *)translationsFromCSVAtURL:(NSURL *)stringsURL;

- (NSString *)convertFormatForString:(NSString *)input isFromIOS:(BOOL)isFromIOS;

@end
