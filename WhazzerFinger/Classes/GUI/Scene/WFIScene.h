//
//  WFIScene.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 18/03/13.
//
//

#import <Foundation/Foundation.h>
#import "WFIDevice.h"
#import "WFIDeviceHardwareOverlay.h"

@protocol WFIScene <NSObject>

- (NSImage *)backgroundImageForDevice:(WFIDevice *)device orientation:(WFIDeviceOrientation)orientation;
- (NSImage *)hardwareOverlayImageForHardwareOverlay:(WFIDeviceHardwareOverlay *)hardwareOverlay orientation:(WFIDeviceOrientation)orientation;

@end
