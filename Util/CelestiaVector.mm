//
// CelestiaVector.mm
//
// Copyright © 2020 Celestia Development Team. All rights reserved.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//

#import "CelestiaVector+Private.h"

@interface CelestiaVector () {
    NSArray* _array;
}
@end

@implementation CelestiaVector (Private)

/*** Conversions to and from Eigen structures ***/

+(CelestiaVector*)vectorWithVector3f:(const Eigen::Vector3f&)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x()] y:[NSNumber numberWithFloat:v.y()] z:[NSNumber numberWithFloat:v.z()]];
}

+(CelestiaVector*)vectorWithVector3d:(const Eigen::Vector3d&)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithDouble:v.x()] y:[NSNumber numberWithDouble:v.y()] z:[NSNumber numberWithDouble:v.z()]];
}

+(CelestiaVector*)vectorWithQuaternionf:(const Eigen::Quaternionf&)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x()] y:[NSNumber numberWithFloat:v.y()] z:[NSNumber numberWithFloat:v.z()] w:[NSNumber numberWithFloat:v.w()]];
}

+(CelestiaVector*)vectorWithQuaterniond:(const Eigen::Quaterniond&)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithDouble:v.x()] y:[NSNumber numberWithDouble:v.y()] z:[NSNumber numberWithDouble:v.z()] w:[NSNumber numberWithDouble:v.w()]];
}

-(CelestiaVector*)initWithVector3f:(const Eigen::Vector3f&)v
{
    return [self initWithx:[NSNumber numberWithFloat:v.x()] y:[NSNumber numberWithFloat:v.y()] z:[NSNumber numberWithFloat:v.z()]];
}

-(CelestiaVector*)initWithVector3d:(const Eigen::Vector3d&)v
{
    return [self initWithx:[NSNumber numberWithDouble:v.x()] y:[NSNumber numberWithDouble:v.y()] z:[NSNumber numberWithDouble:v.z()]];
}

-(Eigen::Vector3f)vector3f
{
    return Eigen::Vector3f([[self x] floatValue],[[self y] floatValue],[[self z] floatValue]);
}

-(Eigen::Vector3d)vector3d
{
    return Eigen::Vector3d([[self x] doubleValue],[[self y] doubleValue],[[self z] doubleValue]);
}

-(Eigen::Quaternionf)quaternionf
{
    return Eigen::Quaternionf([[self w] floatValue],[[self x] floatValue],[[self y] floatValue],[[self z] floatValue]);
}

-(Eigen::Quaterniond)quaterniond
{
    return Eigen::Quaterniond([[self w] doubleValue],[[self x] doubleValue],[[self y] doubleValue],[[self z] doubleValue]);
}

/*** End Eigen conversions ***/


+(CelestiaVector*)vectorWithVec2f:(Vec2f)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y]];
}
+(CelestiaVector*)vectorWithPoint2f:(Point2f)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y]];
}
+(CelestiaVector*)vectorWithVec3f:(Vec3f)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y] z:[NSNumber numberWithFloat:v.z]];
}
+(CelestiaVector*)vectorWithPoint3f:(Point3f)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y] z:[NSNumber numberWithFloat:v.z]];
}
+(CelestiaVector*)vectorWithVec4f:(Vec4f)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y] z:[NSNumber numberWithFloat:v.z] w:[NSNumber numberWithFloat:v.w]];
}
+(CelestiaVector*)vectorWithVec3d:(Vec3d)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithDouble:v.x] y:[NSNumber numberWithDouble:v.y] z:[NSNumber numberWithDouble:v.z]];
}
+(CelestiaVector*)vectorWithPoint3d:(Point3d)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithDouble:v.x] y:[NSNumber numberWithDouble:v.y] z:[NSNumber numberWithDouble:v.z]];
}
+(CelestiaVector*)vectorWithVec4d:(Vec4d)v
{
    return [CelestiaVector vectorWithx:[NSNumber numberWithDouble:v.x] y:[NSNumber numberWithDouble:v.y] z:[NSNumber numberWithDouble:v.z] w:[NSNumber numberWithDouble:v.w]];
}

-(CelestiaVector*)initWithVec2f:(Vec2f)v
{
    return [self initWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y]];
}
-(CelestiaVector*)initWithVec3f:(Vec3f)v
{
    return [self initWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y] z:[NSNumber numberWithFloat:v.z]];
}
-(CelestiaVector*)initWithVec4f:(Vec4f)v
{
    return [self initWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y] z:[NSNumber numberWithFloat:v.z] w:[NSNumber numberWithFloat:v.w]];
}
-(CelestiaVector*)initWithVec3d:(Vec3d)v
{
    return [self initWithx:[NSNumber numberWithDouble:v.x] y:[NSNumber numberWithDouble:v.y] z:[NSNumber numberWithDouble:v.z]];
}
-(CelestiaVector*)initWithVec4d:(Vec4d)v
{
    return [self initWithx:[NSNumber numberWithDouble:v.x] y:[NSNumber numberWithDouble:v.y] z:[NSNumber numberWithDouble:v.z] w:[NSNumber numberWithDouble:v.w]];
}

-(Vec2f)vec2f
{
    return Vec2f([[self x] floatValue],[[self y] floatValue]);
}
-(Vec3f)vec3f
{
    return Vec3f([[self x] floatValue],[[self y] floatValue],[[self z] floatValue]);
}
-(Point2f)point2f
{
    return Point2f([[self x] floatValue],[[self y] floatValue]);
}
-(Point3f)point3f
{
    return Point3f([[self x] floatValue],[[self y] floatValue],[[self z] floatValue]);
}
-(Vec4f)vec4f
{
    return Vec4f([[self x] floatValue],[[self y] floatValue],[[self z] floatValue], [[self w] floatValue]);
}
-(Vec3d)vec3d
{
    return Vec3d([[self x] doubleValue],[[self y] doubleValue],[[self z] doubleValue]);
}
-(Point3d)point3d
{
    return Point3d([[self x] doubleValue],[[self y] doubleValue],[[self z] doubleValue]);
}
-(Vec4d)vec4d
{
    return Vec4d([[self x] doubleValue],[[self y] doubleValue],[[self z] doubleValue], [[self w] doubleValue]);
}
-(CelestiaVector*)initWithPoint2f:(Point2f)v
{
    return [self initWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y]];
}
-(CelestiaVector*)initWithPoint3d:(Point3d)v
{
    return [self initWithx:[NSNumber numberWithDouble:v.x] y:[NSNumber numberWithDouble:v.y] z:[NSNumber numberWithDouble:v.z]];
}
-(CelestiaVector*)initWithPoint3f:(Point3f)v
{
    return [self initWithx:[NSNumber numberWithFloat:v.x] y:[NSNumber numberWithFloat:v.y] z:[NSNumber numberWithFloat:v.z]];
}
@end

@implementation CelestiaVector
-(void)encodeWithCoder:(NSCoder*)coder
{
    //[super encodeWithCoder:coder];
    [coder encodeObject:_array];
}
-(id)initWithCoder:(NSCoder*)coder
{
    //self = [super initWithCoder:coder];
    self = [self init];
    _array = [coder decodeObject];
    return self;
}
+(CelestiaVector*)vectorWithArray:(NSArray*)v
{
    return [[CelestiaVector alloc] initWithArray:v];
}
+(CelestiaVector*)vectorWithx:(NSNumber*)x y:(NSNumber*)y
{
    return [[CelestiaVector alloc] initWithx:x y:y];
}
+(CelestiaVector*)vectorWithx:(NSNumber*)x y:(NSNumber*)y z:(NSNumber*)z
{
    return [[CelestiaVector alloc] initWithx:x y:y z:z];
}
+(CelestiaVector*)vectorWithx:(NSNumber*)x y:(NSNumber*)y z:(NSNumber*)z w:(NSNumber*)w
{
    return [[CelestiaVector alloc] initWithx:x y:y z:z w:w];
}
-(CelestiaVector*)initWithArray:(NSArray*)v
{
    self = [super init];
    _array = v;
    return self;
}
-(CelestiaVector*)initWithx:(NSNumber*)x y:(NSNumber*)y
{
    self = [super init];
    _array = [[NSArray alloc] initWithObjects:x,y,nil];
    return self;
}
-(CelestiaVector*)initWithx:(NSNumber*)x y:(NSNumber*)y z:(NSNumber*)z
{
    self = [super init];
    _array = [[NSArray alloc] initWithObjects:x,y,z,nil];
    return self;
}
-(CelestiaVector*)initWithx:(NSNumber*)x y:(NSNumber*)y z:(NSNumber*)z w:(NSNumber*)w
{
    self = [super init];
    _array = [[NSArray alloc] initWithObjects:x,y,z,w,nil];
    return self;
}
-(NSNumber*)x
{
    return [_array objectAtIndex:0];
}
-(NSNumber*)y
{
    return [_array objectAtIndex:1];
}
-(NSNumber*)z
{
    return [_array objectAtIndex:2];
}
-(NSNumber*)w
{
    return [_array objectAtIndex:3];
}
-(NSNumber*)objectAtIndex:(NSUInteger)index
{
    return [_array objectAtIndex:index];
}
-(NSUInteger)count
{
    return [_array count];
}


- (double)dx {
    return [[self x] doubleValue];
}

- (double)dy {
    return [[self y] doubleValue];
}

- (double)dz {
    return [[self z] doubleValue];
}

- (double)dw {
    return [[self w] doubleValue];
}

@end
