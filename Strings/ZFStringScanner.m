//
//  ZFStringScanner.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFStringScanner.h"
#import "ZFStringsConverter.h"
#import "ZFTranslationFile.h"

@interface ZFStringScanner ()

@property (nonatomic, strong) NSURL *rootURL;
@property (nonatomic, strong) NSURL *rootIOSURL;
@property (nonatomic, strong) NSURL *rootAndroidURL;

@end

@implementation ZFStringScanner

@synthesize files = _files;

#pragma mark getters

- (NSMutableArray *)files {
    if (!_files) _files = [NSMutableArray array];
    return _files;
}


- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}



#pragma mark - conversions

/*!
 @abstract
 Scan the url for translations files for both iOS and Android
 
 @param url of the resource
 
 */

- (void)scanAtURL:(NSURL *)URL {
    
    NSError *error = nil;
    NSArray *dirContents = [[self fileManager] contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:0 error:&error];
    
    if (error) NSLog(@"Error: %@", error.debugDescription);
    
    [dirContents enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        
        BOOL isDir = NO;
        BOOL exists = [self.fileManager fileExistsAtPath:fileURL.path isDirectory:&isDir];
        
        if (!exists) return;
        
        if (!isDir) {           
    
            ZFTranslationFile *file = [[ZFTranslationFile alloc] init];
            BOOL valid = [file addFileAtURL:fileURL];
            if (valid) {
                [self.files addObject:file];
            }
            
        }
        else {
            [self scanAtURL:fileURL];
        }
    }];
    
}

/*!
 @abstract
 Entry point for scanning recursively starting from a given URL
 
 @param url, root of the scan to perform
 
 @discussion After the directory scan is complete, all the generated files get merged by languages and resource type (iOS/Android)
 
 */

- (void)startScanAtURL:(NSURL *)URL {
    [self scanAtURL:URL];
    
    NSMutableArray *groups = [NSMutableArray array];
    [self.files enumerateObjectsUsingBlock:^(ZFTranslationFile *file, NSUInteger idx, BOOL *stop) {
        
        __block BOOL inserted = NO;
        [groups enumerateObjectsUsingBlock:^(NSMutableArray *group, NSUInteger idx, BOOL *stop) {
            if ([file isEqual:[group objectAtIndex:0]]) {
                [group addObject:file];
                *stop = YES;
                inserted = YES;
            }
        }];
        if (!inserted) [groups addObject:[NSMutableArray arrayWithObject:file]];
    }];
    
    
    NSMutableArray *result = [NSMutableArray array];
    [groups enumerateObjectsUsingBlock:^(NSMutableArray *group, NSUInteger idx, BOOL *stop) {
        ZFTranslationFile *file = [group objectAtIndex:0];
        [group enumerateObjectsUsingBlock:^(ZFTranslationFile *anotherFile, NSUInteger idx, BOOL *stop) {
            if (idx == 0) return;
            [file mergeWithFile:anotherFile];
        }];
        [result addObject:file];
    }];
    
    _files = result;
    result = nil;
    groups = nil;
    
}


@end
