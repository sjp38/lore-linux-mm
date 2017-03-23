Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9594E6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 04:49:34 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id r69so35080252vke.4
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:49:34 -0700 (PDT)
Received: from mail-vk0-x22a.google.com (mail-vk0-x22a.google.com. [2607:f8b0:400c:c05::22a])
        by mx.google.com with ESMTPS id t42si180842uag.63.2017.03.23.01.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 01:49:33 -0700 (PDT)
Received: by mail-vk0-x22a.google.com with SMTP id r69so32767745vke.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:49:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAK8P3a2DskgumXx5XuzN8J-T0jmhXgD5dPZ4QWBtDA3WvMCyoQ@mail.gmail.com>
References: <20170322111022.85745-1-dvyukov@google.com> <CAK8P3a2pm2EsxOxxf7SsEObxcNFJP60JOY_78a19g2kD4pL6Rw@mail.gmail.com>
 <CAK8P3a2DskgumXx5XuzN8J-T0jmhXgD5dPZ4QWBtDA3WvMCyoQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 23 Mar 2017 09:49:12 +0100
Message-ID: <CACT4Y+aL-X8VbFC0kfHG8tKVSanhkY9a_hNrEcAHGUyQk1WtSA@mail.gmail.com>
Subject: Re: [PATCH] asm-generic: fix compilation failure in cmpxchg_double()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Mar 22, 2017 at 10:27 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wed, Mar 22, 2017 at 12:27 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Wed, Mar 22, 2017 at 12:10 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> Arnd reported that the new code leads to compilation failures
>>> with some versions of gcc. I've filed gcc issue 72873,
>>> but we need a kernel fix as well.
>>>
>>> Remove instrumentation from cmpxchg_double() for now.
>>
>> Thanks, I also checked that fixes the build error for me.
>
> I got a new variant of the bug in
> arch/x86/include/asm/cmpxchg_32.h:set_64bit() now.
>
> In file included from /git/arm-soc/arch/x86/include/asm/cmpxchg.h:142:0,
>                  from /git/arm-soc/arch/x86/include/asm/atomic.h:7,
>                  from /git/arm-soc/arch/x86/include/asm/msr.h:66,
>                  from /git/arm-soc/arch/x86/include/asm/processor.h:20,
>                  from /git/arm-soc/arch/x86/include/asm/cpufeature.h:4,
>                  from /git/arm-soc/arch/x86/include/asm/thread_info.h:52,
>                  from /git/arm-soc/include/linux/thread_info.h:25,
>                  from /git/arm-soc/arch/x86/include/asm/preempt.h:6,
>                  from /git/arm-soc/include/linux/preempt.h:80,
>                  from /git/arm-soc/include/linux/spinlock.h:50,
>                  from /git/arm-soc/include/linux/mmzone.h:7,
>                  from /git/arm-soc/include/linux/gfp.h:5,
>                  from /git/arm-soc/include/linux/mm.h:9,
>                  from /git/arm-soc/mm/khugepaged.c:3:
> /git/arm-soc/mm/khugepaged.c: In function 'khugepaged':
> /git/arm-soc/arch/x86/include/asm/cmpxchg_32.h:29:2: error: 'asm'
> operand has impossible constraints
>   asm volatile("\n1:\t"
>
> Defconfig is at http://pastebin.com/raw/Pthhv5iU


I can't reproduce it with gcc 4.8.4, 7.0.0, 7.0.1.

Are you sure it's related to my recent change? I did not touch set_64bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
