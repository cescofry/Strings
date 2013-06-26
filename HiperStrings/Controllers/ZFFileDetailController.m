//
//  ZFFileDetailController.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFFileDetailController.h"

#define KEY_KEY     @"Keys"

@interface ZFFileDetailController ()

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSDictionary *rows;
@property (nonatomic, strong) NSArray *columns;

@end

@implementation ZFFileDetailController

- (void)setLangFile:(ZFLangFile *)langFile {
    _langFile = langFile;
    
    [self didSwithSegmentedControl:self.segmentedControl];
    
}

#pragma mark - Segmented Controller

- (IBAction)didSwithSegmentedControl:(NSSegmentedControl *)sender {
    self.rows = (self.segmentedControl.selectedSegment == 0)? [self.langFile iOStranslations] : [self.langFile androidTranslations];

    self.columns = [[NSArray arrayWithObject:KEY_KEY] arrayByAddingObjectsFromArray:[self.rows allKeys]];
    self.keys = (self.columns.count > 1)? [[self.rows objectForKey:[self.columns objectAtIndex:1]] allKeys] : [NSArray array];
    
    NSMutableArray *addCol = [self.columns mutableCopy];
    
    [self.tableView beginUpdates];
    
    NSArray *columns = [self.tableView.tableColumns copy];
    [columns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
        if ([self.columns containsObject:column.identifier]) {
            [addCol removeObject:column.identifier];
            return;
        }
        
        [self.tableView removeTableColumn:column];
    }];
    [addCol enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:obj];
        [column setHeaderCell:[[NSCell alloc] initTextCell:obj]];
        [self.tableView addTableColumn:column];
    }];
    
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark - TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.rows count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:KEY_KEY]) return [self.keys objectAtIndex:row];
    else return [[self.rows objectForKey:tableColumn.identifier] objectForKey:[self.keys objectAtIndex:row]];
}

@end
