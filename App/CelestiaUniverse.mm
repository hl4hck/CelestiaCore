//
//  CelestiaUniverse.mm
//  celestia
//
//  Created by Bob Ippolito on Fri Jun 07 2002.
//  Copyright (c) 2002 Chris Laurel. All rights reserved.
//

#import "CelestiaUniverse.h"
#import "CelestiaSelection+Private.h"
#import "CelestiaUniverse+Private.h"
#import "CelestiaCatalog+Private.h"

@interface CelestiaUniverse () {
    Universe *u;
}

@end

@implementation CelestiaUniverse (Private)

- (instancetype)initWithUniverse:(Universe *)uni {
    self = [super init];
    if (self) {
        u = uni;
    }
    return self;
}

- (Universe *)universe {
    return u;
}

@end

@implementation CelestiaUniverse

- (CelestiaSelection *)find:(NSString *)name {
    return [[CelestiaSelection alloc] initWithSelection:u->find([name UTF8String])];
}

- (NSString *)nameForSelection:(CelestiaSelection *)selection {
    const Selection sel = [selection selection];
    switch (sel.getType()) {
        case Selection::Type_Star:
            return [NSString stringWithUTF8String:u->getDatabase().getObjectName(sel.star(), true).c_str()];
        case Selection::Type_Body:
            return [NSString stringWithUTF8String:sel.body()->getName(true).c_str()];
        case Selection::Type_DeepSky:
            return [NSString stringWithUTF8String:u->getDatabase().getObjectName(sel.deepsky(), true).c_str()];
        case Selection::Type_Location:
            return [NSString stringWithUTF8String:sel.location()->getName(true).c_str()];
        default:
            return @"";
    }
}

- (CelestiaCatalog *)catalog {
    return [[CelestiaCatalog alloc] initWithDatabase:&u->getDatabase()];
}

- (BOOL)isSelectionMarked:(CelestiaSelection *)selection {
    return (BOOL)u->isMarked([selection selection], 1);
}

- (void)markSelection:(CelestiaSelection *)selection withMarker:(CelestiaMarkerRepresentation)marker {
    u->markObject([selection selection], MarkerRepresentation(MarkerRepresentation::Symbol(marker), 10.0f, Color(0.0f, 1.0f, 0.0f, 0.9f)), 1);
}

- (void)unmarkSelection:(CelestiaSelection *)selection {
    u->unmarkObject([selection selection], 1);
}

@end
