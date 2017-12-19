Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC986B025E
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:01:56 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id a72so12390505ioe.13
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:01:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f189si10688004iof.277.2017.12.19.12.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 12:01:54 -0800 (PST)
Subject: Re: mmots build error: version control conflict marker in file
From: Randy Dunlap <rdunlap@infradead.org>
References: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
 <20171219090319.GD2787@dhcp22.suse.cz>
 <7cec6594-94c7-a238-4046-0061a9adc20d@infradead.org>
Message-ID: <1352454e-bdb1-fcb0-8410-a89799c2f1b9@infradead.org>
Date: Tue, 19 Dec 2017 12:01:51 -0800
MIME-Version: 1.0
In-Reply-To: <7cec6594-94c7-a238-4046-0061a9adc20d@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

On 12/19/2017 12:00 PM, Randy Dunlap wrote:
> On 12/19/2017 01:03 AM, Michal Hocko wrote:
>> [CC Johannes]
>>
>> On Tue 19-12-17 09:36:20, Dmitry Vyukov wrote:
>>> Hello,
>>>
>>> syzbot hit the following crash on 80f3359313dfd0e574d0d245dd93a7c3bf39e1fa
>>> git://git.cmpxchg.org/linux-mmots.git master
>>>
>>> failed to run /usr/bin/make [make bzImage -j 32
>>> CC=/syzkaller/gcc/bin/gcc]: exit status 2
>>> scripts/kconfig/conf  --silentoldconfig Kconfig
>>>   CHK     include/config/kernel.release
>>>   CHK     include/generated/uapi/linux/version.h
>>>   UPD     include/config/kernel.release
>>>   CHK     scripts/mod/devicetable-offsets.h
>>>   CHK     include/generated/utsrelease.h
>>>   UPD     include/generated/utsrelease.h
>>>   CHK     include/generated/bounds.h
>>>   CHK     include/generated/timeconst.h
>>>   CC      arch/x86/kernel/asm-offsets.s
>>> In file included from ./arch/x86/include/asm/cpufeature.h:5:0,
>>>                  from ./arch/x86/include/asm/thread_info.h:53,
>>>                  from ./include/linux/thread_info.h:38,
>>>                  from ./arch/x86/include/asm/preempt.h:7,
>>>                  from ./include/linux/preempt.h:81,
>>>                  from ./include/linux/spinlock.h:51,
>>>                  from ./include/linux/mmzone.h:8,
>>>                  from ./include/linux/gfp.h:6,
>>>                  from ./include/linux/slab.h:15,
>>>                  from ./include/linux/crypto.h:24,
>>>                  from arch/x86/kernel/asm-offsets.c:9:
>>> ./arch/x86/include/asm/processor.h:340:1: error: version control
>>> conflict marker in file
>>>  <<<<<<< HEAD
>>>  ^~~~~~~
>>> ./arch/x86/include/asm/processor.h:346:24: error: field a??stacka?? has
>>> incomplete type
>>>   struct SYSENTER_stack stack;
>>>                         ^~~~~
>>> ./arch/x86/include/asm/processor.h:347:1: error: version control
>>> conflict marker in file
>>>  =======
>>>  ^~~~~~~
>>> Kbuild:56: recipe for target 'arch/x86/kernel/asm-offsets.s' failed
>>> make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>>> Makefile:1090: recipe for target 'prepare0' failed
>>> make: *** [prepare0] Error 2
>>
> 
> Wow. arch/x86/include/asm/processor.h around line 340++ looks like this:
> 
> <<<<<<< HEAD
> struct SYSENTER_stack {
> 	unsigned long		words[64];
> };
> 
> struct SYSENTER_stack_page {
> 	struct SYSENTER_stack stack;
> =======
> struct entry_stack {
> 	unsigned long		words[64];
> };
> 
> struct entry_stack_page {
> 	struct entry_stack stack;
>>>>>>>> linux-next/akpm-base
> } __aligned(PAGE_SIZE);

That's only in the git tree.  The mmots that I get from tarballs/patches
does not have this problem.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
