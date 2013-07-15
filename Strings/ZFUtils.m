//
//  ZFUtils.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFUtils.h"
#import "Config.h"

@interface ZFUtils ()

@end

@implementation ZFUtils



#pragma mark - singleton

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
