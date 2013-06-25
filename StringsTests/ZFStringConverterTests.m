//
//  ZFStringConverterTests.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFStringConverterTests.h"
#import "ZFStringsConverter.h"

@interface ZFStringConverterTests ()

@property (nonatomic, strong) ZFStringsConverter *converter;

@end

@implementation ZFStringConverterTests

- (void)setUp
{
    [super setUp];
    self.converter = [[ZFStringsConverter alloc] init];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    self.converter = nil;
    
    [super tearDown];
}

- (void)testFormatConverter {
    NSString *input = @"%d %@ %f %.2f";
    NSString *output = @"%1d %2$ %3f %4.2f";
    
    NSString *convertedOutput = [self.converter convertFormatForString:input isIOS:YES];
    STAssertTrue([output isEqualToString:convertedOutput], @"Failed to properly convert fomat iOS -> Android");
    
}

- (void)testCopareConversions {
    
    NSURL *stringsURL = [[NSBundle mainBundle] URLForResource:@"Test" withExtension:@"txt"];
    NSURL *tempURL = [NSURL URLWithString:NSTemporaryDirectory()];
    NSURL *xmlURL = [tempURL URLByAppendingPathComponent:@"testXML.xml"];
    
    
    NSDictionary *stringsTranslations = [self.converter translationsForStringsAtURL:stringsURL];
    
    STAssertTrue((stringsTranslations && stringsTranslations.count > 0), @"XML result is empty");
    
    NSString *xmlString = [self.converter xmlStringFromDictionary:stringsTranslations];
    
    STAssertTrue((xmlString && xmlString.length > 0), @"XML result is empty");
    
    NSError *error = nil;
    [xmlString writeToURL:xmlURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSDictionary *xmlTranslations = [self.converter translationsForXMLAtURL:xmlURL];
    
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:stringsTranslations.allKeys];
    
    [xmlTranslations enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [allKeys removeObject:key];
        NSString *stringsValue = [stringsTranslations objectForKey:key];
        
        STAssertFalse((stringsValue == nil), @"Key %@ not present", key);
        
        if ([stringsValue rangeOfString:@"%"].location == NSNotFound) STAssertTrue([stringsValue isEqualToString:value], @"Key %@ didn't properly convert");
        else {
            stringsValue = [self.converter convertFormatForString:stringsValue isIOS:YES];
            STAssertTrue([stringsValue isEqualToString:value], @"Key %@ didn't properly convert formats");
        }
        
    }];
    
    STAssertTrue((allKeys.count == 0), @"Some keys have not been converted: %@", [allKeys componentsJoinedByString:@", "]);
    
}

@end
