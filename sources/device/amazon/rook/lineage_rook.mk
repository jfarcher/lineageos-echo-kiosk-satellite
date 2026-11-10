#
# SPDX-FileCopyrightText: 2025 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Inherit from device makefile.
$(call inherit-product, device/amazon/rook/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit the Kiosk Satellite Edition layer.
$(call inherit-product, vendor/kiosk-satellite/config/common.mk)
$(call inherit-product, vendor/kiosk-satellite/config/show.mk)
$(call inherit-product, device/kiosk-satellite/rook/device.mk)

PRODUCT_NAME := lineage_rook
PRODUCT_DEVICE := rook
PRODUCT_MANUFACTURER := Amzn
PRODUCT_BRAND := google
# Kiosk Satellite Edition: (KS) shows in Home Assistant and on the router
# that the Spot runs this image.
PRODUCT_MODEL := Echo Spot (KS)
PRODUCT_CHARACTERISTICS := tablet,nosdcard

WITHOUT_SETUP_WIZARD := true
