Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.61.0508091215490.11660@goblin.wat.veritas.com>
References: <42F57FCA.9040805@yahoo.com.au>
	 <200508090710.00637.phillips@arcor.de> <42F7F5AE.6070403@yahoo.com.au>
	 <1123577509.30257.173.camel@gaston>
	 <Pine.LNX.4.61.0508091215490.11660@goblin.wat.veritas.com>
Content-Type: text/plain
Date: Tue, 09 Aug 2005 16:31:42 +0200
Message-Id: <1123597903.30257.204.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Daniel Phillips <phillips@arcor.de>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

> We do what's most efficient for the core.  Which I think is refcount
> both ways regardless, since these "page"s are exceptional, and the
> majority really do need refcounting.

Well, refcounting _might_ be useful for some usage of these, but we
simply must make sure that those pages are never returned back to the
pool when refcount reach 0, that's it.

> But you don't mind if they are refcounted, do you?
> Just so long as they start out from 1 so never get freed.

Well, a refcounting bug would let them be freed and kaboom ... That's
why a "PG_not_your_ram_dammit" bit would be useful. It could at least
BUG_ON when refcount reaches 0 :)

> You'll actually be needing nopage() on them? 

Yes.

> That idea has come up
> before, it's not out of the question (though I think wli suggested
> we ought rather to change the nopage interface if so), but it's a
> different topic from the current removal of PageReserved anyway.

It is a different topic indeed. Wli proposal would be useful for us
here, but in the meantime, We can just create struct pages and rely on
sparsemem to have a not-too-horrible mem_map :)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
