Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62E9A6B005C
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 06:07:33 -0400 (EDT)
Date: Tue, 29 Sep 2009 11:29:21 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] rmap : fix the comment
In-Reply-To: <1254191106-20903-1-git-send-email-shijie8@gmail.com>
Message-ID: <Pine.LNX.4.64.0909291128420.19216@sister.anvils>
References: <1254191106-20903-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009, Huang Shijie wrote:

> The page_address_in_vma() is not only used in unuse_vma().
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  mm/rmap.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 28aafe2..dd43373 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -242,8 +242,8 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>  }
>  
>  /*
> - * At what user virtual address is page expected in vma? checking that the
> - * page matches the vma: currently only used on anon pages, by unuse_vma;
> + * At what user virtual address is page expected in vma?
> + * checking that the page matches the vma.
>   */
>  unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
>  {
> -- 
> 1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
