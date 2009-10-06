Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2C8B16B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 17:08:43 -0400 (EDT)
Date: Tue, 6 Oct 2009 22:08:29 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] rmap : fix the comment for try_to_unmap_anon
In-Reply-To: <1254672050-3293-1-git-send-email-shijie8@gmail.com>
Message-ID: <Pine.LNX.4.64.0910062207450.18136@sister.anvils>
References: <1254672050-3293-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Huang Shijie wrote:

> fix the comment for the try_to_unmap_anon with the new arguments.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Thanks,
Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  mm/rmap.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index dd43373..c8cf043 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -997,8 +997,7 @@ static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
>   * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
>   * rmap method
>   * @page: the page to unmap/unlock
> - * @unlock:  request for unlock rather than unmap [unlikely]
> - * @migration:  unmapping for migration - ignored if @unlock
> + * @flags: action and flags
>   *
>   * Find all the mappings of a page using the mapping pointer and the vma chains
>   * contained in the anon_vma struct it points to.
> -- 
> 1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
