//
//  WFIDeviceHardwareOverlay.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 18/03/13.
//
//

#import <Foundation/Foundation.h>

@interface WFIDeviceHardwareOverlay : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *imageName;

+ (WFIDeviceHardwareOverlay *) hardwareOverlayWithDictionary:(NSDictionary *)dictionary;

@end
