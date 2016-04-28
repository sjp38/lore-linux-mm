Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD116B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 12:42:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so69134304lfq.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:42:34 -0700 (PDT)
Received: from mail.rt-rk.com (mx2.rt-rk.com. [89.216.37.149])
        by mx.google.com with ESMTPS id z21si38258519wmh.56.2016.04.28.09.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 09:42:32 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.rt-rk.com (Postfix) with ESMTP id 7F2461A2399
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 18:42:30 +0200 (CEST)
Received: from [10.80.11.84] (rtrkn220.domain.local [10.80.11.84])
	by mail.rt-rk.com (Postfix) with ESMTPSA id 6C2271A221F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 18:42:30 +0200 (CEST)
From: Bojan Prtvar <bojan.prtvar@rt-rk.com>
Subject: memtest help
Message-ID: <57223D77.6020502@rt-rk.com>
Date: Thu, 28 Apr 2016 18:42:31 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello everyone,

I need to test all RAM cells on a linux ARM embedded system. My use case 
is very similar to the one described in [1] expect the fact I also have 
strong requirements on minimizing the boot time impact.
Instead of doing that from the bootloader, I decided to evaluate the 
linux memtest feature introduced with [2].

My questions are:

1)
Does the  early_memtest() as called in [3] really covers *all* RAM cells?

2)
As memtest happens very early in boot stage, what primitives I can use 
to measure duration of early_memtest()? Are there any known heuristics? 
I need to test ~2GB of RAM.
This is my major concern.

3)
It seems reasonable to expose the number of detected bad cells to user 
space. I was thinking about sysfs. Are the patches welcomed?

[1]
http://www.linuxforums.org/forum/newbie/173847-how-do-memory-ram-test-when-linux-running.html
[2]
http://lkml.iu.edu/hypermail/linux/kernel/1503.1/00566.html
[3]
http://lxr.free-electrons.com/source/arch/arm/mm/init.c#L291

Thanks,
Bojan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
