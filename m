Date: Mon, 29 Jan 2007 12:22:00 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0701291219040.3611@woody.linux-foundation.org>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
 <Pine.LNX.4.64.0701292002310.16279@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>


On Mon, 29 Jan 2007, Hugh Dickins wrote:
> 
> But it won't quite work as is, since only page_count() is diverted
> via PageCompound(): page_mapcount() works on exactly the page given.
> So the MIPS ZERO_PAGEs could still hit the page_remove_rmap() BUG.

Ok.

> Agreed that's a surprising divergence: but it's worked fine to date,
> and I'm hesitant to change it in a hurry, need to pause to consider
> the ramifications.

How about:
 - the current code has worked so far, so there is no way in hell I'll 
   take a patch for some odd-ball architecture for a theoretical problem 
   that nobody else cares about for 2.6.20 *anyway* and hasn't been 
   reported until now (considering that it's apparently been around since 
   rmap went in).

 - somebody who cares would explore trying to make page_mapcount work like 
   page_count, and see if this is a viable approach.

 - at worst, we can do the Andrew thing, and just forget about the 
   ZERO_PAGE() multi-page thing. It may well be that even MIPS people 
   don't care any more, if the particular uarch version that was helped 
   most isn't very common any more (we can always hope..)

Hmm?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
