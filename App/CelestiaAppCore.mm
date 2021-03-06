//
// CelestiaAppCore.mm
//
// Copyright © 2020 Celestia Development Team. All rights reserved.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//

#include <celengine/glsupport.h>

#import "CelestiaAppCore+Private.h"
#import "CelestiaAppCore+Setting.h"
#import "CelestiaSimulation+Private.h"

#import "CelestiaSelection+Private.h"

#import "CelestiaUtil.h"

#include <celutil/gettext.h>
#include <celestia/url.h>
#include <celestia/oggtheoracapture.h>

class AppCoreProgressWatcher: public ProgressNotifier
{
public:
    AppCoreProgressWatcher(void (^block)(NSString *)) : ProgressNotifier(), block(block) {};

    void update(const std::string& status) {
        @autoreleasepool {
            block([NSString stringWithUTF8String:status.c_str()]);
        }
    }
private:
    void (^block)(NSString *);
};

class AppCoreAlerter: public CelestiaCore::Alerter
{
public:
    AppCoreAlerter(void (^block)(NSString *)) : CelestiaCore::Alerter(), block(block) {};

    void fatalError(const std::string &error)
    {
        @autoreleasepool {
            block([NSString stringWithUTF8String:error.c_str()]);
        }
    }
private:
    void (^block)(NSString *);
};

class AppCoreCursorHandler: public CelestiaCore::CursorHandler
{
public:
    AppCoreCursorHandler(void (^block)(CursorShape)) : CelestiaCore::CursorHandler(), block(block), shape(CelestiaCore::ArrowCursor) {};

    void setCursorShape(CelestiaCore::CursorShape shape)
    {
        CelestiaCore::CursorShape oldShape = this->shape;
        if (oldShape != shape)
        {
            this->shape = shape;
            @autoreleasepool {
                block((CursorShape)shape);
            }
        }
    }

    CelestiaCore::CursorShape getCursorShape() const
    {
        return shape;
    }
private:
    void (^block)(CursorShape);
    CelestiaCore::CursorShape shape;
};

class AppCoreContextMenuHandler: public CelestiaCore::ContextMenuHandler
{
public:
    AppCoreContextMenuHandler(void (^block)(CGPoint, CelestiaSelection *)) : CelestiaCore::ContextMenuHandler(), block(block) {};

    void requestContextMenu(float x, float y, Selection sel)
    {
        @autoreleasepool {
            CelestiaSelection *selection = [[CelestiaSelection alloc] initWithSelection:sel];
            block(CGPointMake(x, y), selection);
        }
    }
private:
    void (^block)(CGPoint, CelestiaSelection *);
};

class AppCoreWatcher: public CelestiaWatcher
{
public:
    AppCoreWatcher(CelestiaCore& watched, void (^block)(CelestiaWatcherFlag)) : CelestiaWatcher(watched), block(block) {}

    void notifyChange(CelestiaCore *, int change)
    {
        @autoreleasepool {
            block((CelestiaWatcherFlag)change);
        }
    }
private:
    void (^block)(CelestiaWatcherFlag);
};

@interface CelestiaAppCore () {
    AppCoreAlerter *alerter;
    AppCoreCursorHandler *cursorHandler;
    AppCoreContextMenuHandler *contextMenuHandler;
    AppCoreWatcher *watcher;

    CelestiaSimulation *_simulation;
}

@end

@implementation CelestiaAppCore

// MARK: Initilalization
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _initialized = NO;
        _simulation = nil;
        core = new CelestiaCore;
        __weak CelestiaAppCore *weakSelf = self;
        alerter = new AppCoreAlerter(^(NSString *error) {
            [[weakSelf delegate] celestiaAppCoreFatalErrorHappened:error];
        });
        cursorHandler = new AppCoreCursorHandler(^(CursorShape shape) {
            [[weakSelf delegate] celestiaAppCoreCursorShapeChanged:shape];
        });
        contextMenuHandler = new AppCoreContextMenuHandler(^(CGPoint location, CelestiaSelection *selection) {
            [[weakSelf delegate] celestiaAppCoreCursorDidRequestContextMenuAtPoint:location withSelection:selection];
        });
        core->setAlerter(alerter);
        core->setCursorHandler(cursorHandler);
        core->setContextMenuHandler(contextMenuHandler);
        watcher = new AppCoreWatcher(*core, ^(CelestiaWatcherFlag changedFlag) {
            [[weakSelf delegate] celestiaAppCoreWatchedFlagDidChange:changedFlag];
        });
        [self initializeSetting];
    }
    return self;
}

+ (BOOL)initGL {
    return (BOOL)celestia::gl::init();
}

- (BOOL)startSimulationWithConfigFileName:(NSString *)configFileName extraDirectories:(NSArray<NSString *> *)extraDirectories progressReporter:(void (^)(NSString *))reporter {

    AppCoreProgressWatcher watcher(reporter);

    std::string configFile = configFileName == nil ? "" : [configFileName UTF8String];
    __block std::vector<fs::path> extras;
    [extraDirectories enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        extras.push_back([obj UTF8String]);
    }];

    bool success = core->initSimulation(configFile, extras, &watcher);
    if (success) {
        _initialized = YES;
    }
    return _initialized;
}

- (BOOL)startRenderer {
    BOOL success = core->initRenderer() ? YES : NO;

    // start with default values
    const int DEFAULT_ORBIT_MASK = Body::Planet | Body::Moon | Body::Stellar;
    const int DEFAULT_LABEL_MODE = 2176;
    const float DEFAULT_AMBIENT_LIGHT_LEVEL = 0.1f;
    const float DEFAULT_VISUAL_MAGNITUDE = 8.0f;
    const Renderer::StarStyle DEFAULT_STAR_STYLE = Renderer::FuzzyPointStars;
    const ColorTableType DEFAULT_STARS_COLOR = ColorTable_Blackbody_D65;
    const unsigned int DEFAULT_TEXTURE_RESOLUTION = medres;

    core->getRenderer()->setRenderFlags(Renderer::DefaultRenderFlags);
    core->getRenderer()->setOrbitMask(DEFAULT_ORBIT_MASK);
    core->getRenderer()->setLabelMode(DEFAULT_LABEL_MODE);
    core->getRenderer()->setAmbientLightLevel(DEFAULT_AMBIENT_LIGHT_LEVEL);
    core->getRenderer()->setStarStyle(DEFAULT_STAR_STYLE);
    core->getRenderer()->setResolution(DEFAULT_TEXTURE_RESOLUTION);
    core->getRenderer()->setStarColorTable(GetStarColorTable(DEFAULT_STARS_COLOR));

    core->getSimulation()->setFaintestVisible(DEFAULT_VISUAL_MAGNITUDE);

    core->getRenderer()->setSolarSystemMaxDistance((core->getConfig()->SolarSystemMaxDistance));

    return success;
}

- (void)setDPI:(NSInteger)dpi {
    core->setScreenDpi((int)dpi);
}

- (void)setStartURL:(NSString *)startURL {
    if (!startURL)
        core->setStartURL("");
    else
        core->setStartURL([startURL UTF8String]);
}

- (void)start {
    core->start();
}

- (void)start:(NSDate *)date {
    core->start([date julianDay]);
}

// MARK: Drawing

- (NSUInteger)aaSamples {
    return core->getConfig()->aaSamples;
}

- (void)draw {
    core->draw();
}

- (void)tick {
    core->tick();
}

- (void)resize:(CGSize)size {
    core->resize(size.width, size.height);
}

- (void)setSafeAreaInsetsWithLeft:(CGFloat)left top:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom {
    core->setSafeAreaInsets(left, top, right, bottom);
}

- (void)setFont:(NSString *)fontPath collectionIndex:(NSInteger)collectionIndex fontSize:(NSInteger)fontSize {
    core->setFont([fontPath UTF8String], collectionIndex, fontSize);
}

- (void)setTitleFont:(NSString *)fontPath collectionIndex:(NSInteger)collectionIndex fontSize:(NSInteger)fontSize {
    core->setTitleFont([fontPath UTF8String], collectionIndex, fontSize);
}

- (void)setRendererFont:(NSString *)fontPath collectionIndex:(NSInteger)collectionIndex fontSize:(NSInteger)fontSize fontStyle:(RendererFontStyle)fontStyle {
    core->setRendererFont([fontPath UTF8String], collectionIndex, fontSize, (Renderer::FontStyle)fontStyle);
}

// MARK: Other
- (NSString *)currentURL {
    CelestiaState appState;
    appState.captureState(core);

    Url currentURL(appState, Url::CurrentVersion);
    return [NSString stringWithUTF8String:currentURL.getAsString().c_str()];
}

- (CelestiaTextEnterMode)textEnterMode {
    return (CelestiaTextEnterMode)core->getTextEnterMode();
}

- (void)setTextEnterMode:(CelestiaTextEnterMode)textEnterMode {
    core->setTextEnterMode((int)textEnterMode);
}

- (void)runScript:(NSString *)path {
    core->runScript([path UTF8String]);
}

- (void)goToURL:(NSString *)url {
    core->goToUrl([url UTF8String]);
}

- (BOOL)captureMovie:(NSString *)filePath withVideoSize:(CGSize)size fps:(float)fps {
    MovieCapture *movieCapture = new OggTheoraCapture(core->getRenderer());
    movieCapture->setAspectRatio(1, 1);
    bool ok = movieCapture->start([filePath UTF8String],
                                  size.width, size.height,
                                  fps);
    if (ok) {
        core->initMovieCapture(movieCapture);
    } else {
        delete movieCapture;
    }
    return (BOOL)ok;
}

- (BOOL)screenshot:(NSString *)filePath withFileSize:(ScreenshotFileType)type {
    return (BOOL)core->saveScreenShot([filePath UTF8String], (ContentType)type);
}

+ (void)setLocaleDirectory:(NSString *)localeDirectory {
    // Gettext integration
    setlocale(LC_ALL, "");
    setlocale(LC_NUMERIC, "C");
    bindtextdomain("celestia", [localeDirectory UTF8String]);
    bind_textdomain_codeset("celestia", "UTF-8");
    bindtextdomain("celestia_constellations", [localeDirectory UTF8String]);
    bind_textdomain_codeset("celestia_constellations", "UTF-8");
    bindtextdomain("celestia_ui", [localeDirectory UTF8String]);
    bind_textdomain_codeset("celestia_ui", "UTF-8");
    textdomain("celestia");
}

// MARK: Simulation
- (CelestiaSimulation *)simulation {
    if (!_simulation) {
        _simulation = [[CelestiaSimulation alloc] initWithSimulation:core->getSimulation()];
    }
    return _simulation;
}

// MARK: History
- (void)forward {
    std::vector<Url>::size_type historySize = core->getHistory().size();
    if (historySize < 2) return;
    if (core->getHistoryCurrent() > historySize-2) return;
    core->forward();
}

- (void)back {
    core->back();
}

- (void)dealloc {
    core->setAlerter(nullptr);
    core->setCursorHandler(nullptr);
    core->setContextMenuHandler(nullptr);
    delete watcher;
    delete alerter;
    delete cursorHandler;
    delete contextMenuHandler;
    delete core;
}

@end
