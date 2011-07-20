Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4916B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 01:53:19 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3397343qwa.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 22:53:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311130413.15392.326.camel@sli10-conroe>
References: <1311130413.15392.326.camel@sli10-conroe>
Date: Wed, 20 Jul 2011 14:53:16 +0900
Message-ID: <CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, Jul 20, 2011 at 11:53 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> per-task block plug can reduce block queue lock contention and increase request
> merge. Currently page reclaim doesn't support it. I originally thought page
> reclaim doesn't need it, because kswapd thread count is limited and file cache
> write is done at flusher mostly.
> When I test a workload with heavy swap in a 4-node machine, each CPU is doing
> direct page reclaim and swap. This causes block queue lock contention. In my
> test, without below patch, the CPU utilization is about 2% ~ 7%. With the
> patch, the CPU utilization is about 1% ~ 3%. Disk throughput isn't changed.

Why doesn't it enhance through?
It means merge is rare?

> This should improve normal kswapd write and file cache write too (increase
> request merge for example), but might not be so obvious as I explain above.

CPU utilization enhance on  4-node machine with heavy swap?
I think it isn't common situation.

And I don't want to add new stack usage if it doesn't have a benefit.
As you know, direct reclaim path has a stack overflow.
These days, Mel, Dave and Christoph try to remove write path in
reclaim for solving stack usage and enhance write performance.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
