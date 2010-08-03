Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DDF0F6008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:28:37 -0400 (EDT)
Date: Tue, 3 Aug 2010 04:31:10 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Re: Over-eager swapping
Message-ID: <20100803033108.GA23117@arachsys.com>
References: <20100802124734.GI2486@arachsys.com>
 <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Minchan Kim <minchan.kim@gmail.com> writes:

> Another possibility is _zone_reclaim_ in NUMA.
> Your working set has many anonymous page.
> 
> The zone_reclaim set priority to ZONE_RECLAIM_PRIORITY.
> It can make reclaim mode to lumpy so it can page out anon pages.
> 
> Could you show me /proc/sys/vm/[zone_reclaim_mode/min_unmapped_ratio] ?

Sure, no problem. On the machine with the /proc/meminfo I showed earlier,
these are

  # cat /proc/sys/vm/zone_reclaim_mode 
  0
  # cat /proc/sys/vm/min_unmapped_ratio 
  1

I haven't changed either of these from the kernel default.

Many thanks,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
