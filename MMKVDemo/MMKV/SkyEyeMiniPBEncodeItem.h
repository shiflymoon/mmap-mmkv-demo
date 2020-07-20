/*
 * Tencent is pleased to support the open source community by making
 * MMKV available.
 *
 * Copyright (C) 2018 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#ifdef __cplusplus

enum PREFIXNAME(MiniPBEncodeItemType) {
    PREFIXNAME(PBEncodeItemType_None),
    PREFIXNAME(PBEncodeItemType_NSString),
    PREFIXNAME(PBEncodeItemType_NSData),
    PREFIXNAME(PBEncodeItemType_NSDate),
    PREFIXNAME(PBEncodeItemType_NSContainer),
};

struct PREFIXNAME(MiniPBEncodeItem) {
    PREFIXNAME(MiniPBEncodeItemType) type;
    int32_t compiledSize;
    int32_t valueSize;
    union {
        void *objectValue;
        void *tmpObjectValue; // this object should release on dealloc
    } value;

    PREFIXNAME(MiniPBEncodeItem)() : type(PREFIXNAME(PBEncodeItemType_None)), compiledSize(0), valueSize(0) {
        memset(&value, 0, sizeof(value));
    }

    PREFIXNAME(MiniPBEncodeItem)(const PREFIXNAME(MiniPBEncodeItem) &other)
        : type(other.type)
        , compiledSize(other.compiledSize)
        , valueSize(other.valueSize)
        , value(other.value) {
        if (type == PREFIXNAME(PBEncodeItemType_NSString)) {
            if (value.tmpObjectValue != nullptr) {
                CFRetain(value.tmpObjectValue);
            }
        }
    }

    PREFIXNAME(MiniPBEncodeItem) &operator=(const PREFIXNAME(MiniPBEncodeItem) &other) {
        if (this != &other) {
            type = other.type;
            compiledSize = other.compiledSize;
            valueSize = other.valueSize;
            value = other.value;

            if (type == PREFIXNAME(PBEncodeItemType_NSString)) {
                if (value.tmpObjectValue != nullptr) {
                    CFRetain(value.tmpObjectValue);
                }
            }
        }

        return *this;
    }

    ~PREFIXNAME(MiniPBEncodeItem)() {
        if (type == PREFIXNAME(PBEncodeItemType_NSString)) {
            if (value.tmpObjectValue != nullptr) {
                CFRelease(value.tmpObjectValue);
                value.tmpObjectValue = nullptr;
            }
        }
    }
};

#endif
