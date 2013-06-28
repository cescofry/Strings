//
//  ZFFileExportCell.m
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import "ZFFileExportCell.h"

#define I_TO_DROID  @"i >> A"
#define DROID_TO_I  @"A >> i"
#define SKIP        @"X"

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

- (void)setLangFile:(ZFTranslationFile *)langFile {
    [super setLangFile:langFile];
    [self.button setTitle:[self stringFromConversionDriver:self.langFile.conversionDriver]];
}

- (NSString *)stringFromConversionDriver:(ZFTranslationFileConversionDriver)driver {
    NSString *conversionS = nil;
    
    switch (driver) {
        case ZFTranslationFileConversionDriverIOS:
            conversionS = I_TO_DROID;
            break;
        case ZFTranslationFileConversionDriverAndorid:
            conversionS = DROID_TO_I;
            break;
        case ZFTranslationFileConversionDriverSkip:
        default:
            conversionS = SKIP;
            break;
    }
    return conversionS;
}

- (void)btnAction:(NSButton *)sender {
    ZFTranslationFileConversionDriver newDriver;
    switch (self.langFile.conversionDriver) {
        case ZFTranslationFileConversionDriverIOS:
            newDriver = (self.langFile.androidName)? ZFTranslationFileConversionDriverAndorid : ZFTranslationFileConversionDriverSkip;
            break;
        case ZFTranslationFileConversionDriverAndorid:
            newDriver = ZFTranslationFileConversionDriverSkip;
            break;
        case ZFTranslationFileConversionDriverSkip:
            newDriver = (self.langFile.iOSName)? ZFTranslationFileConversionDriverIOS : ZFTranslationFileConversionDriverAndorid;
            break;
        default:
            break;
    }
    
    
    self.langFile.conversionDriver = newDriver;
    [self.button setTitle:[self stringFromConversionDriver:self.langFile.conversionDriver]];
}

@end
