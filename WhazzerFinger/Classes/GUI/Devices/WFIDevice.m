//
//  WFIDevice.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 18/03/13.
//
//

#import "WFIDevice.h"
#import "WFIDeviceHardwareOverlay.h"

@implementation WFIDevice

@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize screenWidth = _screenWidth;
@synthesize screenHeight = _screenHeight;
@synthesize hardwareOverlays = _hardwareOverlays;

+ (WFIDevice *)deviceWithName:(NSString *)name
{
    WFIDevice *device = nil;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDevicesPList ofType:@"plist"]];
    NSDictionary *deviceData = [dictionary objectForKey:name];
    
    if (deviceData) {
        device = [[WFIDevice alloc] init];
        device.name = name;
        device.width =  [((NSNumber *)[deviceData objectForKey:@"Width"]) integerValue];
        device.height =  [((NSNumber *)[deviceData objectForKey:@"Height"]) integerValue];
        device.screenWidth = [((NSNumber *)[deviceData objectForKey:@"ScreenWidth"]) integerValue];
        device.screenHeight = [((NSNumber *)[deviceData objectForKey:@"ScreenHeight"]) integerValue];
        
        NSMutableArray *hardwareOverlays = [NSMutableArray array];
        
        NSArray *array = [deviceData objectForKey:@"HardwareOverlays"];
        for (NSDictionary *dict in array) {
            [hardwareOverlays addObject:[WFIDeviceHardwareOverlay hardwareOverlayWithDictionary:dict]];
        }
        
        device.hardwareOverlays = hardwareOverlays;
    }
    
    return device;

}

+ (WFIDevice *)deviceWithMatchingWidth:(NSInteger)width height:(NSInteger)height
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDevicesPList ofType:@"plist"]];
    for (NSString *key in dictionary) {
        WFIDevice *device = [WFIDevice deviceWithName:key];
        if (device.width == width && device.height == height) {
            return device;
        }
    }
    
    return nil;
}

@end
