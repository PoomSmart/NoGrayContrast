DEBUG = 0
PACKAGE_VERSION = 1.1

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = NoGrayContrast
NoGrayContrast_FILES = Tweak.xm
NoGrayContrast_FRAMEWORKS = UIKit
NoGrayContrast_LIBRARIES = Accessibility

include $(THEOS_MAKE_PATH)/tweak.mk