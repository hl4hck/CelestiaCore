//
//  CelestiaStar.mm
//  celestia
//
//  Created by Bob Ippolito on Sat Jun 08 2002.
//  Copyright (c) 2002 Chris Laurel. All rights reserved.
//

#import "CelestiaStar.h"
#import "CelestiaStar+Private.h"
#import "CelestiaObject+Private.h"
#import "CelestiaUniversalCoord+Private.h"
#import "CelestiaUtil.h"

@implementation CelestiaStar(Private)

- (instancetype)initWithStar:(Star *)star
{
    self = [super initWithObject:reinterpret_cast<AstroObject *>(star)];
    return self;
}

- (Star *)star {
    return reinterpret_cast<Star *>([self object]);
}

@end
/* 
    inline StellarClass getStellarClass() const;
    void setStellarClass(StellarClass);
*/
@implementation CelestiaStar

- (float)radius {
    return [self star]->getRadius();
}

- (float)apparentMagnitude:(float)m {
    return [self star]->getApparentMagnitude(m);
}

- (void)setAbsoluteMagnitude:(float)m {
    [self star]->setAbsoluteMagnitude(m);
}

- (float)luminosity {
    return [self star]->getLuminosity();
}

- (float)temperature {
    return [self star]->getTemperature();
}

- (void)setLuminosity:(float)luminosity {
    [self star]->setLuminosity(luminosity);
}

- (NSString *)webInfoURL {
    return [NSString stringWithUTF8String:[self star]->getInfoURL().c_str()];
}

- (CelestiaUniversalCoord *)positionAtTime:(NSDate *)time {
    return [[CelestiaUniversalCoord alloc] initWithUniversalCoord:[self star]->getPosition([time julianDay])];
}

@end
