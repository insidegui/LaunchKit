/*
 * Copyright (c) 2006-2012 Apple Inc. All rights reserved.
 *
 * @APPLE_APACHE_LICENSE_HEADER_START@
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @APPLE_APACHE_LICENSE_HEADER_END@
 */

#include <sys/types.h>

#ifndef _LAUNCHCTL_VPROC_PRIV_H_
#define _LAUNCHCTL_VPROC_PRIV_H_

typedef enum {
	VPROC_GSK_MGR_UID = 3,
	VPROC_GSK_MGR_PID = 4,
	VPROC_GSK_MGR_NAME = 6,
} vproc_gsk_keys;

void *vproc_swap_string(void *, vproc_gsk_keys, const char *, char **);
void *vproc_swap_integer(void *, vproc_gsk_keys, int64_t, int64_t *);

#endif
