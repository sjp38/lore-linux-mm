Date: Mon, 5 Mar 2007 17:01:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070305160143.GB8128@wotan.suse.de>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E8594B.6020904@austin.ibm.com> <20070305032116.GA29678@wotan.suse.de> <45EC352A.7060802@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45EC352A.7060802@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 09:20:10AM -0600, Joel Schopp wrote:
> >But if you don't require a lot of higher order allocations anyway, then
> >guest fragmentation caused by ballooning doesn't seem like much problem.
> 
> If you only need to allocate 1 page size and smaller allocations then no 
> it's not a problem.  As soon as you go above that it will be.  You don't 
> need to go all the way up to MAX_ORDER size to see an impact, it's just 
> increasingly more severe as you get away from 1 page and towards MAX_ORDER.

We allocate order 1 and 2 pages for stuff without too much problem.

> >If you need higher order allocations, then ballooning is bad because of
> >fragmentation, so you need memory unplug, so you need higher order
> >allocations. Goto 1.
> 
> Yes, it's a closed loop.  But hotplug isn't the only one that needs higher 
> order allocations.  In fact it's pretty far down the list.  I look at it 
> like this, a lot of users need high order allocations for better 
> performance and things like on-demand hugepages.  As a bonus you get memory 
> hot-remove.

on-demand hugepages could be done better anyway by having the hypervisor
defrag physical memory and provide some way for the guest to ask for a
hugepage, no?

> >Balooning probably does skew memory management stats and watermarks, but
> >that's just because it is implemented as a module. A couple of hooks
> >should be enough to allow things to be adjusted?
> 
> That is a good idea independent of the current discussion.

Well it shouldn't be too difficult. If you cc linux-mm and/or me with
any thoughts or requirements then I could try to help with it.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
