//
//  ZFFileViewCell.m
//  Strings
//
//  Created by Francesco on 26/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFFileViewCell.h"

@interface ZFFileViewCell ()

@property (nonatomic, strong) NSTextView *titleLbl;
@property (nonatomic, strong) NSTextView *detailLbl;

@end

@implementation ZFFileViewCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        frame = self.bounds;
        frame.size.height = ceil(frame.size.height /2);
        self.titleLbl = [[NSTextView alloc] initWithFrame:frame];
        [self addSubview:self.titleLbl];
        
        frame.origin.y += frame.size.height;
        self.detailLbl = [[NSTextView alloc] initWithFrame:frame];
        [self addSubview:self.detailLbl];
    }
    
    return self;
}

- (void)setLangFile:(ZFLangFile *)langFile {
    _langFile = langFile;
    if (_langFile.iOSName.length > 0) [self.textField setStringValue:_langFile.iOSName];
    
    if (_langFile.androidName.length > 0) [self.textField setStringValue:_langFile.androidName];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
