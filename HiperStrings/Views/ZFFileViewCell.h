//
//  ZFFileViewCell.h
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZFLangFile.h"

@interface ZFFileViewCell : NSTableCellView

@property (nonatomic, strong) ZFLangFile *langFile;

@end
