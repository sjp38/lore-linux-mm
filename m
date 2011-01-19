Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 53BF66B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 18:07:34 -0500 (EST)
Date: Wed, 19 Jan 2011 17:07:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <alpine.DEB.2.00.1101191212090.19519@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1101191703270.25961@router.home>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com> <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com> <alpine.DEB.2.00.1101191351010.20403@router.home>
 <20110119200625.GD15568@one.firstfloor.org> <alpine.DEB.2.00.1101191212090.19519@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011, David Rientjes wrote:

> On Wed, 19 Jan 2011, Andi Kleen wrote:
>
> > cpusets didn't exist when I designed that. But the idea was that
> > the kernel has a first choice ("hit") and any other node is a "miss"
> > that may need investigation.  So yes I would consider cpuset config as an
> > intention too and should be counted as hit/miss.
> >
>
> Ok, so there's no additional modification that needs to be made with the
> patch (other than perhaps some more descriptive documentation of a
> NUMA_HIT and NUMA_MISS).  When the kernel passes all zones into the page
> allocator, it's relying on cpusets to reduce that zonelist to only
> allowable nodes by using ALLOC_CPUSET.  If we can allocate from the first
> zone allowed by the cpuset, it will be treated as a hit; otherwise, it
> will be treated as a miss.  That's better than treating everything as a
> miss when the cpuset doesn't include the first node.

To be more specific: It is the first zone of the zonelist that the cpuset
context provided for allocation from the node that the process is
currently executing on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
