Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 704FA6B03BF
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 09:42:00 -0400 (EDT)
Date: Mon, 23 Aug 2010 08:41:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100823130315.GQ19797@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1008230838320.5750@router.home>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie> <1282550442-15193-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1008230750380.4094@router.home> <20100823130315.GQ19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Mel Gorman wrote:

> > The delta of the counters could also be reduced to increase accuracy.
> > See refresh_zone_stat_thresholds().
> True, but I thought that would introduce a constant performance penalty
> for a corner case which I didn't like.

Sure, an increased frequency of updates would increase the chance of
bouncing cachelines. But the bouncing cacheline scenario for the vm
counters was tuned for applications that continually allocate pages in
parallel.

When the vm gets into a state where continual reclaim is necessary then
the counters are not that frequently updated. If the machine is already
slowing down due to reclaim then the vm can likely affort more frequent
counter updates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
