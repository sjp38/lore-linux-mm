Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD7B46B0003
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 07:13:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k44so6928869wrc.3
        for <linux-mm@kvack.org>; Sat, 17 Mar 2018 04:13:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q13sor68005wrg.76.2018.03.17.04.13.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 17 Mar 2018 04:13:55 -0700 (PDT)
From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Sat, 17 Mar 2018 12:13:39 +0100 (CET)
Subject: clang fails on linux-next since commit 8bf705d13039
Message-ID: <alpine.DEB.2.20.1803171208370.21003@alpaca>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, kasan-dev@googlegroups.com, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org

Hi Dmitry, hi Ingo,

since commit 8bf705d13039 ("locking/atomic/x86: Switch atomic.h to use atomic-instrumented.h")
on linux-next (tested and bisected from tag next-20180316), compiling the 
kernel with clang fails with:

In file included from arch/x86/entry/vdso/vdso32/vclock_gettime.c:33:
In file included from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15:
In file included from ./arch/x86/include/asm/vgtod.h:6:
In file included from ./include/linux/clocksource.h:13:
In file included from ./include/linux/timex.h:56:
In file included from ./include/uapi/linux/timex.h:56:
In file included from ./include/linux/time.h:6:
In file included from ./include/linux/seqlock.h:36:
In file included from ./include/linux/spinlock.h:51:
In file included from ./include/linux/preempt.h:81:
In file included from ./arch/x86/include/asm/preempt.h:7:
In file included from ./include/linux/thread_info.h:38:
In file included from ./arch/x86/include/asm/thread_info.h:53:
In file included from ./arch/x86/include/asm/cpufeature.h:5:
In file included from ./arch/x86/include/asm/processor.h:21:
In file included from ./arch/x86/include/asm/msr.h:67:
In file included from ./arch/x86/include/asm/atomic.h:279:
./include/asm-generic/atomic-instrumented.h:295:10: error: invalid output size for constraint '=a'
                return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
                       ^
./arch/x86/include/asm/cmpxchg.h:149:2: note: expanded from macro 'arch_cmpxchg'
        __cmpxchg(ptr, old, new, sizeof(*(ptr)))
        ^
./arch/x86/include/asm/cmpxchg.h:134:2: note: expanded from macro '__cmpxchg'
        __raw_cmpxchg((ptr), (old), (new), (size), LOCK_PREFIX)
        ^
./arch/x86/include/asm/cmpxchg.h:95:17: note: expanded from macro '__raw_cmpxchg'
                             : "=a" (__ret), "+m" (*__ptr)              \
                                     ^

(... and some more similar and closely related errors)

Best regards,

Lukas
