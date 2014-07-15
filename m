Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 40F9E6B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 00:05:05 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so1079309pad.35
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 21:05:04 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id df3si10714052pbc.99.2014.07.14.21.05.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 21:05:04 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so5201113pab.20
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 21:05:03 -0700 (PDT)
Date: Mon, 14 Jul 2014 21:03:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: remove the unused gfp arg to
 shmem_add_to_page_cache
In-Reply-To: <53C46CBE.60605@gmail.com>
Message-ID: <alpine.LSU.2.11.1407142047390.983@eggly.anvils>
References: <53C46CBE.60605@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org

On Tue, 15 Jul 2014, Wang Sheng-Hui wrote:
> 
> The gfp arg is not used in shmem_add_to_page_cache.
> Remove this unused arg.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Looks right, but checkpatch.pl has some complaints about the spaces:
please fix those.  Maybe you started off with tabs, and gmail turned
them into spaces.  gmail is an outstandingly excellent mailer (;)
but unhelpful on patches.  See Documentation/email-clients.txt or
Documentation/zh_CN/email-clients.txt.  Maybe "git send-email" will
get around it for you.

Thanks,
Hugh

> ---
>  mm/shmem.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1140f49..63cc6af 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -280,7 +280,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
>   */
>  static int shmem_add_to_page_cache(struct page *page,
>                                    struct address_space *mapping,
> -                                  pgoff_t index, gfp_t gfp, void *expected)
> +                                  pgoff_t index, void *expected)
>  {
>         int error;
> 
> @@ -643,7 +643,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
>          */
>         if (!error)
>                 error = shmem_add_to_page_cache(*pagep, mapping, index,
> -                                               GFP_NOWAIT, radswap);
> +                                               radswap);
>         if (error != -ENOMEM) {
>                 /*
>                  * Truncation and eviction use free_swap_and_cache(), which
> @@ -1089,7 +1089,7 @@ repeat:
>                                                 gfp & GFP_RECLAIM_MASK);
>                 if (!error) {
>                         error = shmem_add_to_page_cache(page, mapping, index,
> -                                               gfp, swp_to_radix_entry(swap));
> +                                               swp_to_radix_entry(swap));
>                         /*
>                          * We already confirmed swap under page lock, and make
>                          * no memory allocation here, so usually no possibility
> @@ -1152,7 +1152,7 @@ repeat:
>                 error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
>                 if (!error) {
>                         error = shmem_add_to_page_cache(page, mapping, index,
> -                                                       gfp, NULL);
> +                                                       NULL);
>                         radix_tree_preload_end();
>                 }
>                 if (error) {
> -- 
> 1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
