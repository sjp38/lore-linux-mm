Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7C896B0268
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:03:22 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so854377wmd.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:03:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30si11087136wrl.427.2017.12.19.01.03.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 01:03:21 -0800 (PST)
Date: Tue, 19 Dec 2017 10:03:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmots build error: version control conflict marker in file
Message-ID: <20171219090319.GD2787@dhcp22.suse.cz>
References: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

[CC Johannes]

On Tue 19-12-17 09:36:20, Dmitry Vyukov wrote:
> Hello,
> 
> syzbot hit the following crash on 80f3359313dfd0e574d0d245dd93a7c3bf39e1fa
> git://git.cmpxchg.org/linux-mmots.git master
> 
> failed to run /usr/bin/make [make bzImage -j 32
> CC=/syzkaller/gcc/bin/gcc]: exit status 2
> scripts/kconfig/conf  --silentoldconfig Kconfig
>   CHK     include/config/kernel.release
>   CHK     include/generated/uapi/linux/version.h
>   UPD     include/config/kernel.release
>   CHK     scripts/mod/devicetable-offsets.h
>   CHK     include/generated/utsrelease.h
>   UPD     include/generated/utsrelease.h
>   CHK     include/generated/bounds.h
>   CHK     include/generated/timeconst.h
>   CC      arch/x86/kernel/asm-offsets.s
> In file included from ./arch/x86/include/asm/cpufeature.h:5:0,
>                  from ./arch/x86/include/asm/thread_info.h:53,
>                  from ./include/linux/thread_info.h:38,
>                  from ./arch/x86/include/asm/preempt.h:7,
>                  from ./include/linux/preempt.h:81,
>                  from ./include/linux/spinlock.h:51,
>                  from ./include/linux/mmzone.h:8,
>                  from ./include/linux/gfp.h:6,
>                  from ./include/linux/slab.h:15,
>                  from ./include/linux/crypto.h:24,
>                  from arch/x86/kernel/asm-offsets.c:9:
> ./arch/x86/include/asm/processor.h:340:1: error: version control
> conflict marker in file
>  <<<<<<< HEAD
>  ^~~~~~~
> ./arch/x86/include/asm/processor.h:346:24: error: field a??stacka?? has
> incomplete type
>   struct SYSENTER_stack stack;
>                         ^~~~~
> ./arch/x86/include/asm/processor.h:347:1: error: version control
> conflict marker in file
>  =======
>  ^~~~~~~
> Kbuild:56: recipe for target 'arch/x86/kernel/asm-offsets.s' failed
> make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
> Makefile:1090: recipe for target 'prepare0' failed
> make: *** [prepare0] Error 2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
