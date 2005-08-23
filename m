Message-ID: <430A6D08.1080707@yahoo.com.au>
Date: Tue, 23 Aug 2005 10:25:44 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Then add Hugh's pagefault scalability alternative on top.
> 

I like this. It is very like what I did, and having the 'fallback'
case still take the "narrowed" lock eliminates some of the complexity
I had. So it should be fairly easy to add the per-pte locks on top
of this.

I had preempt_disable() in tlb_gather_mmu which I thought was nice,
but maybe you don't?

> +
> +#ifdef CONFIG_SPLIT_PTLOCK
> +#define __pte_lockptr(page)	((spinlock_t *)&((page)->private))
> +#define pte_lock_init(page)	spin_lock_init(__pte_lockptr(page))
> +#define pte_lock_deinit(page)	((page)->mapping = NULL)

Do you mean page->private?

But I haven't given it a really good look yet.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
