//
// CelestiaSimulation.mm
//
// Copyright © 2020 Celestia Development Team. All rights reserved.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//

#import "CelestiaSimulation.h"
#import "CelestiaSimulation+Private.h"
#import "CelestiaSelection+Private.h"
#import "CelestiaUniverse+Private.h"
#import "CelestiaObserver+Private.h"
#import "CelestiaUniversalCoord+Private.h"
#import "CelestiaVector+Private.h"
#import "CelestiaUtil.h"
#import "CelestiaPlanetarySystem.h"
#import "CelestiaEclipseFinder.h"
#import "CelestiaBody.h"
#import "CelestiaStar.h"

#include "celmath/geomutil.h"

using namespace celmath;

typedef NS_OPTIONS(NSUInteger, CelestiaGoToLocationFieldMask) {
    CelestiaGoToLocationFieldMaskLongitude = 1 << 0,
    CelestiaGoToLocationFieldMaskLatitude = 1 << 1,
    CelestiaGoToLocationFieldMaskDistance = 1 << 2,
};

@implementation CelestiaGoToLocation {
@public
    CelestiaGoToLocationFieldMask fieldMask;
}

- (instancetype)initWithSelection:(CelestiaSelection *)selection longitude:(double)longitude latitude:(double)latitude distance:(double)distance unit:(SimulationDistanceUnit)unit validMask:(CelestiaGoToLocationFieldMask)mask {
    self = [super init];
    if (self) {
        fieldMask = mask;
        _selection = selection;
        _longitude = longitude;
        _latitude = latitude;

        switch (unit) {
            case SimulationDistanceUnitKM:
                _distance = distance;
                break;
            case SimulationDistanceUnitAU:
                _distance = [Astro AUtoKilometers:distance];
                break;
            case SimulationDistanceUnitRadii:
            default:
                _distance = [selection radius] * distance;
                break;
        }
    }
    return self;
}

- (instancetype)initWithSelection:(CelestiaSelection *)selection longitude:(double)longitude latitude:(double)latitude distance:(double)distance unit:(SimulationDistanceUnit)unit {
    return [self initWithSelection:selection longitude:longitude latitude:latitude distance:distance unit:unit validMask:CelestiaGoToLocationFieldMaskLongitude | CelestiaGoToLocationFieldMaskLatitude | CelestiaGoToLocationFieldMaskDistance];
}

- (instancetype)initWithSelection:(CelestiaSelection *)selection longitude:(double)longitude latitude:(double)latitude {
    return [self initWithSelection:selection longitude:longitude latitude:latitude distance:0 unit:SimulationDistanceUnitKM validMask:CelestiaGoToLocationFieldMaskLongitude | CelestiaGoToLocationFieldMaskLatitude];
}

- (instancetype)initWithSelection:(CelestiaSelection *)selection distance:(double)distance unit:(SimulationDistanceUnit)unit {
    return [self initWithSelection:selection longitude:0 latitude:0 distance:distance unit:unit validMask:CelestiaGoToLocationFieldMaskDistance];
}

- (instancetype)initWithSelection:(CelestiaSelection *)selection {
    return [self initWithSelection:selection longitude:0 latitude:0 distance:0 unit:SimulationDistanceUnitKM validMask:0];
}

@end

@interface CelestiaSimulation () {
    Simulation *s;

    CelestiaUniverse *_universe;
}

@end

@implementation CelestiaSimulation (Private)

- (instancetype)initWithSimulation:(Simulation *)sim {
    self = [super init];
    if (self) {
        s = sim;

        _universe = nil;
    }
    return self;
}

- (Simulation *)simulation {
    return s;
}

@end

@implementation CelestiaSimulation

- (CelestiaSelection *)selection {
    return [[CelestiaSelection alloc] initWithSelection:s->getSelection()];
}

- (void)setSelection:(CelestiaSelection *)selection {
    s->setSelection([selection selection]);
}

- (NSDate *)time {
    return [NSDate dateWithJulian:s->getTime()];
}

- (void)setTime:(NSDate *)time {
    s->setTime([time julianDay]);
}

- (CelestiaObserver *)activeObserver {
    return [[CelestiaObserver alloc] initWithObserver:s->getActiveObserver()];
}

- (CelestiaGoToLocation *)currentLocation {
    CelestiaSelection *sel = [self selection];
    if ([sel isEmpty]) {
        return nil;
    }
    double distance, longitude, latitude;
    s->getSelectionLongLat(distance, longitude, latitude);
    return [[CelestiaGoToLocation alloc] initWithSelection:sel longitude:longitude latitude:latitude distance:distance unit:SimulationDistanceUnitKM];
}

- (CelestiaUniverse *)universe {
    if (!_universe) {
        _universe = [[CelestiaUniverse alloc] initWithUniverse:s->getUniverse()];
    }
    return _universe;
}

- (CelestiaSelection *)findObjectFromPath:(NSString *)path {
    return [[CelestiaSelection alloc] initWithSelection:[self simulation]->findObject([path UTF8String], true)];
}

- (void)setFrame:(SimulationCoordinateSystem)coordinate target:(CelestiaSelection *)target reference:(CelestiaSelection *)reference {
    const Selection ref([reference selection]);
    const Selection tar([target selection]);
    s->setFrame((ObserverFrame::CoordinateSystem)coordinate, ref, tar);
}

- (void)reverseObserverOrientation {
    s->reverseObserverOrientation();
}

- (void)update:(NSTimeInterval)seconds {
    s->update(seconds);
}

- (void)goToLocation:(CelestiaGoToLocation *)location {
    [self setSelection:location.selection];
    [self simulation]->geosynchronousFollow();
    double distance = location.selection.radius * 5;
    if (location->fieldMask & CelestiaGoToLocationFieldMaskDistance) {
        distance = location.distance;
    }

    CelestiaVector *up = [CelestiaVector vectorWithx:[NSNumber numberWithFloat:0.0] y:[NSNumber numberWithFloat:1.0] z:[NSNumber numberWithFloat:0.0]];
    if (location->fieldMask & CelestiaGoToLocationFieldMaskLongitude && location->fieldMask & CelestiaGoToLocationFieldMaskLatitude) {
        s->gotoSelectionLongLat(5, distance, (float)location.longitude * M_PI / 180.0, (float)location.latitude * M_PI / 180.0, [up vector3f]);
    } else {
        s->gotoSelection(5, distance, [up vector3f], (ObserverFrame::CoordinateSystem)[Astro coordinateSystem:@"ObserverLocal"]);
    }
}

- (void)goToEclipse:(CelestiaEclipse *)eclipse {
    CelestiaStar *star = [[[eclipse receiver] system] star];
    if (!star)
        return;

    CelestiaSelection *target = [[CelestiaSelection alloc] initWithObject:[eclipse receiver]];
    CelestiaSelection *ref = [[CelestiaSelection alloc] initWithObject:star];

    if (!target || !ref)
        return;

    s->setTime(eclipse.startTime.julianDay);
    s->setFrame(ObserverFrame::PhaseLock, [target selection], [ref selection]);
    s->update(0);
    double distance = [target radius] * 4.0;
    s->gotoLocation(UniversalCoord::Zero().offsetKm(Eigen::Vector3d::UnitX() * distance),
                      YRotation(-0.5 * PI) * XRotation(-0.5 * PI),
                      2.5);
}

- (NSArray<NSString *> *)completionForName:(NSString *)name {
    std::vector<std::string> names = s->getObjectCompletion([name UTF8String]);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:names.size()];
    for (int i = 0; i < names.size(); i++) {
        [array addObject:[NSString stringWithUTF8String:names[i].c_str()]];
    }
    return array;
}

@end
