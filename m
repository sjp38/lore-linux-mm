Date: Sat, 6 Oct 2007 22:26:45 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 2/7] swapin_readahead: move and rearrange args
Message-ID: <20071006222645.18899e83@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710062138580.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062138580.16223@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Oct 2007 21:39:44 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> swapin_readahead has never sat well in mm/memory.c: move it to
> mm/swap_state.c beside its kindred read_swap_cache_async.  Why
> were its args in a different order? rearrange them.  And since
> it was always followed by a read_swap_cache_async of the target
> page, fold that in and return struct page*.  Then CONFIG_SWAP=n
> no longer needs valid_swaphandles and read_swap_cache_async stubs.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
