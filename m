Subject: Re: pagefault scalability patches
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.62.0508180916260.25946@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	 <4303EBC2.4030603@yahoo.com.au> <430448F8.3090502@yahoo.com.au>
	 <Pine.LNX.4.62.0508180916260.25946@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 22 Aug 2005 12:04:53 +1000
Message-Id: <1124676293.5159.4.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-08-18 at 09:17 -0700, Christoph Lameter wrote:
> On Thu, 18 Aug 2005, Nick Piggin wrote:
> 
> > Nick Piggin wrote:
> > 
> > > If the big ticket item is taking the ptl out of the anonymous fault
> > > path, then we probably should forget my stuff
> > 
> > ( for now :) )
> 
> I think we can gradually work atomic operations into various code paths 
> where this will be advantageous and your work may be a very important base 
> to get there.

Don't forget however that when doing things like tearing down page
tables, it's a lot more efficient to take 1 lock, then do a bunch of
things non-atomically, then drop that lock.

At least on PPC, the cost of a lock is approx. equivalent to the cost of
an atomic, and is measurable on such things.

That said, I think your approach for the anonymous page case is a good
first step for now. I'll have to adapt ppc64 to it but it shouldn't be
too hard.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
