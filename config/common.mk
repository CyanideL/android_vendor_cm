PRODUCT_BRAND ?= vrtoxin

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/vrtoxin/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/vrtoxin/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/vrtoxin/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

ifdef VRTOXIN_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=vrtoxinnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=vrtoxin
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

# Workaround for NovaLauncher zipalign fails
PRODUCT_COPY_FILES += \
		vendor/vrtoxin/prebuilt/common/app/NovaLauncher.apk:system/app/NovaLauncher.apk
		
# Workaround for ESFileManager zipalign fails
PRODUCT_COPY_FILES += \
		vendor/vrtoxin/prebuilt/common/app/ESFileManager.apk:system/app/ESFileManager.apk

# Workaround for LayersManager zipalign fails
PRODUCT_COPY_FILES += \
		vendor/vrtoxin/prebuilt/common/app/LayersManager.apk:system/app/LayersManager.apk

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/vrtoxin/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=0
endif

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/vrtoxin/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/vrtoxin/prebuilt/common/bin/50-vrtoxin.sh:system/addon.d/50-vrtoxin.sh \
    vendor/vrtoxin/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/vrtoxin/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# VRToxin-specific init file
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/etc/init.local.rc:root/init.vrtoxin.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is VRToxin!
PRODUCT_COPY_FILES += \
    vendor/vrtoxin/config/permissions/com.vrtoxin.android.xml:system/etc/permissions/com.vrtoxin.android.xml

# Required VRToxin packages
PRODUCT_PACKAGES += \
    Development

# Optional VR packages
PRODUCT_PACKAGES += \
    libemoji \
    Terminal

# Include librsjni explicitly to workaround GMS issue
PRODUCT_PACKAGES += \
    librsjni

# Custom VRToxin packages
PRODUCT_PACKAGES += \
    Launcher3 \
    LockClock

# Extra tools in VRToxin
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    nano \
    htop \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    mkfs.ntfs \
    fsck.ntfs \
    mount.ntfs \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace \
    pigz

WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1

PRODUCT_PACKAGE_OVERLAYS += vendor/vrtoxin/overlay/common

VRTOXIN_BUILDTYPE = RELEASE
PRODUCT_VERSION_MAJOR = 6.0
PRODUCT_VERSION_MAINTENANCE = 2.0

# Set VRTOXIN_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef VRTOXIN_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "VRTOXIN_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^VRTOXIN_||g')
        VRTOXIN_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(VRTOXIN_BUILDTYPE)),)
    VRTOXIN_BUILDTYPE :=
endif

ifdef VRTOXIN_BUILDTYPE
    ifneq ($(VRTOXIN_BUILDTYPE), SNAPSHOT)
        ifdef VRTOXIN_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            VRTOXIN_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from VRTOXIN_EXTRAVERSION
            VRTOXIN_EXTRAVERSION := $(shell echo $(VRTOXIN_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to VRTOXIN_EXTRAVERSION
            VRTOXIN_EXTRAVERSION := -$(VRTOXIN_EXTRAVERSION)
        endif
    else
        ifndef VRTOXIN_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            VRTOXIN_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from VRTOXIN_EXTRAVERSION
            VRTOXIN_EXTRAVERSION := $(shell echo $(VRTOXIN_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to VRTOXIN_EXTRAVERSION
            VRTOXIN_EXTRAVERSION := -$(VRTOXIN_EXTRAVERSION)
        endif
    endif
else
    # If VRTOXIN_BUILDTYPE is not defined, set to UNOFFICIAL
    VRTOXIN_BUILDTYPE := UNOFFICIAL
    VRTOXIN_EXTRAVERSION :=
endif

ifeq ($(VRTOXIN_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        VRTOXIN_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(VRTOXIN_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        VRTOXIN_VERSION := $(PRODUCT_VERSION_MAJOR)-$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(VRTOXIN_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            VRTOXIN_VERSION := $(PRODUCT_VERSION_MAJOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(VRTOXIN_BUILD)
        else
            VRTOXIN_VERSION := $(PRODUCT_VERSION_MAJOR)-$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(VRTOXIN_BUILD)
        endif
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.vrtoxin.version=$(VRTOXIN_VERSION) \
  ro.vrtoxin.releasetype=$(VRTOXIN_BUILDTYPE) \
  ro.modversion=$(VRTOXIN_VERSION) 

-include vendor/vrtoxin-priv/keys/keys.mk

VRTOXIN_DISPLAY_VERSION := $(VRTOXIN_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(VRTOXIN_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(VRTOXIN_EXTRAVERSION),)
        # Remove leading dash from VRTOXIN_EXTRAVERSION
        VRTOXIN_EXTRAVERSION := $(shell echo $(VRTOXIN_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(VRTOXIN_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    VRTOXIN_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.vrtoxin.display.version=$(VRTOXIN_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
