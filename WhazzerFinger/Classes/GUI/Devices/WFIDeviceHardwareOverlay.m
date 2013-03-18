//
//  WFIDeviceHardwareOverlay.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 18/03/13.
//
//

#import "WFIDeviceHardwareOverlay.h"

@implementation WFIDeviceHardwareOverlay

@synthesize name = _name;
@synthesize imageName = _imageName;

+ (WFIDeviceHardwareOverlay *) hardwareOverlayWithDictionary:(NSDictionary *)dictionary
{
    WFIDeviceHardwareOverlay *hardwareOverlay = [[WFIDeviceHardwareOverlay alloc] init];
    
    hardwareOverlay.name = [dictionary objectForKey:@"Name"];
    hardwareOverlay.imageName = [dictionary objectForKey:@"Image"];
    
    return hardwareOverlay;
}

@end
