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
    ro.rommanager.developerid=cyanide
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

# Proprietary latinime lib needed for Keyboard swyping
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so
    
# Layers Backup
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/bin/71-layers.sh:system/addon.d/71-layers.sh

PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# Workaround for NovaLauncher zipalign fails
PRODUCT_COPY_FILES += \
		vendor/cyanide/prebuilt/common/app/NovaLauncher.apk:system/app/NovaLauncher.apk
		
# Workaround for ESFileManager zipalign fails
PRODUCT_COPY_FILES += \
		vendor/cyanide/prebuilt/common/app/ESFileManager.apk:system/app/ESFileManager.apk

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/cyanide/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

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

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/cyanide/configs/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/cyanide/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/cyanide/prebuilt/common/bin/50-cyanide.sh:system/addon.d/50-cyanide.sh \
    vendor/cyanide/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cyanide/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# Cyanide-specific init file
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/etc/init.local.rc:root/init.cyanide.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is Cyanide!
PRODUCT_COPY_FILES += \
    vendor/cyanide/config/permissions/com.cyanide.android.xml:system/etc/permissions/com.cyanide.android.xml

# Required Cyanide packages
PRODUCT_PACKAGES += \
    Development

# Optional Cyanide packages
PRODUCT_PACKAGES += \
    libemoji

# Include librsjni explicitly to workaround GMS issue
PRODUCT_PACKAGES += \
    librsjni

# Custom Cyanide packages
PRODUCT_PACKAGES += \
    CyanideWeatherService \
    Eleven \
    OmniSwitch \
    masquerade

# Extra tools in Cyanide
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

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanide/overlay/common

#Let builder choose custom buildtype. Default to freedom
ifndef CYANIDE_BUILDTYPE
CYANIDE_BUILDTYPE = Detoxified
endif

PRODUCT_VERSION_MAJOR = 5
PRODUCT_VERSION_MAINTENANCE = 0
CYANIDE_VERSION := Cyanide-v$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MAINTENANCE)-$(CYANIDE_BUILD)-$(CYANIDE_BUILDTYPE)-$(shell date +%Y%m%d)

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cyanide.version=$(CYANIDE_VERSION) \
  cyanide.ota.version=$(shell date -u +%Y%m%d) \
  ro.cyanide.releasetype=$(CYANIDE_BUILDTYPE) \
  ro.modversion=$(CYANIDE_VERSION) 

-include vendor/cyanide-priv/keys/keys.mk

CYANIDE_DISPLAY_VERSION := $(CYANIDE_VERSION)

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cyanide.display.version=$(CYANIDE_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
