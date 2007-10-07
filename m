Date: Sun, 7 Oct 2007 19:23:03 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 3/7] swapin needs gfp_mask for loop on tmpfs
Message-ID: <20071007192303.0b9a1432@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710062139490.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062139490.16223@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Miklos Szeredi <miklos@szeredi.hu>, Fengguang Wu <wfg@mail.ustc.edu.cn>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Oct 2007 21:43:36 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> So, pass gfp_mask down the line from shmem_getpage to shmem_swapin
> to swapin_readahead to read_swap_cache_async to add_to_swap_cache.
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
