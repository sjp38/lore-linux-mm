Date: Tue, 9 Aug 2005 15:47:49 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
In-Reply-To: <1123597704.30257.200.camel@gaston>
Message-ID: <Pine.LNX.4.61.0508091542030.13674@goblin.wat.veritas.com>
References: <42F57FCA.9040805@yahoo.com.au>  <200508090710.00637.phillips@arcor.de>
  <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au>
 <20050809080853.A25492@flint.arm.linux.org.uk>
 <Pine.LNX.4.61.0508091012480.10693@goblin.wat.veritas.com>
 <42F88514.9080104@yahoo.com.au>  <Pine.LNX.4.61.0508091145570.11660@goblin.wat.veritas.com>
 <1123597704.30257.200.camel@gaston>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Russell King <rmk+lkml@arm.linux.org.uk>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Aug 2005, Benjamin Herrenschmidt wrote:
> 
> > ioremap is making a similar check to the one remap_pfn_range used
> > to make; but I see no good reason for it at all.  ioremap should be
> > allowed to map whatever the caller asked, just as memset is allowed
> > to set whatever the caller asked.
> 
> This is dodgy actually. memset can't be guaranteed to work on IOs or
> other non-cacheable memory (including real RAM that has been mapped
> non-cacheable, typically RAM that has been "set aside" for other uses as
> described above, wether it's for AGP, or for some weird processor DMA
> bounce buffers or whatever ..., that is RAM that is out of the normal
> kernel control).

That was my point: memset goes ahead without making funny little checks,
and works or not, so I don't see why ioremap needs to make these funny
little checks.  If the driver doesn't know what it's doing (not impossible,
I accept), what's the likelihood that PageReserved or not will save it?

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
