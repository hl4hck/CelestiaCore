//
//  CelestiaUtil.mm
//  celestia
//
//  Created by Bob Ippolito on Fri Jun 07 2002.
//  Copyright (C) 2001-9, the Celestia Development Team
//

#include <celengine/astro.h>
#include <celengine/observer.h>

#import "CelestiaUtil.h"
#import "CelestiaVector+Private.h"

NSDictionary* coordinateDict;

@implementation NSDate (Astro)

- (double)julianDay {
    NSTimeZone *prevTimeZone = [NSTimeZone defaultTimeZone];
    // UTCtoTDB() expects GMT
    [NSTimeZone setDefaultTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
    NSDate *roundedDate = nil;

    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *comps = [currentCalendar components:
                               NSEraCalendarUnit  |
                               NSYearCalendarUnit | NSMonthCalendarUnit  | NSDayCalendarUnit |
                               NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                 fromDate: self];
    int era  = (int)[comps era];
    int year = (int)[comps year];
    if (era < 1) year = 1 - year;
    astro::Date astroDate(year, (int)[comps month], (int)[comps day]);
    astroDate.hour    = (int)[comps hour];
    astroDate.minute  = (int)[comps minute];
    astroDate.seconds = (int)[comps second];
    // -[NSDateComponents second] is rounded to an integer,
    // so have to calculate and add decimal part
    roundedDate = [currentCalendar dateFromComponents: comps];

    NSTimeInterval extraSeconds = [self timeIntervalSinceDate: roundedDate];
    astroDate.seconds += extraSeconds;

    [NSTimeZone setDefaultTimeZone: prevTimeZone];
    double jd = astro::UTCtoTDB(astroDate);
    return jd;
}

+ (instancetype)dateWithJulian:(double)jd {
    astro::Date astroDate(jd);
    int year = astroDate.year;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    [currentCalendar setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    int era = 1;
    if (year < 1)
    {
        era  = 0;
        year = 1 - year;
    }
    [comps setEra:    era];
    [comps setYear:   year];
    [comps setMonth:  astroDate.month];
    [comps setDay:    astroDate.day];
    [comps setHour:   astroDate.hour];
    [comps setMinute: astroDate.minute];
    [comps setSecond: (int)astroDate.seconds];
    return [currentCalendar dateFromComponents: comps];
}

@end


@implementation Astro

+ (NSString *)stringWithCoordinateSystem:(int)n;
{
    NSArray* keys = [coordinateDict allKeys];
    unsigned int i;
    for (i=0;i<[keys count];i++) {
        if ([[coordinateDict objectForKey:[keys objectAtIndex:i]] integerValue] == n)
            return [keys objectAtIndex:i];
    }
    return nil;
}

+ (void)initialize {
    // compiler macro would be prettier I guess
    coordinateDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithInt:ObserverFrame::Universal],  @"Universal",
                       [NSNumber numberWithInt:ObserverFrame::Ecliptical], @"Ecliptical",
                       [NSNumber numberWithInt:ObserverFrame::Equatorial], @"Equatorial",
                       [NSNumber numberWithInt:ObserverFrame::BodyFixed],  @"Geographic",
                       [NSNumber numberWithInt:ObserverFrame::ObserverLocal], @"ObserverLocal",
                       [NSNumber numberWithInt:ObserverFrame::PhaseLock],  @"PhaseLock",
                       [NSNumber numberWithInt:ObserverFrame::Chase],      @"Chase",
                       nil];
}

+ (int)coordinateSystem:(NSString *)coord {
    return [[coordinateDict objectForKey:coord] intValue];
}

+ (double)speedOfLight {
    return astro::speedOfLight;
}

+ (double)J2000 {
    return astro::J2000;
}

+ (double)G {
    return astro::G;
}

+ (double)solarMass {
    return astro::SolarMass;
}

+ (double)earthMass {
    return astro::EarthMass;
}

+ (float)lumToAbsMag:(float)lum {
    return astro::lumToAbsMag(lum);
}

+ (float)lumToAppMag:(float)lum lightYears:(float)lyrs {
    return astro::lumToAppMag(lum, lyrs);
}

+ (float)absMagToLum:(float)mag {
    return astro::absMagToLum(mag);
}

+ (float)absToAppMag:(float)mag lightYears:(float)lyrs {
    return astro::absToAppMag(mag, lyrs);
}
+ (float)appToAbsMag:(float)mag lightYears:(float)lyrs {
    return astro::appToAbsMag(mag, lyrs);
}

+ (float)lightYearsToParsecs:(float)ly {
    return astro::lightYearsToParsecs(ly);
}
+ (float)parsecsToLightYears:(float)pc {
    return astro::parsecsToLightYears(pc);
}

+ (double)lightYearsToKilometers:(double)ly {
    return astro::lightYearsToKilometers(ly);
}

+ (double)kilometersToLightYears:(double)km {
    return astro::kilometersToLightYears(km);
}

+ (double)lightYearsToAU:(double)ly {
    return astro::lightYearsToAU(ly);
}

+ (double)AUtoLightYears:(double)au {
    return astro::AUtoLightYears(au);
}

+ (double)kilometersToAU:(double)km {
    return astro::kilometersToAU(km);
}

+ (double)AUtoKilometers:(double)au {
    return astro::AUtoKilometers(au);
}

+ (double)microLightYearsToKilometers:(double)mly {
    return astro::microLightYearsToKilometers(mly);
}

+ (double)kilometersToMicroLightYears:(double)km {
    return astro::kilometersToMicroLightYears(km);
}

+ (double)microLightYearsToAU:(double)mly {
    return astro::microLightYearsToAU(mly);
}

+ (double)AUtoMicroLightYears:(double)au {
    return astro::AUtoMicroLightYears(au);
}

+ (double)secondsToJulianDate:(double)sec {
    return astro::secondsToJulianDate(sec);
}

+ (double)julianDateToSeconds:(double)jd {
    return astro::julianDateToSeconds(jd);
}

+ (NSArray<NSNumber *> *)decimalToDegMinSec:(double)angle {
    int hours, minutes;
    double seconds;
    astro::decimalToDegMinSec(angle, hours, minutes, seconds);
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:hours], [NSNumber numberWithInt:minutes], [NSNumber numberWithDouble:seconds], nil];
}

+ (double)degMinSecToDecimal:(NSArray<NSNumber *> *)dms {
    return astro::degMinSecToDecimal([[dms objectAtIndex:0] intValue], [[dms objectAtIndex:1] intValue], [[dms objectAtIndex:2] intValue]);
}

+ (NSArray<NSNumber *> *)anomaly:(double)meanAnamaly eccentricity:(double)eccentricity {
    double trueAnomaly,eccentricAnomaly;
    astro::anomaly(meanAnamaly, eccentricity, trueAnomaly, eccentricAnomaly);
    return [NSArray arrayWithObjects:[NSNumber numberWithDouble:trueAnomaly], [NSNumber numberWithDouble:eccentricAnomaly], nil];
}

+ (double)meanEclipticObliquity:(double)jd {
    return astro::meanEclipticObliquity(jd);
}

+ (CelestiaVector *)celToJ2000Ecliptic:(CelestiaVector *)cel {
    Eigen::Vector3d p = [cel vector3d];
    return [CelestiaVector vectorWithVector3d:Eigen::Vector3d(p.x(), -p.z(), p.y())];
}

+ (CelestiaVector *)rectToSpherical:(CelestiaVector *)rect {
    Eigen::Vector3d v = [rect vector3d];
    double r = v.norm();
    double theta = atan2(v.y(), v.x());
    if (theta < 0)
        theta = theta + 2 * PI;
    double phi = asin(v.z() / r);

    return [CelestiaVector vectorWithVector3d:Eigen::Vector3d(theta, phi, r)];
}

@end