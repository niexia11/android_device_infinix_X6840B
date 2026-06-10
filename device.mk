########################################
# device.mk — Infinix X6840B
########################################

PRODUCT_PLATFORM := mt6768

# ─── Keymint 3.0 (Trustonic) workaround ──────────────────────────────────────
# Binary confirmed: /vendor/bin/hw/android.hardware.security.keymint@3.0-service.trustonic
# ro.hardware.keystore is EMPTY (not set in system props)
# Spoof via build props so TWRP/OFox crypto stack accepts it
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build.security_patch=2099-12-31 \
    ro.hardware.keystore_desede=true

# ─── Virtual A/B ──────────────────────────────────────────────────────────────
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# ─── fastbootd ────────────────────────────────────────────────────────────────
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# ─── MTK Mobicore (for Trustonic Keymint 3.0) ─────────────────────────────────
# mobicore service handles TEE communication on MTK platforms
PRODUCT_PACKAGES += \
    libMcClient

# ─── Crypto ───────────────────────────────────────────────────────────────────
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.volume.filenames_mode=aes-256-cts \
    ro.crypto.volume.metadata.encryption=aes-256-xts:v2

# ─── Init ─────────────────────────────────────────────────────────────────────
# Recovery init patches for VAB
PRODUCT_PACKAGES += \
    init_recovery
