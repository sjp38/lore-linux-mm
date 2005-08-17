Date: Wed, 17 Aug 2005 15:51:48 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Linus Torvalds wrote:

> HOWEVER, the fact that it makes the mm counters be atomic just makes it
> pointless. It may help scalability, but it loses the attribute that I
> considered a big win above - it no longer helps the non-contended case (at
> least on x86, a uncontended spinlock is about as expensive as a atomic
> op).

We are trading 2x (spinlock(page_table_lock), 
spin_unlock(page_table_lock)) against one atomic inc.

> 
> I thought Christoph (Nick?) had a patch to make the counters be
> per-thread, and then just folded back into the mm-struct every once in a
> while?

Yes I do but I did want want to risk that can of worms becoming entwined 
with the page fault scalability patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
