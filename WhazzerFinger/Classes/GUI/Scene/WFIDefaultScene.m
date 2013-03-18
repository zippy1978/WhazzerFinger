//
//  WFIDefaultScene.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 18/03/13.
//
//

#import "WFIDefaultScene.h"

#define kHadwareOverlayiPhonePortraitImageDefault @"iPhone4PortraitBlackHardware"
#define kHadwareOverlayiPhoneLandscapeImageDefault @"iPhone4LandscapeBlackHardware"

#define kDefaultSceneWidth 1443
#define kDefaultSceneHeight 820

@implementation WFIDefaultScene

- (NSImage *)backgroundImageForDevice:(WFIDevice *)device orientation:(WFIDeviceOrientation)orientation
{
    CGFloat width = kDefaultSceneWidth;
    CGFloat height = kDefaultSceneHeight;
    CGFloat deviceWidth = device.width;
    CGFloat deviceHeight = device.height;
    CGFloat deviceScreenWidth = device.screenWidth;
    CGFloat deviceScreenHeight = device.screenHeight;
    if (orientation == kWFIDeviceOrientationLandscape) {
        deviceWidth = device.height;
        deviceHeight = device.width;
        deviceScreenWidth = device.screenHeight;
        deviceScreenHeight = device.screenWidth;
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [image lockFocus];
    [[NSColor whiteColor] set];
    NSRectFill(NSMakeRect(0, 0, width, height));
    NSRectFillUsingOperation(NSMakeRect((width / 2) - (deviceScreenWidth / 2), (height / 2) - (deviceScreenHeight / 2), deviceScreenWidth, deviceScreenHeight), NSCompositeClear);
    [image unlockFocus];
    
    return image;
}

- (NSImage *)hardwareOverlayImageForHardwareOverlay:(WFIDeviceHardwareOverlay *)hardwareOverlay orientation:(WFIDeviceOrientation)orientation
{
    NSImage *overlayImage = [NSImage imageNamed:hardwareOverlay.imageName];
    
    if (orientation == kWFIDeviceOrientationPortrait) {
        return overlayImage;
    } else {
        
        // Rotate image
        // Calculate the bounds for the rotated image
        // We do this by affine-transforming the bounds rectangle
        NSRect imageBounds = {NSZeroPoint, [overlayImage size]};
        NSBezierPath* boundsPath = [NSBezierPath bezierPathWithRect:imageBounds];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform rotateByDegrees:90];
        [boundsPath transformUsingAffineTransform:transform];
        NSRect rotatedBounds = {NSZeroPoint, [boundsPath bounds].size};
        NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedBounds.size];
        
        // Center the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2);
        imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2);
        
        // Start a new transform, to transform the image
        transform = [NSAffineTransform transform];
        
        // Move coordinate system to the center
        // (since we want to rotate around the center)
        [transform translateXBy:+(NSWidth(rotatedBounds) / 2)
                            yBy:+(NSHeight(rotatedBounds) / 2)];
        // Do the rotation
        [transform rotateByDegrees:90];
        // Move coordinate system back to normal (bottom, left)
        [transform translateXBy:-(NSWidth(rotatedBounds) / 2)
                            yBy:-(NSHeight(rotatedBounds) / 2)];
        
        // Draw the original image, rotated, into the new image
        // Note: This "drawing" is done off-screen.
        [rotatedImage lockFocus];
        [transform concat];
        [overlayImage drawInRect:imageBounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0] ;
        [rotatedImage unlockFocus];
        
        return rotatedImage;
    }
}

@end
