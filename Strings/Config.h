//
//  Config.h
//  Strings
//
//  Created by Francesco on 28/06/2013.
//  Copyright (c) 2013 ziofritz. All rights reserved.
//

#ifndef Strings_Config_h
#define Strings_Config_h

#pragma mark - formats
#pragma mark iOS

#define ZF_IOS_COMMENT_REGEX            @"/\\*((.|[\r\n])*?)\\*/"
#define ZF_IOS_REGEX                    @"\"([a-zA-Z0-9._]*)\"[ ]*=[ ]*\"(.+?)\"[ ]*;"
#define ZF_FORMAT_IOS_REGEX             @"%(.?\\d?[@a-z])"
#define ZF_LANG_DIR_IOS_REGEX           @"/([a-z]{2}).lproj/"
#define ZF_LANG_DIR_IOS_                @"%@.lproj"
#define ZF_LANG_EXTENSION_IOS_          @"strings"

#pragma mark - Android

#define ZF_ANDROID_COMMENT_REGEX        @"<!--(.|[\r\n])*?-->"
#define ZF_FORMAT_ANDROID_REGEX         @"%(\\d.?\\d?[$a-z])"
#define ZF_LANG_DIR_ANDROID_REGEX       @"/values-([a-z]{2})/"
#define ZF_LANG_DIR_ANDROID_            @"values-%@"
#define ZF_LANG_EXTENSION_ANDROID_      @"xml"

#endif
