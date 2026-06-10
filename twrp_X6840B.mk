########################################
# twrp_X6840B.mk — Infinix X6840B
# Use this file for TWRP and OrangeFox builds
########################################

# Inherit TWRP common (swap for OFox when building OrangeFox)
$(call inherit-product, vendor/twrp/config/common.mk)
# OrangeFox: use this instead ↓
# $(call inherit-product, vendor/recovery/orangefox.mk)

# Device specifics
$(call inherit-product, device/infinix/X6840B/device.mk)

# Product identity
PRODUCT_DEVICE       := X6840B
PRODUCT_NAME         := twrp_X6840B
PRODUCT_BRAND        := Infinix
PRODUCT_MODEL        := Infinix X6840B
PRODUCT_MANUFACTURER := Infinix
PRODUCT_RELEASE_NAME := Smart 20

# GMS client ID
PRODUCT_GMS_CLIENTID_BASE := android-infinix

# Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

# ─── OrangeFox-specific flags ─────────────────────────────────────────────────
# Uncomment these when building OFox
#FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER := 1
#OF_MAINTAINER                       := YourName
#OF_DEVICE_CODENAME                  := X6840B
#FOX_BUILD_TYPE                      := Unofficial
#OF_NO_TREBLE_COMPATIBILITY_CHECK    := 1
#OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR := 1
#OF_SKIP_DECRYPTION_SDCARD           := 0
#OF_USE_GREEN_LED                    := 0
#OF_SUPPORT_ALL_QCOM_CHIPSETS        := 0
#OF_SUPPORT_ALL_MTK_CHIPSETS         := 1
#FOX_TARGET_DEVICES                  := X6840B
