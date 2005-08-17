Date: Wed, 17 Aug 2005 16:01:02 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: pagefault scalability patches
In-Reply-To: <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 17 Aug 2005, Christoph Lameter wrote:
>
> We are trading 2x (spinlock(page_table_lock), 
> spin_unlock(page_table_lock)) against one atomic inc.

Bzzt. Thank you for playing.

Spinunlock is free on x86 and x86-64, since it's a plain normal store. The 
x86 memory ordering semantics take care of the rest.

In other words, one uncontended spinlock/unlock pair is pretty much
_exactly_ the same cost as one single atomic operation, and there is no 
win.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
