Date: Mon, 6 Nov 2006 17:12:47 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <200611061807.16890.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0611061711500.10892@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <200611061756.00623.ak@suse.de> <Pine.LNX.4.64.0611060856590.25351@schroedinger.engr.sgi.com>
 <200611061807.16890.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Nov 2006, Andi Kleen wrote:
> On Monday 06 November 2006 18:00, Christoph Lameter wrote:
> > On Mon, 6 Nov 2006, Andi Kleen wrote:
> > 
> > > > Because acceses to the structure can occur after kfree. The RCU 
> > > > implementation only delays the destruction of the slab. Locks are always 
> > > > in a definite state regardless if the object is in use or not.
> > > 
> > > Only objects that have been used at least once can be still visible. And 
> > > those would be still constructed of course -- just after the kmem_cache_alloc,
> > > not inside. For those that have never been used it shouldn't matter.
> > 
> > Constructors are only called on allocation of the slab, not on 
> > kmem_cache_alloc. 
> 
> I know this.
> 
> > And you are right: It does not matter for those that  
> > have never been used.
> 
> This means it is fine to replace the constructor with an function
> that runs after kmem_cache_alloc() in this case.

But where will you do the spin_lock_init?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
