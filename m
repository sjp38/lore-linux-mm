Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C25226B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 04:39:09 -0400 (EDT)
Date: Wed, 8 Sep 2010 09:38:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/9] Reduce latencies and improve overall reclaim
	efficiency v1
Message-ID: <20100908083851.GA29263@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <20100908115807.C916.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100908115807.C916.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 12:14:29PM +0900, KOSAKI Motohiro wrote:
> > There have been numerous reports of stalls that pointed at the problem being
> > somewhere in the VM. There are multiple roots to the problems which means
> > dealing with any of the root problems in isolation is tricky to justify on
> > their own and they would still need integration testing. This patch series
> > gathers together three different patch sets which in combination should
> > tackle some of the root causes of latency problems being reported.
> > 
> > The first patch improves vmscan latency by tracking when pages get reclaimed
> > by shrink_inactive_list. For this series, the most important results is
> > being able to calculate the scanning/reclaim ratio as a measure of the
> > amount of work being done by page reclaim.
> > 
> > Patches 2 and 3 account for the time spent in congestion_wait() and avoids
> > calling going to sleep on congestion when it is unnecessary. This is expected
> > to reduce stalls in situations where the system is under memory pressure
> > but not due to congestion.
> > 
> > Patches 4-8 were originally developed by Kosaki Motohiro but reworked for
> > this series. It has been noted that lumpy reclaim is far too aggressive and
> > trashes the system somewhat. As SLUB uses high-order allocations, a large
> > cost incurred by lumpy reclaim will be noticeable. It was also reported
> > during transparent hugepage support testing that lumpy reclaim was trashing
> > the system and these patches should mitigate that problem without disabling
> > lumpy reclaim.
> 
> Wow, I'm sorry my lazyness bother you. I'll join to test this patch series
> ASAP and take a feedback soon.
> 

It did not bother me at all. I generally agreed with the direction and
it seemed sensible to take them into consideration before patches 9 and
10 in particular and make sure they all played nicely together.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
