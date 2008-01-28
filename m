Received: from [172.20.26.62]([172.20.26.62]) (2179 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1JJMaq-0000DiC@megami.veritas.com>
	for <linux-mm@kvack.org>; Sun, 27 Jan 2008 21:31:40 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 28 Jan 2008 05:31:48 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] change comment in read_swap_cache_async
In-Reply-To: <479D5CDE.6060201@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0801280526240.13717@sister.site>
References: <479D5CDE.6060201@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008, Tomohiro Kusumi wrote:
> 
> The function try_to_swap_out seems to have been removed in 2.5 era.
> So shouldn't the following comment get changed ?

You're right, that's wrong, it should be referring to add_to_swap
instead - thank you.  But by coincidence there's already a patch
in Andrew's -mm tree which corrects that comment: should get into
2.6.25-rc in a couple of weeks.

Hugh

> 
> Tomohiro Kusumi
> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
> 
> diff -Nurp linux-2.6.24.org/mm/swap_state.c linux-2.6.24/mm/swap_state.c
> --- linux-2.6.24.org/mm/swap_state.c	2008-01-28 13:22:41.000000000 +0900
> +++ linux-2.6.24/mm/swap_state.c	2008-01-28 13:26:07.000000000 +0900
> @@ -349,8 +349,8 @@ struct page *read_swap_cache_async(swp_e
>  		 * our caller observed it.  May fail (-EEXIST) if there
>  		 * is already a page associated with this entry in the
>  		 * swap cache: added by a racing read_swap_cache_async,
> -		 * or by try_to_swap_out (or shmem_writepage) re-using
> -		 * the just freed swap entry for an existing page.
> +		 * or by shmem_writepage re-using the just freed swap
> +		 * entry for an existing page.
>  		 * May fail (-ENOMEM) if radix-tree node allocation failed.
>  		 */
>  		err = add_to_swap_cache(new_page, entry);
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
