#import <UIKit/UIKit.h>
#import <UIKit/_UILegibilitySettings.h>
#import "../PS.h"

@interface SBIconLabelImageParameters : NSObject
- (NSInteger)iconLocation;
@end

@interface SBFolderIconBackgroundView : UIView
@end

@interface SBFolderBackgroundView : UIView
- (BOOL)_shouldUseDarkBackground;
@end

@interface SBWallpaperEffectView : UIView
- (void)setStyle:(NSInteger)style;
@end

extern "C" BOOL _UIAccessibilityEnhanceBackgroundContrast();

%hook SBFolderIconImageView

- (void)_updateAccessibilityBackgroundContrast {
    %orig;
    SBFolderIconBackgroundView *backgroundView = MSHookIvar<SBFolderIconBackgroundView *>(self, "_backgroundView");
    UIView *accessibilityBackgroundView = MSHookIvar<UIView *>(self, "_accessibilityBackgroundView");
    backgroundView.hidden = NO;
    accessibilityBackgroundView.hidden = YES;
}

%end

%hook SBFolderBackgroundView

- (void)_updateBackgroundImageView {
    %orig;
    UIImageView *backgroundImageView = MSHookIvar<UIImageView *>(self, "_backgroundImageView");
    backgroundImageView.hidden = NO;
}

- (void)_configureAccessibilityBackground {
    %orig;
    UIView *accessibilityBackgroundView = MSHookIvar<UIView *>(self, "_accessibilityBackgroundView");
    SBWallpaperEffectView *backdropView = MSHookIvar<SBWallpaperEffectView *>(self, "_backdropView");
    accessibilityBackgroundView.hidden = YES;
    if (backdropView != nil) {
        backdropView.hidden = NO;
        BOOL darkBG = [self _shouldUseDarkBackground];
        backdropView.style = darkBG ? 12 : 11;
        if (_UIAccessibilityEnhanceBackgroundContrast()) {
            // Because style 11 is reverted to 2 (solid black) when contrast option is enabled.
            // It does not match with the blurry white style when the option is disabled.
            backdropView.style = 7;
        }
    }
}

%end

%hook SBDockView

- (void)_backgroundContrastDidChange: (id)change {
    // We do not call the original method here since it adds/removes some important views that we need to configure them
    // and it is not wise to recreate those views whenever they are not existed.
    // %orig;
    UIView *backgroundView = MSHookIvar<SBWallpaperEffectView *>(self, "_backgroundView") ? : MSHookIvar<UIImageView *>(self, "_backgroundImageView");
    UIView *accessibilityBackgroundView = MSHookIvar<UIView *>(self, "_accessibilityBackgroundView");
    backgroundView.hidden = NO;
    accessibilityBackgroundView.hidden = YES;
}

%end

%hook SBIconView

- (_UILegibilitySettings *)_legibilitySettingsWithParameters: (SBIconLabelImageParameters *)param {
    _UILegibilitySettings *settings = nil;
    if (_UIAccessibilityEnhanceBackgroundContrast()) {
        NSInteger location = [param iconLocation];
        // 0 - homescreen
        // 1 - homescreen (iOS 8.4+)
        // 2 - dock
        // 3 - dock (iOS 8.4+)
        // 4 - folder (expanded, iOS 7)
        // 5 - folder (expanded, iOS 8.0 - 8.3)
        // 6 - folder (expanded, iOS 8.4+)
        // 7 - folder (expanded, iOS 9.0+)
        BOOL iOS8 = isiOS8Up;
        BOOL iOS84 = isiOS84Up;
        BOOL iOS9 = isiOS9Up;
        if ((iOS8 && !iOS84 && location == 2) || (iOS84 && location == 3) ||
            (iOS8 && !iOS84 && location == 5) || (iOS84 && location == 6) ||
            (iOS9 && location == 7) || (isiOS7 && location == 4)) {
            // What we do here is to disable the black label of icons when they are in dock or expanded folders and contrast option is enabled, just like iOS 7.0
            // Labels color for homescreen icons is normally white. (If the wallpaper tone is not bright too)
            MSHookIvar<NSInteger>(param, "_iconLocation") = 0;
            settings = %orig;
            MSHookIvar<NSInteger>(param, "_iconLocation") = location;
        }
    }
    return settings ? settings : %orig;
}

%end
