Date: Mon, 29 Jan 2007 11:27:56 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>


On Mon, 29 Jan 2007, Hugh Dickins wrote:

> On Mon, 29 Jan 2007, Nick Piggin wrote:
> > 
> > OK, how's this one?
> 
> Grudging okay - so irritating to have to do this!

I really hate it. Like REALLY REALLY hate it.

This just seems really stupid.

How about making the zero-page on MIPS be PageCompound(), and then have 
all the sub-pages just point to the first page - that's how compound pages 
work anyway.

Then the mapcount/refcount is all done on the compound page, and none of 
these problems occur.

Hmm? 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
