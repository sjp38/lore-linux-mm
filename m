Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 73C766B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 06:22:39 -0500 (EST)
Date: Thu, 26 Feb 2009 11:22:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090226112232.GE32756@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1235647139.16552.34.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Lin Ming <ming.m.lin@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 01:18:59PM +0200, Pekka Enberg wrote:
> On Thu, 2009-02-26 at 11:03 +0000, Mel Gorman wrote:
> > On Thu, Feb 26, 2009 at 05:10:27PM +0800, Lin Ming wrote:
> > > We tested this v2 patch series with 2.6.29-rc6 on different machines.
> > > 
> > 
> > Wonderful, thanks.
> > 
> > > 		4P qual-core	2P qual-core	2P qual-core HT
> > > 		tigerton	stockley	Nehalem
> > > 		------------------------------------------------
> > > tbench		+3%		+2%		0%
> > 
> > Nice.
> > 
> > > oltp		-2%		0%		0%
> > 
> > This is a big disappointment and somewhat confusing that it is so
> > severe. For sysbench I was seeing on six different machines;
> > 
> > 	50834.14        51763.08    1.79%
> > 	61852.08        61966.58    0.18%
> > 	5935.98         5980.06     0.74%
> > 	29227.78        30167.72    3.12%
> > 	66702.67        66534.76   -0.25%
> > 	26643.18        26542.59   -0.38%
> > 
> > So, two smallish regressions but mainly gains. Then again, I'm becoming
> > more and more convinced that sysbench doesn't really represent a proper
> > OLTP workload.
> > 
> > I'd like to understand more how the page allocator at least was being used
> > during your tests. Would it be possible to get a full profile (including
> > instruction if possible and the vmlinux file) for both kernels please?
> > 
> > If you can get the profiles, confirm the regression is still there as
> > sometimes profiling can alter the outcome. Even if this happens, the
> > profile will tell me where time is being spent.
> > 
> > > aim7		0%		0%		0%
> > > specjbb2005	+3%		0%		0%
> > > hackbench	0%		0%		0%	
> > > 
> > > netperf:
> > > TCP-S-112k	0%		-1%		0%
> > > TCP-S-64k	0%		-1%		+1%
> > > TCP-RR-1	0%		0%		+1%
> > > UDP-U-4k	-2%		0%		-2%
> > 
> > Pekka, for this test was SLUB or the page allocator handling the 4K
> > allocations?
> 
> The page allocator. The pass-through revert is not in 2.6.29-rc6 and I
> won't be sending it until 2.6.30 opens up.
> 

In that case, Lin, could I also get the profiles for UDP-U-4K please so I
can see how time is being spent and why it might have gotten worse?

Thanks

> > 
> > > UDP-U-1k	+3%		0%		0%
> > > UDP-RR-1	0%		0%		0%
> > > UDP-RR-512	-1%		0%		+1%
> > > 
> > > Lin Ming
> > > 
> > 
> > Thanks a million for testing.
> > 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
