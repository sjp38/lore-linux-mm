Subject: Re: pagefault scalability patches
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	 <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
	 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 22 Aug 2005 12:13:43 +1000
Message-Id: <1124676823.5159.12.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-08-17 at 15:51 -0700, Christoph Lameter wrote:
> On Wed, 17 Aug 2005, Linus Torvalds wrote:
> 
> > HOWEVER, the fact that it makes the mm counters be atomic just makes it
> > pointless. It may help scalability, but it loses the attribute that I
> > considered a big win above - it no longer helps the non-contended case (at
> > least on x86, a uncontended spinlock is about as expensive as a atomic
> > op).
> 
> We are trading 2x (spinlock(page_table_lock), 
> spin_unlock(page_table_lock)) against one atomic inc.

At least on ppc, unlock isn't atomic

> > I thought Christoph (Nick?) had a patch to make the counters be
> > per-thread, and then just folded back into the mm-struct every once in a
> > while?
> 
> Yes I do but I did want want to risk that can of worms becoming entwined 
> with the page fault scalability patches.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
