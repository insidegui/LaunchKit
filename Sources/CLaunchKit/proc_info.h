/*
 * Copyright (c) 2005 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */

#ifndef _PROC_INFO_H_
#define _PROC_INFO_H_

#import <TargetConditionals.h>

#if TARGET_OS_IOS

/* pbi_flags values */
#define PROC_FLAG_SYSTEM        1       /*  System process */
#define PROC_FLAG_TRACED        2       /* process currently being traced, possibly by gdb */
#define PROC_FLAG_INEXIT        4       /* process is working its way in exit() */
#define PROC_FLAG_PPWAIT        8
#define PROC_FLAG_LP64          0x10    /* 64bit process */
#define PROC_FLAG_SLEADER       0x20    /* The process is the session leader */
#define PROC_FLAG_CTTY          0x40    /* process has a control tty */
#define PROC_FLAG_CONTROLT      0x80    /* Has a controlling terminal */
#define PROC_FLAG_THCWD         0x100   /* process has a thread with cwd */
/* process control bits for resource starvation */
#define PROC_FLAG_PC_THROTTLE   0x200   /* In resource starvation situations, this process is to be throttled */
#define PROC_FLAG_PC_SUSP       0x400   /* In resource starvation situations, this process is to be suspended */
#define PROC_FLAG_PC_KILL       0x600   /* In resource starvation situations, this process is to be terminated */
#define PROC_FLAG_PC_MASK       0x600
/* process action bits for resource starvation */
#define PROC_FLAG_PA_THROTTLE   0x800   /* The process is currently throttled due to resource starvation */
#define PROC_FLAG_PA_SUSP       0x1000  /* The process is currently suspended due to resource starvation */
#define PROC_FLAG_PSUGID        0x2000   /* process has set privileges since last exec */
#define PROC_FLAG_EXEC          0x4000   /* process has called exec  */

/* proc_get_dirty() flags */
#define PROC_DIRTY_TRACKED              0x1
#define PROC_DIRTY_ALLOWS_IDLE_EXIT     0x2
#define PROC_DIRTY_IS_DIRTY             0x4
#define PROC_DIRTY_LAUNCH_IS_IN_PROGRESS   0x8

struct proc_bsdinfo {
    uint32_t                pbi_flags;              /* 64bit; emulated etc */
    uint32_t                pbi_status;
    uint32_t                pbi_xstatus;
    uint32_t                pbi_pid;
    uint32_t                pbi_ppid;
    uid_t                   pbi_uid;
    gid_t                   pbi_gid;
    uid_t                   pbi_ruid;
    gid_t                   pbi_rgid;
    uid_t                   pbi_svuid;
    gid_t                   pbi_svgid;
    uint32_t                rfu_1;                  /* reserved */
    char                    pbi_comm[MAXCOMLEN];
    char                    pbi_name[2 * MAXCOMLEN];  /* empty if no name is registered */
    uint32_t                pbi_nfiles;
    uint32_t                pbi_pgid;
    uint32_t                pbi_pjobc;
    uint32_t                e_tdev;                 /* controlling tty dev */
    uint32_t                e_tpgid;                /* tty process group id */
    int32_t                 pbi_nice;
    uint64_t                pbi_start_tvsec;
    uint64_t                pbi_start_tvusec;
};

#endif // TARGET_OS_IOS

#endif /*_PROC_INFO_H_ */
