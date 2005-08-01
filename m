Date: Mon, 1 Aug 2005 20:29:40 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
Message-ID: <Pine.LNX.4.61.0508012024330.5373@goblin.wat.veritas.com>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Aug 2005, Linus Torvalds wrote:
> 
> that "continue" will continue without the spinlock held, and now do 

Yes, I was at last about to reply on that point and others.
I'll make those comments in a separate mail to Nick and all.

> Instead, I'd suggest changing the logic for "lookup_write". Make it 
> require that the page table entry is _dirty_ (not writable), and then 

Attractive, I very much wanted to do that rather than change all the
arches, but I think s390 rules it out: its pte_mkdirty does nothing,
its pte_dirty just says no.

Whether your patch suits all other uses of (__)follow_page I've not
investigated (and I don't see how you can go without the set_page_dirty
if it was necessary before); but at present see no alternative to
something like Nick's patch, though I'd much prefer smaller.

Or should we change s390 to set a flag in the pte just for this purpose?

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
