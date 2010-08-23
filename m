Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B21316007E9
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 09:56:13 -0400 (EDT)
Date: Mon, 23 Aug 2010 14:55:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100823135559.GS19797@csn.ul.ie>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie> <1282550442-15193-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1008230750380.4094@router.home> <20100823130315.GQ19797@csn.ul.ie> <alpine.DEB.2.00.1008230838320.5750@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008230838320.5750@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 08:41:56AM -0500, Christoph Lameter wrote:
> On Mon, 23 Aug 2010, Mel Gorman wrote:
> 
> > > The delta of the counters could also be reduced to increase accuracy.
> > > See refresh_zone_stat_thresholds().
> > True, but I thought that would introduce a constant performance penalty
> > for a corner case which I didn't like.
> 
> Sure, an increased frequency of updates would increase the chance of
> bouncing cachelines. But the bouncing cacheline scenario for the vm
> counters was tuned for applications that continually allocate pages in
> parallel.
> 
> When the vm gets into a state where continual reclaim is necessary then
> the counters are not that frequently updated. If the machine is already
> slowing down due to reclaim then the vm can likely affort more frequent
> counter updates.
> 

Ok, but is that better than this patch? Decreasing the size of the window by
reducing the threshold still leaves a window. There is still a small amount
of drift by summing up all the deltas but you get a much more accurate count
at the point of time it was important to know.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
