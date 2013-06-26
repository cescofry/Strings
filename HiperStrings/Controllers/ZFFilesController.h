//
//  ZFFilesController.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFFileDetailController.h"

@interface ZFFilesController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet ZFFileDetailController *fileDetailController;
@property (nonatomic, strong) IBOutlet NSTableView *filesTable;
@property (assign) IBOutlet NSWindow *window;

@end
