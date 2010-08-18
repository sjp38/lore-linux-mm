Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A3D1F6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:57:35 -0400 (EDT)
Received: by pwi3 with SMTP id 3so372883pwi.14
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 07:57:34 -0700 (PDT)
Date: Wed, 18 Aug 2010 23:57:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100818145725.GA5744@barrios-desktop>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
 <1281951733-29466-3-git-send-email-mel@csn.ul.ie>
 <20100816094350.GH19797@csn.ul.ie>
 <20100816160623.GB15103@cmpxchg.org>
 <20100817101655.GN19797@csn.ul.ie>
 <20100817142040.GA3884@barrios-desktop>
 <20100818085123.GU19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818085123.GU19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 09:51:23AM +0100, Mel Gorman wrote:
> > What's a window low and min wmark? Maybe I can miss your point. 
> > 
> 
> The window is due to the fact kswapd is not awake yet. The window is because
> kswapd might not be awake as NR_FREE_PAGES is higher than it should be. The
> system is really somewhere between the low and min watermark but we are not
> taking the accurate measure until kswapd gets woken up. The first allocation
> to notice we are below the low watermark (be it due to vmstat refreshing or
> that NR_FREE_PAGES happens to report we are below the watermark regardless of
> any drift) wakes kswapd and other callers then take an accurate count hence
> "we could breach the watermark but I'm expecting it can only happen for at
> worst one allocation".

Right. I misunderstood your word. 
One more question. 

Could you explain live lock scenario?

I looked over the code. Although the VM pass zone_watermark_ok by luck,
It can't allocate the page from buddy and then might go OOM. 
When do we meet live lock case?

I think the description in change log would be better to understand 
this patch in future. 

Thanks. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
