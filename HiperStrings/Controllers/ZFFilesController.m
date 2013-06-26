//
//  ZFFilesController.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFFilesController.h"
#import "ZFFileViewCell.h"
#import "ZFStringScanner.h"
#import "ZFLangFile.h"

@interface ZFFilesController ()

@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, strong) ZFStringScanner *scanner;

@end

@implementation ZFFilesController

#pragma mark - tableview

- (id)init
{
    self = [super init];
    if (self) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self load];
        });
    }
    return self;
}

- (void)load {
    [self setURLFromDialog:^(BOOL success) {
        if (!self.sourceURL || !success) return;
        self.scanner = [[ZFStringScanner alloc] init];
        [self.scanner startScanAtURL:self.sourceURL];
        [self.filesTable reloadData];
        /*
        [scanner.files enumerateObjectsUsingBlock:^(ZFLangFile *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"file\n %@[%@]\n %@[%@]", obj.iOSName, [obj.iOStranslations.allKeys componentsJoinedByString:@"|"], obj.androidName, [obj.androidTranslations.allKeys componentsJoinedByString:@"|"]);
        }];
         */
        
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.scanner.files count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ZFFileViewCell *cell = [tableView makeViewWithIdentifier:@"langCell" owner:self];
    [cell setLangFile:[self.scanner.files objectAtIndex:row]];
    
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (self.fileDetailController) [self.fileDetailController setLangFile:[self.scanner.files objectAtIndex:row]];
    return YES;
}

@end
