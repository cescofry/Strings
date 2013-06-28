//
//  ZFFileViewCell.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import <Cocoa/Cocoa.h>
#import "ZFTranslationFile.h"

@interface ZFFileViewCell : NSTableCellView

@property (nonatomic, strong) ZFTranslationFile *langFile;
@property (nonatomic, strong) NSTextField *titleLbl;
@property (nonatomic, strong) NSTextField *detailLbl;

@end
