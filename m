Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CB3066007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:04:41 -0400 (EDT)
Date: Mon, 23 Aug 2010 11:04:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100823135559.GS19797@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1008231059580.8601@router.home>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie> <1282550442-15193-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1008230750380.4094@router.home> <20100823130315.GQ19797@csn.ul.ie> <alpine.DEB.2.00.1008230838320.5750@router.home>
 <20100823135559.GS19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Mel Gorman wrote:

> > When the vm gets into a state where continual reclaim is necessary then
> > the counters are not that frequently updated. If the machine is already
> > slowing down due to reclaim then the vm can likely affort more frequent
> > counter updates.
> >
>
> Ok, but is that better than this patch? Decreasing the size of the window by
> reducing the threshold still leaves a window. There is still a small amount
> of drift by summing up all the deltas but you get a much more accurate count
> at the point of time it was important to know.

In order to make that decision we would need to know what deltas make a
significant difference. Would be also important to know if there are any
other counters that have issues. If so then the reduction of the
thresholds is addressing these problems in a number of counters.

I have no objection against this approach here but it may just be bandaid
on a larger issue that could be approached in a cleaner way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
