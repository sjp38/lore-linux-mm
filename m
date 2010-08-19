Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A7B046B02AF
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:45:04 -0400 (EDT)
Received: by pzk33 with SMTP id 33so894878pzk.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 08:45:01 -0700 (PDT)
Date: Fri, 20 Aug 2010 00:44:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100819154453.GA7325@barrios-desktop>
References: <20100818145725.GA5744@barrios-desktop>
 <20100819080624.GX19797@csn.ul.ie>
 <AANLkTi=Mtc_7b5WG4nmwbFYg8yijyMSG1AUTzy+QTwoy@mail.gmail.com>
 <20100819103839.GZ19797@csn.ul.ie>
 <20100819140150.GA6805@barrios-desktop>
 <20100819140946.GA19797@csn.ul.ie>
 <20100819143439.GB6805@barrios-desktop>
 <20100819150739.GB19797@csn.ul.ie>
 <20100819152233.GD6805@barrios-desktop>
 <20100819154032.GE19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819154032.GE19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 04:40:33PM +0100, Mel Gorman wrote:
 
> The patch leader now reads as
> 
> Ordinarily watermark checks are based on the vmstat NR_FREE_PAGES as it is
> cheaper than scanning a number of lists. To avoid synchronization overhead,
> counter deltas are maintained on a per-cpu basis and drained both periodically
> and when the delta is above a threshold. On large CPU systems, the difference
> between the estimated and real value of NR_FREE_PAGES can be very high.
> If NR_FREE_PAGES is much higher than number of real free page in buddy, the VM
> can allocate pages below min watermark, at worst reducing the real number of
> pages to zero. Even if the OOM killer kills some victim for freeing memory, it
> may not free memory if the exit path requires a new page resulting in livelock.
> 
> This patch introduces zone_nr_free_pages() to take a slightly more accurate
> estimate of NR_FREE_PAGES while kswapd is awake. The estimate is not perfect
> and may result in cache line bounces but is expected to be lighter than the
> IPI calls necessary to continually drain the per-cpu counters while kswapd
> is awake.
> 
> Is that better?

Good!

> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
