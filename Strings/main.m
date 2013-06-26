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
        
        // insert code here...
        NSLog(@"Starting Strings:");
        NSString *urlString = [NSString stringWithUTF8String:argv[0]];
        NSLog(@"Scanning %@", urlString);
        
        
        
        ZFStringScanner *scanner = [[ZFStringScanner alloc] init];
        [scanner scanStringsAtURL:[NSURL URLWithString:urlString]];
        
        NSLog(@"Done, exiting");
        
    }
    return 0;
}

