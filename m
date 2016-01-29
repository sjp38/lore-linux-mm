Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 67F216B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:50:44 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id uo6so43287463pac.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:50:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id n16si24687372pfj.185.2016.01.29.06.50.43
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 06:50:43 -0800 (PST)
Date: Fri, 29 Jan 2016 09:50:40 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 4/5] mm: Use radix_tree_iter_retry()
Message-ID: <20160129145040.GW2948@linux.intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453929472-25566-5-git-send-email-matthew.r.wilcox@intel.com>
 <56AB7B27.3090805@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56AB7B27.3090805@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 29, 2016 at 03:45:59PM +0100, Vlastimil Babka wrote:
> This should be applied on top. There are no restarts anymore.

Quite right.  Sorry I missed the comment.

Acked-by: Matthwe Wilcox <willy@linux.intel.com>

> ----8<----
> >From 3b0bdd370b57fb6d83b213e140cd1fb0e8962af8 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 29 Jan 2016 15:41:31 +0100
> Subject: [PATCH] mm: Use radix_tree_iter_retry()-fix
> 
> Remove now-obsolete-and-misleading comment.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/shmem.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 8f89abd4eaee..4d758938340c 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -382,11 +382,6 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>  
>  		page = radix_tree_deref_slot(slot);
>  
> -		/*
> -		 * This should only be possible to happen at index 0, so we
> -		 * don't need to reset the counter, nor do we risk infinite
> -		 * restarts.
> -		 */
>  		if (radix_tree_deref_retry(page)) {
>  			slot = radix_tree_iter_retry(&iter);
>  			continue;
> -- 
> 2.7.0
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
