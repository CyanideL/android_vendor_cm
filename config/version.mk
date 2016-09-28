# Used to display the version
ANDROID_VERSION := N
CYANIDE_VERSION := Cyanide-$(ANDROID_VERSION)
# Used to display the build version
CYANIDE_BUILD_VERSION := $(BUILD_ID)-$(shell date +%Y%m%d)
# Used for the rom zip name
CYANIDE_PACKAGE_NAME := $(CYANIDE_VERSION)-$(shell date +%Y%m%d)-$(CYANIDE_BUILD_TYPE)-$(subst cyanide_,,$(TARGET_PRODUCT))

PRODUCT_PROPERTY_OVERRIDES += \
    ro.cyanide.version_android=$(ANDROID_VERSION) \
    ro.cyanide.version=$(CYANIDE_VERSION) \
    ro.cyanide.build.version=$(CYANIDE_BUILD_VERSION) \
ro.cyanide.build.type=$(CYANIDE_BUILD_TYPE)
