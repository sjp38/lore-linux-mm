Message-ID: <42F8AC87.5060403@yahoo.com.au>
Date: Tue, 09 Aug 2005 23:15:51 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de> <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au> <20050809080853.A25492@flint.arm.linux.org.uk> <Pine.LNX.4.61.0508091012480.10693@goblin.wat.veritas.com> <42F88514.9080104@yahoo.com.au> <Pine.LNX.4.61.0508091145570.11660@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508091145570.11660@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 9 Aug 2005, Nick Piggin wrote:

>>But in either case: I agree that it is probably not a great loss
>>to remove the check, although considering it will be needed for
>>swsusp anyway...
> 
> 
> swsusp (and I think crashdump has a similar need) is a very different
> case: it's approaching memory from the zone/mem_map end, with no(?) idea
> of how the different pages are used: needs to save all the info while
> avoiding those areas which would give trouble.  I can well imagine it
> needs either a page flag or a table lookup to decide that.
> 

Yep.

> But ioremap and remap_pfn_range are coming from drivers which (we hope)
> know what they're mapping these particular areas for.  If it's provable
> that the meaning which swsusp needs is equally usable for a little sanity
> check in ioremap, okay, but I'm sceptical.
> 

I understand what you mean, and I agree. Though as far away from the
business end of the drivers I am, I tend to get the feeling that
drivers need the most hand holding.

Anyway, I guess the way to understand the problem is finding the
reason why ioremap checks PageReserved, and whether or not ioremap
should be expected (or allowed) to remap physical RAM in use by
the kernel.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
