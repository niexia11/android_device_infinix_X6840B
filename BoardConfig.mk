########################################
# BoardConfig.mk — Infinix X6840B
# Platform   : MT6768 (ro.board.platform=mt6768)
# Android    : 16 / API 36 (first_api_level=36)
# Recovery   : vendor_boot (VAB, header v4)
# ABI        : arm64-v8a ONLY (abilist32 is EMPTY → 64-bit only)
########################################

DEVICE_PATH := device/infinix/X6840B

# ─── Architecture ──────────────────────────────────────────────────────────────
# abilist=arm64-v8a, abilist32="" → 64-bit only, no TARGET_2ND_ARCH
TARGET_ARCH               := arm64
TARGET_ARCH_VARIANT       := armv8-a
TARGET_CPU_ABI            := arm64-v8a
TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_CPU_ABI2           :=
TARGET_CPU_VARIANT        := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

# ─── Platform ──────────────────────────────────────────────────────────────────
TARGET_BOARD_PLATFORM     := mt6768
TARGET_NO_BOOTLOADER      := true

# ─── Kernel (GKI — no source build, ramdisk-only) ──────────────────────────────
# All offsets are derived from vendor_boot_raw.img header (xxd + magiskboot):
#   kernel_addr  = 0x40080000  → base = 0x40080000 - 0x8000 = 0x40078000
#   ramdisk_addr = 0x47C80000  → offset = 0x47C80000 - 0x40078000 = 0x07C08000
#   page_size confirmed from header = 0x1000 = 4096
TARGET_NO_KERNEL              := true
BOARD_BOOT_HEADER_VERSION     := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4

BOARD_KERNEL_BASE          := 0x40078000
BOARD_KERNEL_OFFSET        := 0x00008000
BOARD_RAMDISK_OFFSET       := 0x07C08000
BOARD_KERNEL_TAGS_OFFSET   := 0x0BC08000   # confirmed: tags_addr=0x4bc80000 - base=0x40078000
BOARD_DTB_OFFSET           := 0x0BC08000   # confirmed: dtb_addr=0x4bc80000  - base=0x40078000
BOARD_PAGE_SIZE            := 4096          # ← CONFIRMED 4096, not 2048!
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/dtb

# Vendor boot cmdline (from magiskboot unpack output)
BOARD_VENDOR_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_PAGE_SIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

# ─── vendor_boot Recovery (VAB — recovery lives in vendor_boot) ────────────────
BOARD_USES_RECOVERY_AS_BOOT              := false
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/twrp.fstab

# ─── Virtual A/B ───────────────────────────────────────────────────────────────
# ro.virtual_ab.enabled=true, ro.build.ab_update=true
ENABLE_VIRTUAL_AB := true
AB_OTA_UPDATER    := true

# All "updated" partitions from lpdump (both standard + Transsion tr_* partitions)
AB_OTA_PARTITIONS += \
    system \
    system_ext \
    system_dlkm \
    vendor \
    vendor_dlkm \
    product \
    odm \
    odm_dlkm \
    tr_region \
    tr_product \
    tr_preload \
    tr_carrier \
    tr_company \
    tr_manifest \
    tr_overlayfs \
    tr_misc

# ─── Partitions ────────────────────────────────────────────────────────────────
# blockdev --getsize64 /dev/block/by-name/super     = 9663676416
# lpdump group main_a max size                      = 9661579264
# blockdev --getsize64 /dev/block/by-name/vendor_boot_a = 67108864
# blockdev --getsize64 /dev/block/by-name/boot_a       = 67108864
BOARD_SUPER_PARTITION_SIZE               := 9663676416
BOARD_SUPER_PARTITION_GROUPS            := main
BOARD_MAIN_SIZE                         := 9661579264

# All logical partitions (standard Android 16 GKI + Transsion custom)
# NOTE for custom ROM: remove tr_* if your ROM does not ship those partitions
BOARD_MAIN_PARTITION_LIST               := \
    system \
    system_ext \
    system_dlkm \
    vendor \
    vendor_dlkm \
    product \
    odm \
    odm_dlkm \
    tr_region \
    tr_product \
    tr_preload \
    tr_carrier \
    tr_company \
    tr_manifest \
    tr_overlayfs \
    tr_misc

BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE   := 67108864
BOARD_BOOTIMAGE_PARTITION_SIZE          := 67108864
BOARD_FLASH_BLOCK_SIZE                  := 262144   # page_size * 64 = 4096 * 64
BOARD_HAS_LARGE_FILESYSTEM              := true

# Filesystem types (fstab: system/vendor/odm use erofs on stock; ext4 fallback)
TARGET_USERIMAGES_USE_EXT4  := true
TARGET_USERIMAGES_USE_F2FS  := true

# Metadata partition = /dev/block/by-name/metadata (mmcblk0p12, f2fs)
# md_udc = mmcblk0p11 (MTK modem metadata, different partition — do NOT confuse)
BOARD_USES_METADATA_PARTITION := true

# ─── AVB / Verified Boot ───────────────────────────────────────────────────────
BOARD_AVB_ENABLE := true
BOARD_AVB_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)

# ─── Crypto / FBE ──────────────────────────────────────────────────────────────
# ro.crypto.type=file, ro.crypto.state=encrypted
# From fstab: fileencryption=aes-256-xts:aes-256-cts:v2
#             keydirectory=/metadata/vold/metadata_encryption
#             inlinecrypt is a separate mount option
# Keymint: android.hardware.security.keymint@3.0-service.trustonic
TW_INCLUDE_CRYPTO                   := true
TW_INCLUDE_CRYPTO_FBE               := true
TW_INCLUDE_FBE_METADATA_DECRYPT     := true

# PLATFORM_VERSION spoof — CRITICAL for TWRP/OFox to not reject Keymint 3.0
# Without this, recovery will refuse to decrypt /data
PLATFORM_VERSION                    := 99.87.36
PLATFORM_VERSION_LAST_STABLE        := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH             := 2099-12-31
VENDOR_SECURITY_PATCH               := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH                 := $(PLATFORM_SECURITY_PATCH)

# ─── Display ───────────────────────────────────────────────────────────────────
# wm size: 720x1576, wm density: 280
# max_brightness: 5119 (from /sys/class/leds/lcd-backlight/max_brightness)
TW_THEME                  := portrait_hdpi
TARGET_SCREEN_WIDTH       := 720
TARGET_SCREEN_HEIGHT      := 1576
TW_SCREEN_DENSITY         := 280

TW_BRIGHTNESS_PATH        := /sys/class/leds/lcd-backlight/brightness
TW_MAX_BRIGHTNESS         := 5119
TW_DEFAULT_BRIGHTNESS     := 3000

# ─── TWRP / OFox Features ──────────────────────────────────────────────────────
TW_DEVICE_VERSION                 := 1
TW_EXCLUDE_DEFAULT_USB_INIT       := true
TW_EXTRA_LANGUAGES                := false
TW_INCLUDE_NTFS_3G                := true
TW_NO_SCREEN_BLANK                := true
TW_SCREEN_BLANK_ON_BOOT           := false
TW_USE_TOOLBOX                    := true
TW_INCLUDE_REPACKTOOLS            := true
TW_INCLUDE_RESETPROP              := true
TW_INCLUDE_LIBRESETPROP           := true
TW_INCLUDE_FASTBOOTD              := true
TW_HAS_MTP                        := true
TW_MTP_DEVICE                     := /dev/mtp_usb
TW_INTERNAL_STORAGE_PATH          := /sdcard
TW_INTERNAL_STORAGE_MOUNT_POINT   := sdcard
TW_EXTERNAL_STORAGE_PATH          := /sdcard1
TW_EXTERNAL_STORAGE_MOUNT_POINT   := sdcard1

# ─── Logcat ────────────────────────────────────────────────────────────────────
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD    := true
