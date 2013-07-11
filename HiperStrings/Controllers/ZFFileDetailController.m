//
//  ZFFileDetailController.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFFileDetailController.h"

#define KEY_KEY     @"Keys"

@interface ZFFileDetailController ()

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSArray *columns;

@end

@implementation ZFFileDetailController

- (void)setLangFile:(ZFTranslationFile *)langFile {
    _langFile = langFile;
    
    self.columns = [[NSArray arrayWithObject:KEY_KEY] arrayByAddingObjectsFromArray:[_langFile allIdioms]];
    self.keys = (self.columns.count > 1)? [self.langFile allKeys] : [NSArray array];
    
    NSMutableArray *addCol = [self.columns mutableCopy];
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
        [[column headerCell] setStringValue:obj];
        [[column headerCell] setAlignment:NSLeftTextAlignment];
        [self.tableView addTableColumn:column];
    }];
    
    [self didSwithSegmentedControl:self.segmentedControl];
    
}

#pragma mark - Segmented Controller

-(void)tableViewColumnDidResize:(NSNotification *)notification {

//    NSTableColumn *column = [[notification userInfo] objectForKey:@"NSTableColumn"];

}

- (IBAction)didSwithSegmentedControl:(NSSegmentedControl *)sender {
    self.rows = [self.langFile translationsByType:(self.segmentedControl.selectedSegment == 0)? ZFLangTypeIOS : ZFLangTypeAndorid andLanguageIdentifier:nil];  
    [self.tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.keys count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {    
    NSString *key = [self.keys objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:KEY_KEY]) return key;
    else {
        NSArray *translation = [self.langFile translationsByType:(self.segmentedControl.selectedSegment == 0)? ZFLangTypeIOS : ZFLangTypeAndorid andLanguageIdentifier:tableColumn.identifier];
        ZFLangFile *lang = [translation lastObject];
        ZFTranslationLine *line = [lang lineForKey:key];
        return (line.type != ZFTranslationLineTypeUntranslated)? line.value : @"--";
    }
    
    //return [[self.rows objectForKey:tableColumn.identifier] objectForKey:[self.keys objectAtIndex:row]];
}

@end
