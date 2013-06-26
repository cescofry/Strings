//
//  ZFUtils.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFUtils.h"

@interface ZFUtils ()

@property (nonatomic, strong) NSRegularExpression *iOSLangRegEx;
@property (nonatomic, strong) NSRegularExpression *androidLangRegEx;

@end

@implementation ZFUtils


- (NSRegularExpression *)iOSLangRegEx {
    if (!_iOSLangRegEx) {
        NSError *error = nil;
        _iOSLangRegEx = [[NSRegularExpression alloc] initWithPattern:@"/([a-z]{2}).lproj/" options:0 error:&error];
    }
    return _iOSLangRegEx;
}

- (NSRegularExpression *)androidLangRegEx {
    if (!_androidLangRegEx) {
        NSError *error = nil;
        _androidLangRegEx = [[NSRegularExpression alloc] initWithPattern:@"/values-([a-z]{2})/" options:0 error:&error];
    }
    return _androidLangRegEx;
}


- (NSString *)langFromURL:(NSURL *)url isIOS:(BOOL *)isIOS {
    NSArray *matches = [self.iOSLangRegEx matchesInString:url.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, url.absoluteString.length)];
    BOOL _isIOS = (matches && matches.count > 0);
    if (!_isIOS) {
        matches = [self.androidLangRegEx matchesInString:url.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, url.absoluteString.length)];
    }
    
    if (!matches || matches.count == 0) return nil;
    
    if (isIOS) *isIOS = _isIOS;
    
    NSRange langMatchRange = [[matches objectAtIndex:0] rangeAtIndex:1];
    NSString *lang = [url.absoluteString substringWithRange:langMatchRange];
    
    return lang;
}

#pragma mark singleton

static ZFUtils *_sharedUtils;

+ (ZFUtils *)sharedUtils {
    if (!_sharedUtils) _sharedUtils = [[ZFUtils alloc] init];
    return _sharedUtils;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_sharedUtils == nil) {
            _sharedUtils = [super allocWithZone:zone];
            return _sharedUtils;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}



@end
