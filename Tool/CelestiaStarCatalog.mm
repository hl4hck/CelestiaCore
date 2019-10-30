//
//  CelestiaStarCatalog.m
//  CelestiaCore
//
//  Created by 李林峰 on 2019/8/10.
//  Copyright © 2019 李林峰. All rights reserved.
//

#import "CelestiaStarCatalog+Private.h"
#import "CelestiaStar+Private.h"
#import "CelestiaDSO+Private.h"

@interface CelestiaStarCatalog () {
    AstroDatabase *d;
}

@end

@implementation CelestiaStarCatalog (Private)

- (instancetype)initWithDatabase:(AstroDatabase *)database {
    self = [super init];
    if (self) {
        d = database;
    }
    return self;
}

- (AstroDatabase *)database {
    return d;
}

@end

@implementation CelestiaStarCatalog

- (NSInteger)count {
    return d->size();
}

- (CelestiaStar *)starAtIndex:(NSInteger)index {
    return [[CelestiaStar alloc] initWithStar:d->getStar((uint32_t)index)];
}

- (CelestiaDSO *)dsoAtIndex:(NSInteger)index {
    return [[CelestiaDSO alloc] initWithDSO:d->getDSO((uint32_t)index)];
}

- (NSString *)starName:(CelestiaStar *)star {
    return [NSString stringWithUTF8String:d->getObjectName([star star]).c_str()];
}

- (NSString *)dsoName:(CelestiaDSO *)dso {
    return [NSString stringWithUTF8String:d->getObjectName([dso DSO]).c_str()];
}

- (NSArray<NSString *> *)completionForName:(NSString *)name NS_SWIFT_NAME(completion(for:)) {
    std::vector<Name> names = d->getCompletion([name UTF8String]);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:names.size()];
    for (int i = 0; i < names.size(); i++) {
        [array addObject:[NSString stringWithUTF8String:names[i].c_str()]];
    }
    return array;
}

@end
