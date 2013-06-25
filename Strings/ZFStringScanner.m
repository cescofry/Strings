//
//  ZFStringScanner.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFStringScanner.h"
#import "ZFStringsConverter.h"

@implementation ZFStringScanner

- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

- (void)scanStringsAtURL:(NSURL *)stringsURL {
    
    NSError *error = nil;
    NSArray *dirContents = [[self fileManager] contentsOfDirectoryAtURL:stringsURL includingPropertiesForKeys:nil options:0 error:&error];
    
    if (error) NSLog(@"Error: %@", error.debugDescription);
    
    [dirContents enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        
        BOOL isDir = NO;
        BOOL exists = [self.fileManager fileExistsAtPath:fileURL.path isDirectory:&isDir];
        
        if (!exists) return;
        
        if (!isDir) {
            
            BOOL isStringsFile = [[fileURL pathExtension] isEqualToString:@"strings"];
            if (!isStringsFile) return;
            NSURL *XMLURL = [fileURL URLByAppendingPathExtension:@"xml"];
            
            ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
            [converter convertStringsAtURL:fileURL toXMLAtURL:XMLURL];
        }
        else {
            [self scanStringsAtURL:fileURL];
        }
    }];
    
}

- (void)scanXMLsAtURL:(NSURL *)stringsURL {
    
}

@end
