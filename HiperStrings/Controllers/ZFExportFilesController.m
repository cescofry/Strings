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
#import "ZFStringsConverter.h"

@implementation ZFExportFilesController

- (void)setScanner:(ZFStringScanner *)scanner {
    _scanner = scanner;
    [self.tableView reloadData];
}

#pragma mark - actions

- (IBAction)exportAction:(id)sender {
    
    ZFStringsConverter *converter = [[ZFStringsConverter alloc] init];
    [self.scanner.files enumerateObjectsUsingBlock:^(ZFTranslationFile *langFile, NSUInteger idx, BOOL *stop) {
        
    }];
    
    
    
    
    [self.window close];
}

- (IBAction)cancelAction:(id)sender {
    [self.window close];
}

#pragma mark - TAbleView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    int count = self.scanner.files.count;
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
