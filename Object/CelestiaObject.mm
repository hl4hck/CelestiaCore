//
//  CelestiaObject.m
//  CelestiaCore
//
//  Created by 李林峰 on 2019/8/10.
//  Copyright © 2019 李林峰. All rights reserved.
//

#import "CelestiaObject.h"
#import "CelestiaObject+Private.h"

@interface CelestiaObject () {
    AstroObject *c;
}
@end

@implementation CelestiaObject (Private)

- (instancetype)initWithObject:(AstroObject *)object {
    self = [super init];
    if (self) {
        c = object;
    }
    return self;
}

- (AstroObject *)object {
    return c;
}

@end

@implementation CelestiaObject

@end
