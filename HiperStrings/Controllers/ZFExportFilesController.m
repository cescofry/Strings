//
//  ZFExportFilesController.m
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFExportFilesController.h"
#import "ZFTranslationFile.h"
#import "ZFFileExportCell.h"

@interface ZFExportFilesController ()

@property (nonatomic, strong) NSURL *CSVExportURL;

@end

@implementation ZFExportFilesController

- (void)setScanner:(ZFStringScanner *)scanner {
    _scanner = scanner;
    [self.tableView reloadData];
    
    [self.csvPopUpBtn removeAllItems];
    NSArray *items = @[@"none", @"All Keys", @"Only Missing"];
    [self.csvPopUpBtn addItemsWithTitles:items];
    [self.csvPopUpBtn selectItemAtIndex:0];
    
}

#pragma mark - actions

- (IBAction)csvPopUpChanged:(id)sender {
    NSInteger selected = [self.csvPopUpBtn indexOfSelectedItem];
    if (selected >= 1 && !self.CSVExportURL) {
        NSOpenPanel* openDlg = [NSOpenPanel openPanel];
        [openDlg setCanChooseFiles:NO];
        [openDlg setAllowsMultipleSelection:NO];
        [openDlg setCanChooseDirectories:YES];
        
        
        void (^completitionBlock)(NSInteger) = ^(NSInteger result) {
            self.CSVExportURL = openDlg.URL;
        };
        
        if (!self.window) [openDlg beginWithCompletionHandler:completitionBlock];
        else [openDlg beginSheetModalForWindow:self.window completionHandler:completitionBlock];
    }
}

- (IBAction)exportAction:(id)sender {
    
    __block BOOL succeded = YES;
    __block NSError *error;
    NSInteger index = [self.csvPopUpBtn indexOfSelectedItem];
    [self.scanner.files enumerateObjectsUsingBlock:^(ZFTranslationFile *translationFile, NSUInteger idx, BOOL *stop) {
        BOOL done = [translationFile writeAllTranslationsError:&error];
        if (succeded && !done) succeded = NO;
        
        if (!self.CSVExportURL) return;
        [translationFile writeAllCSVToURL:self.CSVExportURL missingOnly:(index > 1) error:&error];
 
    }];
    
    NSString *message = (!error)? @"Export succeded" : error.debugDescription;
    NSAlert *alert = [NSAlert alertWithMessageText:@"Export" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
    [alert runModal];
    
    [self.window close];
}

- (IBAction)cancelAction:(id)sender {
    [self.window close];
}

#pragma mark - TAbleView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger count = self.scanner.files.count;
    return count;
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ZFTranslationFile *langFile = [self.scanner.files objectAtIndex:row];
    ZFFileExportCell *cell = [tableView makeViewWithIdentifier:@"langExportCell" owner:self];
    [cell setLangFile:langFile];
    
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}


@end
