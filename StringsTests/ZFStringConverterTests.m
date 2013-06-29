//
//  ZFStringConverterTests.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
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

- (void)testCompareConversions {
    
    NSURL *stringsURL = [[NSBundle mainBundle] URLForResource:@"Test" withExtension:@"txt"];
    NSURL *tempURL = [NSURL URLWithString:NSTemporaryDirectory()];
    NSURL *xmlURL = [tempURL URLByAppendingPathComponent:@"testXML.xml"];
    
    
    NSArray *stringsTranslations = [self.converter translationsForStringsAtURL:stringsURL];
    
    STAssertTrue((stringsTranslations && stringsTranslations.count > 0), @"XML result is empty");
    
    NSString *xmlString = [self.converter xmlStringFromTranslations:stringsTranslations];
    
    STAssertTrue((xmlString && xmlString.length > 0), @"XML result is empty");
    
}

@end
