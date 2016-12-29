THEOS_DEVICE_IP = 172.21.113.159

ARCHS = armv7 arm64
TARGET = iphone:latest:8.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DDDynamicRedPocket
DDDynamicRedPocket_FILES = Tweak.xm
DDDynamicRedPocket_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
