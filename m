Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 17B498D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 15:06:32 -0500 (EST)
Date: Wed, 19 Jan 2011 21:06:25 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is not allowed
Message-ID: <20110119200625.GD15568@one.firstfloor.org>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com> <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com> <alpine.DEB.2.00.1101191351010.20403@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101191351010.20403@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 01:59:01PM -0600, Christoph Lameter wrote:
> On Tue, 18 Jan 2011, David Rientjes wrote:
> 
> > It depends on the semantics of NUMA_MISS: if no local nodes are allowed by
> > current's cpuset (a pretty poor cpuset config :), then it seems logical
> > that all allocations would be a miss.
> 
> NUMA_MISS is defined as an allocations that did not succeed on the node
> the allocation was "intended" for. So far "intended" as been interpreted
> as allocations that are either intended for the closest numa node or the
> preferred node. One could say that the cpuset config is an "intention".
> 
> Andi?

cpusets didn't exist when I designed that. But the idea was that
the kernel has a first choice ("hit") and any other node is a "miss"
that may need investigation.  So yes I would consider cpuset config as an 
intention too and should be counted as hit/miss.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
