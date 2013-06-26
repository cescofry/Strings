//
//  ZFStringsToXML.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFStringsConverter.h"

@implementation ZFStringsConverter

#pragma mark - Strings

- (NSString *)convertFormatForString:(NSString *)input isIOS:(BOOL)isIOS {
    static NSRegularExpression *formatIOSRegEx;
    static NSRegularExpression *formatAndroidRegEx;
    if (!formatIOSRegEx) {
        NSError *error;
        formatIOSRegEx = [NSRegularExpression regularExpressionWithPattern:@"%(.?\\d?[@a-z])" options:NSRegularExpressionAnchorsMatchLines error:&error];
        formatAndroidRegEx = [NSRegularExpression regularExpressionWithPattern:@"%(\\d.?\\d?[$a-z])" options:NSRegularExpressionAnchorsMatchLines error:&error];
    }
    
    __block NSMutableString *mutValue = [NSMutableString stringWithString:input];
    
    NSArray *formatMatches;
    if (isIOS) formatMatches = [formatIOSRegEx  matchesInString:input options:NSMatchingReportCompletion range:NSMakeRange(0, input.length)];
    else formatMatches = [formatAndroidRegEx  matchesInString:input options:NSMatchingReportCompletion range:NSMakeRange(0, input.length)];
    [formatMatches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *subMatch, NSUInteger idx, BOOL *stop) {
        int i = (int) idx + 1;
        NSRange range = [subMatch rangeAtIndex:1];
        NSString *replace = [input substringWithRange:range];
        if ([replace isEqualToString:@"@"]) replace = @"$";
        
        [mutValue  replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%d%@", i, replace]];
    }];
    
    return (NSString *)mutValue;
}

- (NSDictionary *)translationsForStringsAtURL:(NSURL *)stringsURL {
    
    if (!stringsURL) return nil;
    
    NSMutableDictionary *translation = [NSMutableDictionary dictionary];
    
    NSStringEncoding encoding;
    NSError *error;
    NSString *stringsString = [NSString stringWithContentsOfURL:stringsURL usedEncoding:&encoding error:&error];
    
    if (!stringsString || stringsString.length == 0) return nil;
    
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\"([a-zA-Z0-9._]*)\"[ ]*=[ ]*\"(.+?)\"[ ]*;" options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    NSArray *matches = [regEx matchesInString:stringsString options:NSMatchingReportCompletion range:NSMakeRange(0, stringsString.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        if ([match numberOfRanges] < 2) return;
        NSString *key = [stringsString substringWithRange:[match rangeAtIndex:1]];
        NSString *value = [stringsString substringWithRange:[match rangeAtIndex:2]];
        
        [translation setObject:value forKey:key];
    }];
    
    return (NSDictionary *)translation;
    
}

- (NSString *)stringsStringFromDictionary:(NSDictionary *)dictionary {
    
    NSMutableString *stringsString = [NSMutableString string];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [stringsString appendFormat:@"\"%@\" = \"%@\";\n", key, [self convertFormatForString:obj isIOS:YES]];
    }];
    
    return (NSString *)stringsString;
    
}

#pragma mark - XML

- (NSDictionary *)translationsForXMLAtURL:(NSURL *)XMLURL {
    NSMutableDictionary *translation = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithContentsOfURL:XMLURL options:NSDataReadingMappedIfSafe error:&error];
    NSArray *nodes = [xml nodesForXPath:@"//resources/string" error:&error];
    [nodes enumerateObjectsUsingBlock:^(NSXMLNode *obj, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:[obj XMLString] error:&error];
        NSString *key = [element attributeForName:@"name"].stringValue;

        [translation setObject:obj.stringValue forKey:key];
    }];
    
    return (NSDictionary *)translation;
}

- (NSString *)xmlStringFromDictionary:(NSDictionary *)dictionary {
    
    NSMutableArray *elements = [NSMutableArray array];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSXMLElement *element = [NSXMLElement elementWithName:@"string"];
        [element setAttributesAsDictionary:@{@"name" : key}];
        [element setStringValue:[self convertFormatForString:obj isIOS:NO]];
        
        [elements addObject:element];
    }];
    
    NSXMLElement *root = [NSXMLElement elementWithName:@"resources" children:elements attributes:nil];
    NSXMLDocument *xml = [NSXMLDocument documentWithRootElement:root];
    [xml setDocumentContentKind:NSXMLDocumentXMLKind];
    [xml setVersion:@"1.0"];
    [xml setCharacterEncoding:@"utf-8"];
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n%@", [xml XMLString]];
}

#pragma mark - Converters

- (void)convertStringsAtURL:(NSURL *)stringsURL toXMLAtURL:(NSURL *)XMLURL {
    NSDictionary *translations = [self translationsForStringsAtURL:stringsURL];
    NSString *translationsString = [self xmlStringFromDictionary:translations];
    
    NSError *error;
    [translationsString writeToURL:XMLURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
}


- (void)convertXMLAtURL:(NSURL *)XMLURL toStringsAtURL:(NSURL *)stringsURL {
    NSDictionary *translations = [self translationsForXMLAtURL:XMLURL];
    NSString *translationsString = [self stringsStringFromDictionary:translations];
    
    NSError *error;
    [translationsString writeToURL:stringsURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end
