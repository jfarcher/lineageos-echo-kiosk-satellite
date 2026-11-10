/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "libcameracustom_shim"

#include <dlfcn.h>
#include <stdint.h>
#include <string.h>

#include <memory>
#include <mutex>

#include <log/log.h>

struct MSDK_SENSOR_INIT_FUNCTION_STRUCT {
    uint32_t sensorId;
    char drvName[32];
    void* info;
    void* getInstance;
    int (*getCameraDefault)(int type, void* data, uint32_t size);
    void* reserved;
    void* getCameraCalData;
};
static_assert(sizeof(MSDK_SENSOR_INIT_FUNCTION_STRUCT) == 56);

namespace {

constexpr int kAePlineTable = 4;

constexpr size_t kPlineMappingSize = 0x5a0;
constexpr size_t kPlineTableCount = 50;
constexpr size_t kPlineTableSize = 6436;
constexpr size_t kPlineTableStride = 6440;
constexpr size_t kPlineTrailerSize = 9226;
constexpr size_t kOldPlineSize = 0x512b4;
constexpr size_t kNewPlineSize = 0x51380;

MSDK_SENSOR_INIT_FUNCTION_STRUCT sensorList[2];
int (*rookGetCameraDefault)(int, void*, uint32_t);

void convertPline(uint8_t* dst, const uint8_t* src) {
    memset(dst, 0, kNewPlineSize);
    memcpy(dst, src, kPlineMappingSize);

    dst += kPlineMappingSize;
    src += kPlineMappingSize;
    for (size_t i = 0; i < kPlineTableCount; i++) {
        memcpy(dst, src, kPlineTableSize);
        dst += kPlineTableStride;
        src += kPlineTableSize;
    }

    memcpy(dst, src, kPlineTrailerSize);
}

int getCameraDefault(int type, void* data, uint32_t size) {
    if (type != kAePlineTable)
        return rookGetCameraDefault(type, data, size);

    if (data == nullptr || size < kNewPlineSize)
        return 1;

    std::unique_ptr<uint8_t[]> pline(new uint8_t[kOldPlineSize]);
    int ret = rookGetCameraDefault(type, pline.get(), kOldPlineSize);
    if (ret == 0)
        convertPline(static_cast<uint8_t*>(data), pline.get());

    return ret;
}

void init() {
    void* handle = dlopen("libcameracustom_rook.so", RTLD_NOW | RTLD_LOCAL);
    LOG_ALWAYS_FATAL_IF(handle == nullptr, "Failed to load libcameracustom_rook: %s", dlerror());

    auto getList = reinterpret_cast<uint32_t (*)(MSDK_SENSOR_INIT_FUNCTION_STRUCT**)>(
            dlsym(handle, "_Z21GetSensorInitFuncListPP32MSDK_SENSOR_INIT_FUNCTION_STRUCT"));
    MSDK_SENSOR_INIT_FUNCTION_STRUCT* list = nullptr;
    LOG_ALWAYS_FATAL_IF(getList == nullptr || getList(&list) != 0 || list == nullptr,
                        "Failed to get the rook sensor list");

    memcpy(sensorList, list, sizeof(sensorList));
    rookGetCameraDefault = sensorList[0].getCameraDefault;
    sensorList[0].getCameraDefault = getCameraDefault;
}

}  // namespace

uint32_t GetSensorInitFuncList(MSDK_SENSOR_INIT_FUNCTION_STRUCT** list) {
    static std::once_flag once;
    std::call_once(once, init);

    if (list == nullptr)
        return 0x80000000;

    *list = sensorList;
    return 0;
}
