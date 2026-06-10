LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),X6840B)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
