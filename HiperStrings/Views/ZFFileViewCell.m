//
//  ZFFileViewCell.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//
//  Open Source Initiative OSI - The MIT License (MIT):Licensing [OSI Approved License] The MIT License (MIT)
//  Copyright (c) 2013 ziofritz.
//

#import "ZFFileViewCell.h"

@implementation ZFFileViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSRect frame = self.bounds;
    frame.size.height = ceil(frame.size.height /2);
    self.titleLbl = [[NSTextField alloc] initWithFrame:frame];
    [self addSubview:self.titleLbl];
    
    frame.origin.y += frame.size.height;
    self.detailLbl = [[NSTextField alloc] initWithFrame:frame];
    [self addSubview:self.detailLbl];
}


- (void)setLangFile:(ZFLangFile *)langFile {
    _langFile = langFile;
    if (_langFile.iOSName.length > 0) [self.titleLbl setStringValue:_langFile.iOSName];
    if (_langFile.androidName.length > 0) [self.detailLbl setStringValue:_langFile.androidName];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
