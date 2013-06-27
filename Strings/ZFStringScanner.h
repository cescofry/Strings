//
//  ZFStringScanner.h
//  Strings
//
//  Created by Francesco on 25/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import <Foundation/Foundation.h>

@interface ZFStringScanner : NSObject

@property (nonatomic, strong) NSMutableArray *files;

- (void)startScanAtURL:(NSURL *)URL;

@end
