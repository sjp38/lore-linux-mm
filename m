Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 540336B028E
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 22:06:07 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so3064078pdj.27
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 19:06:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zm8si4758775pac.71.2014.03.21.19.06.06
        for <linux-mm@kvack.org>;
        Fri, 21 Mar 2014 19:06:06 -0700 (PDT)
Date: Fri, 21 Mar 2014 19:12:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 203/499] include/linux/vmstat.h:32:2: error:
 implicit declaration of function 'raw_cpu_inc'
Message-Id: <20140321191216.776e3281.akpm@linux-foundation.org>
In-Reply-To: <532cde58.CgQv/f5/Xxy3YpRB%fengguang.wu@intel.com>
References: <532cde58.CgQv/f5/Xxy3YpRB%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Sat, 22 Mar 2014 08:50:32 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   4ddd4bc6e081ef29f7adaacb357b77052fefcd7e
> commit: 4ac4f1a27eed39f833aa8874515127e3bd0ff971 [203/499] vmstat: use raw_cpu_ops to avoid false positives on preemption checks
> config: make ARCH=x86_64 allnoconfig
> 
> Note: the mmotm/master HEAD 4ddd4bc6e081ef29f7adaacb357b77052fefcd7e builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings:
> 
>    In file included from include/linux/mm.h:897:0,
>                     from include/linux/suspend.h:8,
>                     from arch/x86/kernel/asm-offsets.c:12:
>    include/linux/vmstat.h: In function '__count_vm_event':
> >> include/linux/vmstat.h:32:2: error: implicit declaration of function 'raw_cpu_inc' [-Werror=implicit-function-declaration]
>      raw_cpu_inc(vm_event_states.event[item]);
>      ^
>    include/linux/vmstat.h: In function '__count_vm_events':
> >> include/linux/vmstat.h:42:2: error: implicit declaration of function 'raw_cpu_add' [-Werror=implicit-function-declaration]
>      raw_cpu_add(vm_event_states.event[item], delta);
>      ^
>    cc1: some warnings being treated as errors
>    make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>    make[2]: Target `__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target `prepare' not remade because of errors.
>    make: *** [sub-make] Error 2

bah, OK, patch ordering problem.  I'll shuffle them around and we'll be
stuck with a small and quite minor bisection window where the kernel
emits warnings at runtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
