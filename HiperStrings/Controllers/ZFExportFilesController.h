//
//  ZFExportFilesController.h
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFStringScanner.h"

@interface ZFExportFilesController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) ZFStringScanner *scanner;
@property (nonatomic, strong) IBOutlet NSWindow *window;

- (IBAction)exportAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
