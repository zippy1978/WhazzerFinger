//
//  WFIDefaultPointer.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 29/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WFIDefaultPointer.h"

@implementation WFIDefaultPointer {
    
    NSImage *_hoverImage;
    NSImage *_activeImage;
    
    NSImage *_currentImage;
}

- (id)init {
    
    if (self = [super init])
    {
        _hoverImage = [NSImage imageNamed:@"DefaultHoverPointer"];
        _activeImage = [NSImage imageNamed:@"DefaultActivePointer"];
        _currentImage = _hoverImage;
    }
    return self;
}

- (NSImage *)imageForState:(WFIPointerMouseState)state
{
    switch (state) {
        case kWFIPointerMouseStateDown:
            _currentImage = _activeImage;
            return _activeImage;
            break;
            
        case kWFIPointerMouseStateUp:
            _currentImage = _hoverImage;
            return _hoverImage;
            break;
            
        default:
            return _currentImage;
            break;
    }
}

- (CGSize)size
{
    return _hoverImage.size;
}

@end
