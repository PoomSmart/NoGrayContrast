GO_EASY_ON_ME = 1
SDKVERSION = 7.1
ARCHS = armv7 arm64

include theos/makefiles/common.mk
TWEAK_NAME = NoGrayContrast
NoGrayContrast_FILES = Tweak.xm
NoGrayContrast_FRAMEWORKS = UIKit
NoGrayContrast_LIBRARIES = Accessibility

include $(THEOS_MAKE_PATH)/tweak.mk
