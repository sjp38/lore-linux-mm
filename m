From: Andi Kleen <ak@suse.de>
Subject: Re: Page allocator: Single Zone optimizations
Date: Mon, 6 Nov 2006 18:20:01 +0100
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <200611061807.16890.ak@suse.de> <Pine.LNX.4.64.0611060912070.25496@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611060912070.25496@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200611061820.01943.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

> No its not. RCU means that there are potential accesses after a object has 
> been freed and even after an object has been reallocated via 
> kmem_cache_alloc. A function that runs after kmem_cache_alloc() may 
> mess up the lock state.

Ok, got it. How messy.

>From my previous slab experiences I predict it will not work anymore in less than
half a year. Such fragile constructions never tend to hold long.

> > What I meant: some time ago i had patches to add a __GFP_ZERO queue to the
> > page allocator. The page allocator would handle all this for everybody. 
> > For various reasons they never got pushed.
> 
> Yup that was probably my patchset. 

That was an own patch by me. But it was pretty obvious so I'm sure
others had the same idea.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
