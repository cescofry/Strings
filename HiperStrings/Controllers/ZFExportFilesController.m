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

@implementation ZFExportFilesController

- (void)setScanner:(ZFStringScanner *)scanner {
    _scanner = scanner;
    [self.tableView reloadData];
}

#pragma mark - actions

- (IBAction)exportAction:(id)sender {
    
    __block BOOL succeded = YES;
    __block NSError *error;
    [self.scanner.files enumerateObjectsUsingBlock:^(ZFTranslationFile *translationFile, NSUInteger idx, BOOL *stop) {
        BOOL done = [translationFile writeAllTranslationsError:&error];
        if (succeded && !done) succeded = NO;
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
