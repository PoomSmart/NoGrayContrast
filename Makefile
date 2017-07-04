DEBUG = 0
PACKAGE_VERSION = 1.1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest
	ARCHS = x86_64 i386
endif

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = NoGrayContrast
NoGrayContrast_FILES = Tweak.xm
NoGrayContrast_FRAMEWORKS = UIKit
NoGrayContrast_LIBRARIES = Accessibility
NoGrayContrast_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/tweak.mk

all::
ifeq ($(SIMULATOR),1)
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif
