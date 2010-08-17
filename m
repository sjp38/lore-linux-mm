Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BAF7D6B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 10:25:54 -0400 (EDT)
Received: by pxi5 with SMTP id 5so2710839pxi.14
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 07:25:53 -0700 (PDT)
Date: Tue, 17 Aug 2010 23:25:45 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/3] mm: page allocator: Update free page counters
 after pages are placed on the free list
Message-ID: <20100817142545.GB3884@barrios-desktop>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
 <1281951733-29466-2-git-send-email-mel@csn.ul.ie>
 <AANLkTi=wtAAaW4HoU7Oee=gNuM_t1hvf9sAK7RGRJ1AQ@mail.gmail.com>
 <20100817095917.GM19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100817095917.GM19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 10:59:18AM +0100, Mel Gorman wrote:
> On Tue, Aug 17, 2010 at 11:21:15AM +0900, Minchan Kim wrote:
> > Now allocation path decrease NR_FREE_PAGES _after_ it remove pages from buddy.
> > It can make that actually we don't have enough pages in buddy but
> > pretend to have enough pages.
> > It could make same situation with free path which is your concern.
> > So I think it can confuse watermark check in extreme case.
> > 
> > So don't we need to consider _allocation_ path with conservative?
> > 
> 
> I considered it and it would be desirable. The downside was that the
> paths became more complicated. Take rmqueue_bulk() for example. It could
> start by modifying the counters but there then needs to be a recovery
> path if all the requested pages were not allocated.
> 
> It'd be nice to see if these patches on their own were enough to
> alleviate the worst of the per-cpu-counter drift before adding new
> branches to the allocation path.
> 
> Does that make sense?

No problem. It was a usecase of big machine. 
I also hope we don't add unnecessary overhead in normal machine due to unlikely problem.
Let's consider it by further step if it isn't enough.

Thanks, Mel.

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
