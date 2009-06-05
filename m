Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4E9BD6B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:20:04 -0400 (EDT)
Date: Fri, 5 Jun 2009 19:03:52 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH][mmtom] remove annotation of gfp_mask in add_to_swap
In-Reply-To: <1244212237-14128-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <Pine.LNX.4.64.0906051858160.14826@sister.anvils>
References: <1244212237-14128-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009, Minchan Kim wrote:

> Hugh removed add_to_swap's gfp_mask argument.
> (mm: remove gfp_mask from add_to_swap)
> So we have to remove annotation of gfp_mask  of the function.

"annotation"?  Or "DocBook comment"?  Or "DocBook annotation"?

> 
> This patch cleans up add_to_swap function.
> It doesn't affect behavior of function.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Thanks, yes, my oversight.

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  mm/swap_state.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index b9ca029..b62e7f5 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -124,7 +124,6 @@ void __delete_from_swap_cache(struct page *page)
>  /**
>   * add_to_swap - allocate swap space for a page
>   * @page: page we want to move to swap
> - * @gfp_mask: memory allocation flags
>   *
>   * Allocate swap space for the page and add the page to the
>   * swap cache.  Caller needs to hold the page lock. 
> -- 
> 1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
