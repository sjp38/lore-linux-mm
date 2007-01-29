Date: Mon, 29 Jan 2007 19:08:25 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <45BD6A7B.7070501@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Nick Piggin wrote:
> 
> OK, how's this one?

Grudging okay - so irritating to have to do this!

We have different ideas of what's a good cleanup
(pte -> old/new), but if you wish.

I'd much rather you'd got rid of move_pte's prot argument,
that can be taken from the old_vma you're now having to pass
(because of your debug additions to page_remove_rmap).

Grudging okay: thanks for fixing it.

Hugh

> 
> Not tested on MIPS, but the same move_pte compiled on i386 here.
> 
> I sent Ralf a little test program that should eventually free a ZERO_PAGE
> if it is run a few times (with a non-zero zero_page_mask). Do you have
> time to confirm, Ralf?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
