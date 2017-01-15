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

PRODUCT_BOOTANIMATION := vendor/cyanide/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif

# Sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=Playa.ogg \
    ro.config.notification_sound=regulus.ogg \
    ro.config.alarm_alert=Alarm_Beep_03.ogg

# Selinux
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/cyanide/prebuilt/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/cyanide/prebuilt/bin/50-hosts.sh:system/addon.d/50-hosts.sh \
    vendor/cyanide/prebuilt/bin/blacklist:system/addon.d/blacklist

# Swype Lib
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/lib/libjni_latinime.so:system/lib/libjni_latinime.so \
    vendor/cyanide/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so \
    vendor/cyanide/prebuilt/common/lib64/libjni_latinime.so:system/lib64/libjni_latinime.so \
    vendor/cyanide/prebuilt/common/lib64/libjni_latinimegoogle.so:system/lib64/libjni_latinimegoogle.so

# Workaround for CyanideMods zipalign fails
PRODUCT_COPY_FILES += \
        vendor/cyanide/prebuilt/common/app/CyanideMods/CyanideMods.apk:system/priv-app/CyanideMods/CyanideMods.apk

# Workaround for NovaLauncher zipalign fails
PRODUCT_COPY_FILES += \
		vendor/cyanide/prebuilt/common/app/CyanideLauncher.apk:system/app/CyanideLauncher.apk
		
# Workaround for ESFileManager zipalign fails
PRODUCT_COPY_FILES += \
		vendor/cyanide/prebuilt/common/app/ESFileManager.apk:system/app/ESFileManager.apk

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/cyanide/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cyanide/prebuilt/bin/sysinit:system/bin/sysinit

# Init script file with Cyanide extras
#PRODUCT_COPY_FILES += \
#    vendor/cyanide/prebuilt/etc/init.local.rc:root/init.cyanide.rc

# DU Utils Library
PRODUCT_BOOT_JARS += \
    org.dirtyunicorns.utils

# Additional packages
-include vendor/cyanide/config/packages.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanide/overlay

#  Cyanide Version
-include vendor/cyanide/config/version.mk
