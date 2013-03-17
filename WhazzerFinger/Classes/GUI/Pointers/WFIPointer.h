//
//  WFIPointer.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kWFIPointerMouseStateDown,
    kWFIPointerMouseStateUp,
    kWFIPointerMouseStateMoved,
    kWFIPointerMouseStateDragged
} WFIPointerMouseState;

@protocol WFIPointer <NSObject>

- (NSImage *)imageForState:(WFIPointerMouseState)state;
- (CGSize)size;

@end
