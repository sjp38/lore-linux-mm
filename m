Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04AF06B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 13:59:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so12739579wme.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:59:12 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id x131si5445972wmb.35.2016.04.19.10.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 10:59:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 956591C2107
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 18:59:11 +0100 (IST)
Date: Tue, 19 Apr 2016 18:59:07 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: Page allocation from buddy system might delay the tasks on
 different SMP cores
Message-ID: <20160419175907.GC15167@techsingularity.net>
References: <CANv7uPRLOS1kWos4k7aNXdx_Gx72BNxHWmJyOYs=GFydV63fAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CANv7uPRLOS1kWos4k7aNXdx_Gx72BNxHWmJyOYs=GFydV63fAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: GeHao Kang <kanghao0928@gmail.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org

On Wed, Apr 20, 2016 at 12:07:21AM +0800, GeHao Kang wrote:
> Hi Mel,
> Through my experiment in SMP system, I find the mm_page_alloc_zone_locked
> event produced by the fork system call on one CPU might delay the task
> on another CPU.  According to the events-keme.txt in kernel documents,
> the interrupts are disabled and cache lines between CPUs are dirtied
> when this event happens.  Therefore, I am afraid that a task might be
> interfered by the tasks on different CPUs
> which at the same time request memory from the buddy allocator.
> 
> My questions are as follows:
>     * Is it necessary to disable interrupts when allocating/freeing memory from
>       buddy system?

Yes.

>     * Why the cache lines between CPUs are dirtied by the allocation in
>       buddy system?
> 

Because a page can be freed on one CPU and allocated using another.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
