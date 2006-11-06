Date: Mon, 6 Nov 2006 09:15:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <200611061807.16890.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0611060912070.25496@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <200611061756.00623.ak@suse.de> <Pine.LNX.4.64.0611060856590.25351@schroedinger.engr.sgi.com>
 <200611061807.16890.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Nov 2006, Andi Kleen wrote:

> I know this.
> 
> > And you are right: It does not matter for those that  
> > have never been used.
> 
> This means it is fine to replace the constructor with an function
> that runs after kmem_cache_alloc() in this case.

No its not. RCU means that there are potential accesses after a object has 
been freed and even after an object has been reallocated via 
kmem_cache_alloc. A function that runs after kmem_cache_alloc() may 
mess up the lock state.

> What I meant: some time ago i had patches to add a __GFP_ZERO queue to the
> page allocator. The page allocator would handle all this for everybody. 
> For various reasons they never got pushed.

Yup that was probably my patchset. The problem was that I could not make 
the case that this was beneficial if all cache lines of a page were 
touched. It was a significant performance benefit only for sparsely 
accessed pages. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
