//
//  CelestiaCatalog+Private.h
//  CelestiaCore
//
//  Created by 李林峰 on 2019/8/10.
//  Copyright © 2019 李林峰. All rights reserved.
//

#import "CelestiaCatalog.h"
#include "celengine/astrodb.h"

NS_ASSUME_NONNULL_BEGIN

@interface CelestiaCatalog (Private)

- (instancetype)initWithDatabase:(AstroDatabase *)database;

- (AstroDatabase *)database;

@end

NS_ASSUME_NONNULL_END
