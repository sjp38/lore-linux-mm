Date: Fri, 15 Oct 2004 22:54:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] use find_trylock_page in free_swap_and_cache instead of
    hand coding
In-Reply-To: <20041015183556.GB4937@logos.cnet>
Message-ID: <Pine.LNX.4.44.0410152248460.7849-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Oct 2004, Marcelo Tosatti wrote:
> On Fri, Oct 15, 2004 at 02:20:08PM +0100, Hugh Dickins wrote:
> > But please extend your patch to mm/swap_state.c, where you can get rid
> > of the two radix_tree_lookups by reverting to find_get_page - thanks!
> 
> Here it is. Can you please review an Acked-by?

Looks good, thanks, yes, help yourself to one of these:
Acked-by: Hugh Dickins <hugh@veritas.com>

> That raises a question in my mind: The swapper space statistics
> are not protected by anything.
> 
> Two processors can write to it at the same time - I can imagine
> we lose a increment (two CPUs increasing at the same time), but
> what else can happen to the statistics due to the lack of locking?

That's right.  It just doesn't matter at all: much better to lose
the occasional increment than weigh it down with locking or atomicity.

When was the last time you or anyone took any interest in those
numbers?  From time to time I think of just ripping them  out.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
