Date: Tue, 10 Jul 2007 11:50:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: -mm merge plans -- anti-fragmentation
In-Reply-To: <20070710152355.GI8779@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0707101148161.11906@schroedinger.engr.sgi.com>
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com>
 <20070710152355.GI8779@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Dave McCracken <dave.mccracken@oracle.com>, Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Nick Piggin wrote:

> > The sheer list of patches lined up behind this set is strong evidence that 
> > there are useful features which depend on a working order>0.  When you add in 
> > the existing code that has to struggle with allocation failures or resort to 
> > special pools (ie hugetlbfs), I see a clear vote for the need for this patch.
> 
> Really the only patches so far that I think have convincing reasons are
> memory unplug and hugepage, and both of those can get a long way by using
> a reserve zone (note it isn't entirely reserved, but still available for
> things like pagecache). Beyond that, is there a big demand, and do we
> want to make this fundamental change in direction in the kernel to
> satisfy that demand?

SLUB can use it to use large order pages which generate less lock 
contention which is important in SMP systems. Large pages also increase 
the object density in slabs.

> So small ones like order-1 and 2 seem reasonably good right now AFAIKS.

Sorry no. Without the antifrag patches I had failures even with order 1 
and 2 allocs from SLUB.

> If you perhaps want to say start using order-4  pages for slab or
> some other kernel memory allocations, then you can run into the situation
> where memory gets fragmented such that you have one sixteenth of your
> memory actualy used but you can't allocate from any of your slabs because
> there are no order-4 pages left. I guess this is a big difference between
> order-low failures and order-high.

The order that is readily reclaimable should be configurable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
