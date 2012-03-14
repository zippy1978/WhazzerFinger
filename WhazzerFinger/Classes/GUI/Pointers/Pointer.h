//
//  Pointer.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kPointerMouseStateDown,
    kPointerMouseStateUp,
    kPointerMouseStateMoved,
    kPointerMouseStateDragged
} PointerMouseState;

@protocol Pointer <NSObject>

- (NSImage *)imageForState:(PointerMouseState)state;
- (CGSize)size;

@end
