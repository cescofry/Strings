//
//  ZFFileDetailController.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import <Foundation/Foundation.h>
#import "ZFLangFile.h"

@interface ZFFileDetailController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) ZFLangFile *langFile;

- (IBAction)didSwithSegmentedControl:(NSSegmentedControl *)sender;

@end
