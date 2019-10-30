//
//  CelestiaCatEntry+Private.h
//  CelestiaCore
//
//  Created by 李林峰 on 2019/8/10.
//  Copyright © 2019 李林峰. All rights reserved.
//

#import "CelestiaCatEntry.h"
#include <celengine/astroobj.h>

NS_ASSUME_NONNULL_BEGIN

@interface CelestiaCatEntry (Private)

- (instancetype)initWithCatEntry:(AstroObject *)entry;
- (AstroObject *)entry;

@end

NS_ASSUME_NONNULL_END
