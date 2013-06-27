//
//  ZFUtils.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ZF_UTILS [ZFUtils sharedUtils];

@interface ZFUtils : NSObject

- (NSString *)langFromURL:(NSURL *)url isIOS:(BOOL *)isIOS;
+(ZFUtils *)sharedUtils;

@end

