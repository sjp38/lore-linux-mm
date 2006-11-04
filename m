Date: Fri, 3 Nov 2006 16:37:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <200611032319.53888.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0611031632550.17238@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061103135013.6bdc6240.akpm@osdl.org> <Pine.LNX.4.64.0611031352420.16486@schroedinger.engr.sgi.com>
 <200611032319.53888.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006, Andi Kleen wrote:

> 
> > This has to do with the constructors and the destructors. They are only 
> > applied during the first allocation or the final deallocation of the slab. 
> 
> It's pretty much obsolete though - nearly nobody uses constructors/destructors.
> And the few uses left over are useless to avoid cache misses 
> and could as well be removed.
> 
> Long ago i fixed some code to use constructors and made sure it carefully
> avoided some cache misses in the hot path, but typically when people change
> anything later they destroy that. It's just not maintainable.
> 
> I would vote for just getting rid of slab constructors/destructors.

I would appreciate patches to that effect, voting will not help much. It 
would make my new slab project much easier. But I doubt that this is as 
easy as you think. F.e. I wonder how you going to do anonvma RCU without 
constructors. I think constructors/destructors are here to stay.

One thing I would appreciate very much and its in your area. Deal 
with the use of slab for page size allocations (pmd, pgd etc) in i386 arch 
code. The page struct in use there is overloaded both by slab and by the 
i386 arch code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
