Date: Tue, 2 Oct 2007 17:21:53 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: new aops merge [was Re: -mm merge plans for 2.6.24]
In-Reply-To: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710021706280.4916@blonde.wat.veritas.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Oct 2007, Andrew Morton wrote:
> fs-introduce-write_begin-write_end-and-perform_write-aops.patch
> introduce-write_begin-write_end-aops-important-fix.patch
> introduce-write_begin-write_end-aops-fix2.patch
> deny-partial-write-for-loop-dev-fd.patch
> mm-restore-kernel_ds-optimisations.patch
> implement-simple-fs-aops.patch
> implement-simple-fs-aops-fix.patch
> ...
> fs-remove-some-aop_truncated_page.patch
> 
>   Merge

Good, fine by me; but forces me to confess, with abject shame,
that I still haven't sent you some shmem/tmpfs fixes/cleanups
(currently intermingled with some other stuff in my tree, I'm
still disentangling).  Nothing so bad as to mess up a bisection,
but my loop-over-tmpfs tests hang without passing gfp_mask down
and down to add_to_swap_cache; and a few other bits.  I'll get
back on to it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
