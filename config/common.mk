PRODUCT_BRAND ?= cyanide

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/cyanide/prebuilt/common/bootanimation))
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
PRODUCT_BOOTANIMATION := vendor/cyanide/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/cyanide/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

ifdef CYANIDE_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanidenightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanidemod
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
		vendor/cyanide/prebuilt/common/app/NovaLauncher.apk:system/app/NovaLauncher.apk
		
# Workaround for ESFileManager zipalign fails
PRODUCT_COPY_FILES += \
		vendor/cyanide/prebuilt/common/app/ESFileManager.apk:system/app/ESFileManager.apk
		
# Workaround for CyanideBlue zipalign fails
#PRODUCT_COPY_FILES += \
#		vendor/cyanide/prebuilt/common/app/CyanideBlue.apk:system/app/CyanideBlue.apk

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=0
endif

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/cyanide/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/cyanide/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/cyanide/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cyanide/prebuilt/common/bin/sysinit:system/bin/sysinit

# Proprietary latinime lib needed for Keyboard swyping
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# userinit support
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
    
# SuperSU
PRODUCT_COPY_FILES += \
	vendor/cyanide/prebuilt/common/etc/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
	vendor/cyanide/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# CYANIDE-specific init file
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/etc/init.local.rc:root/init.cyanide.rc

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/cyanide/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/cyanide/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# Chromium Prebuilt
ifeq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)
-include prebuilts/chromium/$(TARGET_DEVICE)/chromium_prebuilt.mk
endif

PRODUCT_COPY_FILES += \
    vendor/cyanide/config/permissions/com.cyanide.android.xml:system/etc/permissions/com.cyanide.android.xml

# T-Mobile theme engine
include vendor/cyanide/config/themes_common.mk

# Required CYANIDE packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt

# Optional CYANIDE packages
PRODUCT_PACKAGES += \
    Basic \
    libemoji

# Custom CM packages
PRODUCT_PACKAGES += \
    Eleven \
    LockClock \
    OmniSwitch \
    CMAccount \
    CyanidePapers

# CM Platform Library
PRODUCT_PACKAGES += \
     org.cyanogenmod.platform-res \
     org.cyanogenmod.platform \
     org.cyanogenmod.platform.xml

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CYANIDE
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

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
    procrank
    
# HFM Files
PRODUCT_COPY_FILES += \
	vendor/cyanide/prebuilt/etc/hosts.alt:system/etc/hosts.alt \
	vendor/cyanide/prebuilt/etc/hosts.og:system/etc/hosts.og

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1

endif

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanide/overlay/common

CYANIDE_BUILDTYPE = RELEASE
PRODUCT_VERSION_MAJOR = 5.1.1
PRODUCT_VERSION_MAINTENANCE = RC-16.0

# Set CYANIDE_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef CYANIDE_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "CYANIDE_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^CYANIDE_||g')
        CYANIDE_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(CYANIDE_BUILDTYPE)),)
    CYANIDE_BUILDTYPE :=
endif

ifdef CYANIDE_BUILDTYPE
    ifneq ($(CYANIDE_BUILDTYPE), SNAPSHOT)
        ifdef CYANIDE_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            CYANIDE_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from CYANIDE_EXTRAVERSION
            CYANIDE_EXTRAVERSION := $(shell echo $(CYANIDE_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CYANIDE_EXTRAVERSION
            CYANIDE_EXTRAVERSION := -$(CYANIDE_EXTRAVERSION)
        endif
    else
        ifndef CYANIDE_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            CYANIDE_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from CYANIDE_EXTRAVERSION
            CYANIDE_EXTRAVERSION := $(shell echo $(CYANIDE_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CYANIDE_EXTRAVERSION
            CYANIDE_EXTRAVERSION := -$(CYANIDE_EXTRAVERSION)
        endif
    endif
else
    # If CYANIDE_BUILDTYPE is not defined, set to UNOFFICIAL
    CYANIDE_BUILDTYPE := UNOFFICIAL
    CYANIDE_EXTRAVERSION :=
endif

ifeq ($(CYANIDE_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        CYANIDE_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(CYANIDE_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        CYANIDE_VERSION := $(PRODUCT_VERSION_MAJOR)-$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CYANIDE_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            CYANIDE_VERSION := $(PRODUCT_VERSION_MAJOR).$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(CYANIDE_BUILD)
        else
            CYANIDE_VERSION := $(PRODUCT_VERSION_MAJOR)-$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CYANIDE_BUILD)
        endif
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cyanide.version=$(CYANIDE_VERSION) \
  ro.cyanide.releasetype=$(CYANIDE_BUILDTYPE) \
  ro.modversion=$(CYANIDE_VERSION) 

-include vendor/cm-priv/keys/keys.mk

CYANIDE_DISPLAY_VERSION := $(CYANIDE_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(CYANIDE_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(CYANIDE_EXTRAVERSION),)
        # Remove leading dash from CYANIDE_EXTRAVERSION
        CYANIDE_EXTRAVERSION := $(shell echo $(CYANIDE_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(CYANIDE_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    CYANIDE_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

ifndef CM_PLATFORM_SDK_VERSION
  # This is the canonical definition of the SDK version, which defines
  # the set of APIs and functionality available in the platform.  It
  # is a single integer that increases monotonically as updates to
  # the SDK are released.  It should only be incremented when the APIs for
  # the new release are frozen (so that developers don't write apps against
  # intermediate builds).
  CM_PLATFORM_SDK_VERSION := 1
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cyanide.display.version=$(CYANIDE_DISPLAY_VERSION)

# CyanogenMod Platform SDK Version
PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.build.version.plat.sdk=$(CM_PLATFORM_SDK_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
