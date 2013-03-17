//
//  WFISimFingerPointer.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WFISimFingerPointer.h"

@implementation WFISimFingerPointer {
    
    NSImage *_hoverImage;
    NSImage *_activeImage;
}

- (id)init {
    
    if (self = [super init])
    {
        _hoverImage = [NSImage imageNamed:@"SimFingerHoverPointer"];
        _activeImage = [NSImage imageNamed:@"SimFingerActivePointer"];
    }
    return self;
}

- (NSImage *)imageForState:(WFIPointerMouseState)state
{
    switch (state) {
        case kWFIPointerMouseStateDown:
            return _activeImage;
            break;
        
        default:
            return _hoverImage;
            break;
    }
}

- (CGSize)size
{
    return _hoverImage.size;
}

@end
