/*
 * Tencent is pleased to support the open source community by making
 * MMKV available.
 *
 * Copyright (C) 2019 THL A29 Limited, a Tencent company.
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

#import "SkyEyeMMKVLog.h"

#ifdef ENABLE_MMKV_LOG

#ifndef NDEBUG
PREFIXNAME(MMKVLogLevel) g_currentLogLevel = PREFIXNAME(MMKVLogDebug);
#else
MMKVLogLevel g_currentLogLevel = MMKVLogInfo;
#endif

static const char *MMKVLogLevelDesc(PREFIXNAME(MMKVLogLevel) level) {
	switch (level) {
		case PREFIXNAME(MMKVLogDebug):
			return "D";
		case PREFIXNAME(MMKVLogInfo):
			return "I";
		case PREFIXNAME(MMKVLogWarning):
			return "W";
		case PREFIXNAME(MMKVLogError):
			return "E";
		default:
			return "N";
	}
}

void _MMKVLogWithLevel(PREFIXNAME(MMKVLogLevel) level, const char *file, const char *func, int line, NSString *format, ...) {
	if (level >= g_currentLogLevel) {
		va_list argList;
		va_start(argList, format);
		NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
		va_end(argList);

		if (PREFIXNAME(g_isLogRedirecting)) {
			[g_callbackHandler mmkvLogWithLevel:level file:file line:line func:func message:message];
		} else {
			NSLog(@"[%s] <%s:%d::%s> %@", MMKVLogLevelDesc(level), file, line, func, message);
		}
	}
}

#endif // ENABLE_MMKV_LOG
