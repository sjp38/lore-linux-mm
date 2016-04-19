Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68F546B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:07:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p188so23984493oih.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:07:22 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id 6si1114790otv.3.2016.04.19.09.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 09:07:21 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id s2so3248594iod.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:07:21 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 20 Apr 2016 00:07:21 +0800
Message-ID: <CANv7uPRLOS1kWos4k7aNXdx_Gx72BNxHWmJyOYs=GFydV63fAQ@mail.gmail.com>
Subject: mm: Page allocation from buddy system might delay the tasks on
 different SMP cores
From: GeHao Kang <kanghao0928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mel@csn.ul.ie
Cc: linux-mm@kvack.org

Hi Mel,
Through my experiment in SMP system, I find the mm_page_alloc_zone_locked
event produced by the fork system call on one CPU might delay the task
on another CPU.  According to the events-keme.txt in kernel documents,
the interrupts are disabled and cache lines between CPUs are dirtied
when this event happens.  Therefore, I am afraid that a task might be
interfered by the tasks on different CPUs
which at the same time request memory from the buddy allocator.

My questions are as follows:
    * Is it necessary to disable interrupts when allocating/freeing memory from
      buddy system?
    * Why the cache lines between CPUs are dirtied by the allocation in
      buddy system?

Thanks,
- Kang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
