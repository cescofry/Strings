//
//  ZFStringScanner.h
//  Strings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFStringScanner : NSObject

- (void)scanStringsAtURL:(NSURL *)stringsURL;
- (void)scanXMLsAtURL:(NSURL *)stringsURL;

@end
