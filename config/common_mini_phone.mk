# Inherit common CYANIDE stuff
$(call inherit-product, vendor/cyanide/config/common.mk)

# Include CYANIDE audio files
include vendor/cyanide/config/cyanide_audio.mk

# Required CYANIDE packages
PRODUCT_PACKAGES += \
    LatinIME

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Helium.ogg

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/cyanide/prebuilt/common/bootanimation/320.zip:system/media/bootanimation.zip
endif

$(call inherit-product, vendor/cyanide/config/telephony.mk)
