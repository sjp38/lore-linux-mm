Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 867866B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 21:47:14 -0400 (EDT)
Date: Mon, 29 Oct 2012 10:52:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/5] mm, highmem: remove useless pool_lock
Message-ID: <20121029015259.GG15767@bbox>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
 <1351451576-2611-3-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351451576-2611-3-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 29, 2012 at 04:12:53AM +0900, Joonsoo Kim wrote:
> The pool_lock protects the page_address_pool from concurrent access.
> But, access to the page_address_pool is already protected by kmap_lock.
> So remove it.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kin <minchan@kernel.org>

Looks good to me.
Just a nitpick.

Please write comment about locking rule like below.

> 
> diff --git a/mm/highmem.c b/mm/highmem.c
> index b3b3d68..017bad1 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -328,7 +328,6 @@ struct page_address_map {
>   * page_address_map freelist, allocated from page_address_maps.
>   */

/* page_address_pool is protected by kmap_lock */

>  static struct list_head page_address_pool;	/* freelist */
> -static spinlock_t pool_lock;			/* protects page_address_pool */
>  

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
