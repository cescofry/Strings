//
//  ZFFileExportCell.m
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFFileExportCell.h"

@interface ZFFileExportCell ()

@property (nonatomic, strong) NSButton *button;

@end

#define BTN_W       50

@implementation ZFFileExportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSRect rect = self.titleLbl.frame;
    rect.size.width -= BTN_W;
    NSRect btnRect = NSMakeRect(rect.size.width, rect.origin.y, BTN_W, self.bounds.size.height);

    [self.titleLbl setFrame:rect];
    rect.origin.y += rect.size.height;
    [self.detailLbl setFrame:rect];
    
    self.button = [[NSButton alloc] initWithFrame:btnRect];
    [self.button setTarget:self];
    [self.button setAction:@selector(btnAction:)];
    [self addSubview:self.button];
}

- (void)setLangFile:(ZFLangFile *)langFile {
    [super setLangFile:langFile];
    
    NSString *btnTxt = (langFile.iOSName)? @"i" : @"A";
    [self.button setStringValue:btnTxt];
}

- (void)btnAction:(NSButton *)sender {
    NSString *btnTxt = sender.stringValue;
    if ([btnTxt isEqualToString:@"i"]) {
        if (self.langFile.androidName) btnTxt = @"A";
        else btnTxt = @"X";
    }
    if ([btnTxt isEqualToString:@"A"]) {
        btnTxt = @"X";
    }
    
    if ([btnTxt isEqualToString:@"X"]) {
        if (self.langFile.iOSName) btnTxt = @"i";
        else btnTxt = @"A";
    }
}

@end
