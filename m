Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 478F46B0253
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:22:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so216761386pfe.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:22:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ul1si21444299pab.19.2016.04.29.02.22.18
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 02:22:18 -0700 (PDT)
Subject: Re: memtest help
References: <57223D77.6020502@rt-rk.com>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <572327BE.7030606@arm.com>
Date: Fri, 29 Apr 2016 10:22:06 +0100
MIME-Version: 1.0
In-Reply-To: <57223D77.6020502@rt-rk.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bojan Prtvar <bojan.prtvar@rt-rk.com>, linux-mm@kvack.org

On 28/04/16 17:42, Bojan Prtvar wrote:
> Hello everyone,
> 
> I need to test all RAM cells on a linux ARM embedded system. My use case
> is very similar to the one described in [1] expect the fact I also have
> strong requirements on minimizing the boot time impact.
> Instead of doing that from the bootloader, I decided to evaluate the
> linux memtest feature introduced with [2].
> 
> My questions are:
> 
> 1)
> Does the  early_memtest() as called in [3] really covers *all* RAM cells?

No.

> 
> 2)
> As memtest happens very early in boot stage, what primitives I can use
> to measure duration of early_memtest()? Are there any known heuristics?
> I need to test ~2GB of RAM.
> This is my major concern.

Stopwatch?

> 
> 3)
> It seems reasonable to expose the number of detected bad cells to user
> space. I was thinking about sysfs. Are the patches welcomed?
> 

$ dmesg | grep "bad mem"

Cheers
Vladimir

> [1]
> http://www.linuxforums.org/forum/newbie/173847-how-do-memory-ram-test-when-linux-running.html
> 
> [2]
> http://lkml.iu.edu/hypermail/linux/kernel/1503.1/00566.html
> [3]
> http://lxr.free-electrons.com/source/arch/arm/mm/init.c#L291
> 
> Thanks,
> Bojan
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
