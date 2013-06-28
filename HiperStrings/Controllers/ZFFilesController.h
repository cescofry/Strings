//
//  ZFFilesController.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import <Foundation/Foundation.h>
#import "ZFFileDetailController.h"
#import "ZFExportFilesController.h"

@interface ZFFilesController : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (nonatomic, strong) IBOutlet ZFFileDetailController *fileDetailController;
@property (nonatomic, strong) IBOutlet NSTableView *filesTable;
@property (nonatomic, strong) IBOutlet NSButton *exportBtn;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *exportPanel;

@property (nonatomic, strong) IBOutlet ZFExportFilesController *exportController;

- (IBAction)exportAction:(id)sender;

@end
