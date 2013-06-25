//
//  ZFAppDelegate.m
//  HiperStrings
//
//  Created by Francesco on 25/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFAppDelegate.h"
#import "ZFStringScanner.h"

@interface ZFAppDelegate ()

@property(nonatomic, strong) NSURL *sourceURL;

@end

@implementation ZFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self setURLFromDialog:^(BOOL success) {
        if (!self.sourceURL || !success) return;
        ZFStringScanner *scanner = [[ZFStringScanner alloc] init];
        [scanner scanStringsAtURL:self.sourceURL];
    }];
}


- (void)setURLFromDialog:(void (^)(BOOL success)) completed {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:YES];
    
    
    void (^completitionBlock)(NSInteger) = ^(NSInteger result) {
        if (result != NSOKButton) {
            if (completed) completed(NO);
            return;
        }
        
        self.sourceURL = openDlg.URL;
        if (completed) completed(YES);
    };
    
    if (!self.window) [openDlg beginWithCompletionHandler:completitionBlock];
    else [openDlg beginSheetModalForWindow:self.window completionHandler:completitionBlock];
}


@end
