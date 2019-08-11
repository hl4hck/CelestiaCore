//
//  CelestiaUniverse.h
//  celestia
//
//  Created by Bob Ippolito on Fri Jun 07 2002.
//  Copyright (c) 2002 Chris Laurel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CelestiaSelection.h"
#import "CelestiaDSOCatalog.h"
#import "CelestiaStarCatalog.h"

NS_ASSUME_NONNULL_BEGIN

@interface CelestiaUniverse : NSObject

@property (readonly) CelestiaDSOCatalog *dsoCatalog;
@property (readonly) CelestiaStarCatalog *starCatalog;

- (CelestiaSelection *)find:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
