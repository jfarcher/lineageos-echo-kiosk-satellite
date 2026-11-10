#
# SPDX-FileCopyrightText: 2025 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := mdpi

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio.effect@2.0-impl \
    audio.primary.amazon_wrapper

PRODUCT_PACKAGES += \
    libaudio-resampler \
    libaudioutils \
    libaudioroute \
    libtinyalsa \
    libamazonlog \
    libbinder_shim \
    libcutils_shim

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service \
    android.hardware.bluetooth@1.0-impl \
    libbt-vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml

# Camera
PRODUCT_PACKAGES += \
    libcameracustom

# Init scripts
PRODUCT_PACKAGES += \
    init.target.rook.rc

# Input
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/idc/,$(TARGET_COPY_OUT_VENDOR)/usr/idc/)

# Kernel Modules
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/init.insmod.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/init.insmod.cfg

PRODUCT_PACKAGES += \
    amzn-bcmdhd

# Overlay
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += \
    $(LOCAL_PATH)/overlay/packages/apps/Bluetooth

PRODUCT_PACKAGES += \
    FrameworksResOverlayRook \
    LatinIMEOverlayRook \
    SetupWizardOverlayRook \
    SystemUIOverlayRook

# Screen
TARGET_SCREEN_DENSITY := 160
TARGET_SCREEN_HEIGHT := 480
TARGET_SCREEN_WIDTH := 480

# Sensors
PRODUCT_PACKAGES += \
    sensors.amazon

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml

# Shipping API Level
PRODUCT_SHIPPING_API_LEVEL := 22

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Suspend blocker
PRODUCT_PACKAGES += \
    suspend_blocker_mt8163

# Thermal
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/thermal.policy.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/thermal.policy.conf

# Vendor partition
TARGET_HAS_VENDOR_PARTITION := false

# Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service-lazy \
    wpa_supplicant.conf \
    libwifi-hal

PRODUCT_PACKAGES += \
    WifiResOverlayRook

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    hardware/broadcom/wlan/bcmdhd/config/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf

# Inherit from mt8163-common
$(call inherit-product, device/amazon/mt8163-common/mt8163.mk)

# Inherit the proprietary files
$(call inherit-product, vendor/amazon/rook/rook-vendor.mk)
