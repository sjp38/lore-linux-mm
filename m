Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8B1B56B00B0
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 07:11:24 -0400 (EDT)
Date: Fri, 25 Sep 2009 12:11:00 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swap : remove unused field of swapper_space
In-Reply-To: <1253869953-4747-1-git-send-email-shijie8@gmail.com>
Message-ID: <Pine.LNX.4.64.0909251207440.7106@sister.anvils>
References: <1253869953-4747-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009, Huang Shijie wrote:

> There is no place to use the i_mmap_nonlinear of swapper_space, so
> remove it.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

I say NAK, unless you're very sure:
see commit comment below when I added that line.

Hugh

> ---
>  mm/swap_state.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 6d1daeb..be16a6b 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -43,7 +43,6 @@ struct address_space swapper_space = {
>  	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
>  	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
>  	.a_ops		= &swap_aops,
> -	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
>  	.backing_dev_info = &swap_backing_dev_info,
>  };
>  

commit e11f2cc49856eabafed09cf30e190646f78b7207
Author: Hugh Dickins <hugh@veritas.com>
Date:   Fri Jun 4 20:51:55 2004 -0700

    [PATCH] mm: swapper_space.i_mmap_nonlinear
    
    Initialize swapper_space.i_mmap_nonlinear, so mapping_mapped reports false on
    it (as it used to do).  Update comment on swapper_space, now more fields are
    used than those initialized explicitly.
    
    Signed-off-by: Hugh Dickins <hugh@veritas.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
