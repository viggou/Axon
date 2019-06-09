ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Axon
$(TWEAK_NAME)_FILES = Tweak.xm AXNAppCell.m AXNView.m AXNManager.m
$(TWEAK_NAME)_FRAMEWORKS += QuartzCore WebKit MediaPlayer
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk