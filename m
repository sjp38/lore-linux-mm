Date: Fri, 15 Oct 2004 14:20:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] use find_trylock_page in free_swap_and_cache instead of
    hand    coding
In-Reply-To: <20041015104502.GA1989@logos.cnet>
Message-ID: <Pine.LNX.4.44.0410151411330.5770-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Oct 2004, Marcelo Tosatti wrote:
> 
> This small cleanup to free_swap_and_cache() substitues a 
> "lock - radix lookup - TestSetPageLocked - unlock" sequence
> of instructions with "find_trylock_page()" (which does 
> exactly that).

You're right: I must have been so excited by distinguishing the swapcache
from the pagecache, that I was blind to how that was still applicable
(unlike inserting and removing).

But please extend your patch to mm/swap_state.c, where you can get rid
of the two radix_tree_lookups by reverting to find_get_page - thanks!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
