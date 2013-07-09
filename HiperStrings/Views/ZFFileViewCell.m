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

@interface ZFFileViewCell ()

@property (nonatomic, strong) NSImageView *iOSIcon;
@property (nonatomic, strong) NSImageView *androidIcon;

@end

@implementation ZFFileViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGRect labelFrame;
    CGRect iconFrame;
    CGRect frame = self.bounds;
    frame.size.height = ceil(frame.size.height /2);
    
    CGRectDivide(frame, &iconFrame, &labelFrame, 30, CGRectMinXEdge);

    self.detailLbl = [[NSTextField alloc] initWithFrame:labelFrame];
    [self.detailLbl setBordered:NO];
    [self addSubview:self.detailLbl];

    self.androidIcon = [[NSImageView alloc] initWithFrame:iconFrame];
    [self.androidIcon setImage:[NSImage imageNamed:@"android_icon"]];
    [self addSubview:self.androidIcon];
    
    labelFrame.origin.y += labelFrame.size.height;
    self.titleLbl = [[NSTextField alloc] initWithFrame:labelFrame];
    [self.titleLbl setBordered:NO];
    [self addSubview:self.titleLbl];
    
    iconFrame.origin.y += iconFrame.size.height;
    self.iOSIcon = [[NSImageView alloc] initWithFrame:iconFrame];
    [self.iOSIcon setImage:[NSImage imageNamed:@"iOS_icon"]];
    [self addSubview:self.iOSIcon];

}


- (void)setLangFile:(ZFTranslationFile *)langFile {
    _langFile = langFile;
    if (_langFile.iOSName.length > 0) [self.titleLbl setStringValue:_langFile.iOSName];
    if (_langFile.androidName.length > 0) [self.detailLbl setStringValue:_langFile.androidName];
    [self setNeedsDisplay:YES];
}

@end
