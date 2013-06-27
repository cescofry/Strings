//
//  main.m
//  Strings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFStringScanner.h"


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString *arg = (argc == 2)? [NSString stringWithUTF8String:argv[1]] : @"--help";
        
        if ([arg isEqualToString:@"--help"]) {
            printf("Strings is a tool to convert iOS to Android translations file and vice versa.\nPlease use strings <ROOT URL> to start\n");
            return 0;
        }
        
        // insert code here...
        NSLog(@"Starting Strings:");
        
        NSURL *url = [NSURL URLWithString:arg];
        if (!url){
            printf("The directory provided is not valid. Exiting\n");
            return 0;
        }
        
        printf("Scanning %s\n", url.absoluteString.UTF8String);
        
        
        
        ZFStringScanner *scanner = [[ZFStringScanner alloc] init];
        [scanner startScanAtURL:url];
        
        printf("Nothing Done. Exiting\n");
        
    }
    return 0;
}

