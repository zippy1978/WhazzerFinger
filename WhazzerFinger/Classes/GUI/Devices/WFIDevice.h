//
//  WFIDevice.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 18/03/13.
//
//

#import <Foundation/Foundation.h>

#define kDevicesPList @"Devices"

typedef enum {
    kWFIDeviceOrientationPortrait,
    kWFIDeviceOrientationLandscape
} WFIDeviceOrientation;

@interface WFIDevice : NSObject

@property (copy, nonatomic) NSString *name;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

@property (strong, nonatomic) NSArray *hardwareOverlays;

+ (WFIDevice *)deviceWithName:(NSString *)name;
+ (WFIDevice *)deviceWithMatchingWidth:(NSInteger)width height:(NSInteger)height;

@end
