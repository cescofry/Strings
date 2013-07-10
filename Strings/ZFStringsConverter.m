//
//  ZFStringsToXML.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFStringsConverter.h"
#import "Config.h"
#import "ZFTranslationLine.h"

@implementation ZFStringsConverter

#pragma mark - Strings

/*!
 @abstract
 Convert a string substituting the format value from and to iOS/Andorid
 
 @param input string to be converted
 
 @param isIOS boolean for the conversion direction
 
 @return NSSTring, the converted string
 
 @discussion The converter takes care of different string rapresentation and enumeration of arguaments on Andorid
 
 */

- (NSString *)convertFormatForString:(NSString *)input isFromIOS:(BOOL)isFromIOS {
    static NSRegularExpression *formatIOSRegEx;
    static NSRegularExpression *formatAndroidRegEx;
    if (!formatIOSRegEx) {
        NSError *error;
        formatIOSRegEx = [NSRegularExpression regularExpressionWithPattern:ZF_FORMAT_IOS_REGEX options:NSRegularExpressionAnchorsMatchLines error:&error];
        formatAndroidRegEx = [NSRegularExpression regularExpressionWithPattern:ZF_FORMAT_ANDROID_REGEX options:NSRegularExpressionAnchorsMatchLines error:&error];
    }
    
    __block NSMutableString *mutValue = [NSMutableString stringWithString:input];
    
    NSArray *formatMatches;
    if (isFromIOS) formatMatches = [formatIOSRegEx  matchesInString:input options:NSMatchingReportCompletion range:NSMakeRange(0, input.length)];
    else formatMatches = [formatAndroidRegEx  matchesInString:input options:NSMatchingReportCompletion range:NSMakeRange(0, input.length)];
    
    [formatMatches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *subMatch, NSUInteger idx, BOOL *stop) {
        int i = (int) idx + 1;
        
        NSRange origRange = [subMatch rangeAtIndex:1];
        NSString *orig = [input substringWithRange:origRange];
        
        NSString *replace = nil;
        
        NSRange range;
        if (isFromIOS) {
            // add number
            replace = [NSString stringWithFormat:@"%d$%@", i, orig];
            // check for @
            range = [replace rangeOfString:@"@"];
            if (range.location != NSNotFound) replace = [replace stringByReplacingCharactersInRange:range withString:@"s"];
        }
        else {
            // remove number
            range = [orig rangeOfString:[NSString stringWithFormat:@"%d$", i]];
            if (range.location != NSNotFound) replace = [orig stringByReplacingCharactersInRange:range withString:@""];
            //replace = [orig substringWithRange:NSMakeRange(1, (orig.length - 1))]; // TODO: Fromatting numbers is wrong. Putting too early
            // check for $
            range = [replace rangeOfString:@"s"];
            if (range.location != NSNotFound) replace = [replace stringByReplacingCharactersInRange:range withString:@"@"];
        }
        
        if (replace) [mutValue replaceCharactersInRange:origRange withString:replace];

    }];
    
    return (NSString *)mutValue;
}

/*!
 @abstract
 Convert the .strings file at a given URL and converts it to a dictionary of transaltions
 
 @param stringsURL the url of the file to be converted
 
 @return NSArray with the translations
 
 @discussion The comments are not recorded so they are lost in this fase already. The same is true for the key sorting which is likely to become alphabetical in the process
 
 */

- (NSArray *)translationsForStringsAtURL:(NSURL *)stringsURL {
    
    if (!stringsURL) return nil;
    
    
    NSStringEncoding encoding;
    NSError *error;
    NSString *stringsString = [NSString stringWithContentsOfURL:stringsURL usedEncoding:&encoding error:&error];
    
    if (!stringsString || stringsString.length == 0) return nil;
    
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:ZF_IOS_REGEX options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSRegularExpression *commentRegEx = [NSRegularExpression regularExpressionWithPattern:ZF_IOS_COMMENT_REGEX options:0 error:&error];
    
    NSArray *matches = [regEx matchesInString:stringsString options:NSMatchingReportCompletion range:NSMakeRange(0, stringsString.length)];
    NSArray *comments = [commentRegEx matchesInString:stringsString options:NSMatchingReportCompletion range:NSMakeRange(0, stringsString.length)];
    NSMutableArray *translations = [NSMutableArray array];
    
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        ZFTranslationLine *line = [ZFTranslationLine line];
        
        NSString *key = [stringsString substringWithRange:[match rangeAtIndex:1]];
        NSString *value = [stringsString substringWithRange:[match rangeAtIndex:2]];
        
        [line setKey:key];
        [line setValue:value];
        [line setPosition:idx];
        [line setRange:[match rangeAtIndex:0]];
        
        [translations addObject:line];
    }];
    
    [comments enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        ZFTranslationLine *line = [ZFTranslationLine line];

        NSString *value = [stringsString substringWithRange:[match rangeAtIndex:1]];
        [line setKey:[NSString stringWithFormat:@"*_comment_%ld", idx]];
        [line setValue:value];
        [line setPosition:idx];
        [line setType:ZFTranslationLineTypeComment];
        [line setRange:[match rangeAtIndex:0]];
    
        [translations addObject:line];
    }];
    
    return (NSArray *)translations;
    
}

/*!
 @abstract
 Parse the translations to a string ready to be written to a .strings file
 
 @param array of translations
 
 @return NSString ready in .strings format
 
 */

- (NSString *)stringsStringFromTranslations:(NSArray *)translations {
    
    NSMutableString *stringsString = [NSMutableString string];
    
    [translations enumerateObjectsUsingBlock:^(ZFTranslationLine *line, NSUInteger idx, BOOL *stop) {
        
        if (line.type == ZFTranslationLineTypeComment) {
            [stringsString appendFormat:@"/** %@ */\n", line.value];
            return;
        }
        
        NSString *value = (line.type == ZFTranslationLineTypeFormattedString)? [self convertFormatForString:line.value isFromIOS:NO] : line.value;
        [stringsString appendFormat:@"\"%@\" = \"%@\";\n", line.key, value];
    }];
    
    return (NSString *)stringsString;
    
}



#pragma mark - XML

/*!
 @abstract
 Converts the .xml file at URL to a dictionary of translations
 
 @param MLXURL of the file to be converted
 
 @return NSArray with the translations
 
 */

- (NSArray *)translationsForXMLAtURL:(NSURL *)XMLURL {
    if (!XMLURL) return nil;
    
    NSMutableArray *translation = [NSMutableArray array];
    
    NSError *error = nil;
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:XMLURL options:NSDataReadingMappedIfSafe error:&error];
    NSArray *nodes = [xml nodesForXPath:@"//resources/string" error:&error];
    [nodes enumerateObjectsUsingBlock:^(NSXMLNode *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:[obj XMLString] error:&error];
        NSString *key = [element attributeForName:@"name"].stringValue;
        NSString *value = [obj.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
        
        ZFTranslationLine *line = [ZFTranslationLine line];
        [line setKey:key];
        [line setValue:value];
        [line setPosition:idx];
        
        [translation addObject:line];
    }];
    
    return (NSArray *)translation;
}

/*!
 @abstract
 Parse the dictionary of transaltions to a string ready to be written on an .xml file
 
 @param array with the transaltions
 
 @return NSString ready to be written to an .xml file
 
 @discussion The format attribute is not parsed
 
 */

- (NSString *)xmlStringFromTranslations:(NSArray *)translations {
    
    NSMutableArray *elements = [NSMutableArray array];
    [translations enumerateObjectsUsingBlock:^(ZFTranslationLine *line, NSUInteger idx, BOOL *stop) {

        if (line.type == ZFTranslationLineTypeComment) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithKind:NSXMLCommentKind];
            [element setStringValue:line.value];
            
            [elements addObject:element];
        }
        else {
            NSXMLElement *element = [NSXMLElement elementWithName:@"string"];
            [element setAttributesAsDictionary:@{@"name" : line.key}];
            NSString *value = (line.type == ZFTranslationLineTypeFormattedString)? [self convertFormatForString:line.value isFromIOS:YES] : line.value;
            [element setStringValue:value];
            
            [elements addObject:element];
        }
        
    }];
    
    NSXMLElement *root = [NSXMLElement elementWithName:@"resources" children:elements attributes:nil];
    NSXMLDocument *xml = [NSXMLDocument documentWithRootElement:root];
    [xml setDocumentContentKind:NSXMLDocumentXMLKind];
    [xml setVersion:@"1.0"];
    [xml setCharacterEncoding:@"utf-8"];

    
    return [xml XMLStringWithOptions:NSXMLNodePrettyPrint|NSXMLCommentKind];
}

@end
