//
//  ZFLangFile.h
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZFLangTypeIOS,
    ZFLangTypeAndorid
} ZFLangType;

@interface ZFLangFile : NSObject

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, assign, readonly) ZFLangType type;
@property (nonatomic, strong, readonly) NSString *language;
@property (nonatomic, strong, readonly) NSMutableDictionary *translations;

- (id)initWithURL:(NSURL *)url;

@end
