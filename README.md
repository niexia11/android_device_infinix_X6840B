# Device Tree — Infinix X6840B (MT6768)
# Key findings from live device data

## Confirmed values (all from DT_PROJECT.TXT)

| Item | Value |
|------|-------|
| Platform | mt6768 |
| Android / SDK | 16 / 36 |
| Architecture | arm64-v8a ONLY — abilist32 is EMPTY |
| vendor_boot header | v4 |
| Page size | **4096** (NOT 2048 — confirmed from xxd of vendor_boot) |
| Kernel base | 0x40078000 (kernel_addr 0x40080000 − 0x8000) |
| Ramdisk offset | 0x07C08000 (ramdisk_addr 0x47C80000 − base) |
| vendor_boot size | 67108864 (64 MB) |
| boot size | 67108864 (64 MB) |
| super size | 9663676416 |
| main_a max | 9661579264 (from lpdump) |
| Virtual A/B | true (ro.virtual_ab.enabled=true) |
| Crypto type | file (FBE) |
| fileencryption | aes-256-xts:aes-256-cts:v2 |
| key directory | /metadata/vold/metadata_encryption |
| Keymint | Trustonic 3.0 |
| Metadata partition | /dev/block/by-name/metadata (mmcblk0p12, f2fs) |
| Screen | 720x1576, density 280 |
| Max brightness | 5119 |
| Security patch | 2026-04-01 |

## Critical corrections vs first draft

1. **Page size = 4096, not 2048** — confirmed from vendor_boot header byte 0x0C
2. **No 32-bit ABI** — abilist32 is empty; Android 16 dropped 32-bit app support
3. **system_dlkm is a real partition** — present in lpdump and mapper
4. **tr_* partitions exist** — 8 Transsion custom logical partitions in super
5. **init_boot partition exists** — init_boot_a/b in by-name; needs BOARD_INIT_BOOT_HEADER_VERSION=4
6. **No cache partition** — not in by-name list at all (Android 11+ removed it)
7. **md_udc ≠ metadata** — md_udc=mmcblk0p11 is MTK modem metadata; metadata=mmcblk0p12 is the real one
8. **inlinecrypt is a mount option**, NOT part of the fileencryption= string
9. **Max brightness = 5119**, not 2047

## Keymint 3.0 crypto — what you need

The PLATFORM_VERSION spoof in BoardConfig.mk is MANDATORY.
Without it, TWRP/OFox will refuse to decrypt /data because it checks
the platform version against what Keymint reports.

Both these must be set:
  PLATFORM_VERSION := 99.87.36
  PLATFORM_SECURITY_PATCH := 2099-12-31

Also set in device.mk:
  ro.vendor.build.security_patch=2099-12-31
  ro.hardware.keystore_desede=true

## Still to verify (run these commands)

These values are estimated/standard MTK — verify before final build:

```bash
# 1. Tags offset — dump boot image and check header
su -c "dd if=/dev/block/by-name/boot_a of=/sdcard/boot.img"
magiskboot unpack /sdcard/boot.img
# Look for: TAGS_ADDR value in output

# 2. Init boot header
su -c "dd if=/dev/block/by-name/init_boot_a of=/sdcard/init_boot.img"
magiskboot unpack /sdcard/init_boot.img

# 3. Backlight path (confirm the exact sysfs path)
su -c "ls /sys/class/leds/"
su -c "ls /sys/class/backlight/"
# Whichever exists → update TW_BRIGHTNESS_PATH

# 4. Exact display dimensions (already confirmed: 720x1576)
wm size

# 5. USB controller for MTP
su -c "ls /dev/mtp_usb 2>/dev/null || ls /dev/usb-ffs/mtp 2>/dev/null"
```

## tr_* partitions — what they are

Transsion/Infinix-specific logical partitions inside super:
- tr_region: Regional firmware (huge — ~3.2GB)
- tr_product: Product configuration
- tr_preload: Pre-loaded apps
- tr_carrier: Carrier customization
- tr_company: Company branding
- tr_manifest: Partition manifest
- tr_overlayfs: OverlayFS layers
- tr_misc: Misc configs

For **TWRP/OFox**: Include all of them in fstab so recovery can mount them
For **Custom ROM (AOSP base)**: Remove tr_* from BOARD_MAIN_PARTITION_LIST and AB_OTA_PARTITIONS; adjust BOARD_MAIN_SIZE accordingly
For **Custom ROM (XOS base)**: Keep all tr_* partitions

## GitHub repo structure

Push to: https://github.com/niexia11/android_device_infinix_X6840B

Recommended branch name: android-16 or twrp-3.7

For Action-TWRP-Builder workflow, the lunch target is:
  twrp_X6840B-eng
