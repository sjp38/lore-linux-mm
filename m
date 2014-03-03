Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id C62146B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 09:39:55 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id i7so5507473oag.19
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 06:39:55 -0800 (PST)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id tk7si23534421obc.3.2014.03.03.06.39.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 06:39:54 -0800 (PST)
Received: by mail-ob0-f174.google.com with SMTP id wo20so4536483obc.5
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 06:39:54 -0800 (PST)
Date: Mon, 3 Mar 2014 08:39:48 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm: zswap: remove unnecessary parentheses
Message-ID: <20140303143948.GA3362@cerebellum.variantweb.net>
References: <1393839476-24989-1-git-send-email-sj38.park@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393839476-24989-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 03, 2014 at 06:37:56PM +0900, SeongJae Park wrote:
> Fix following trivial checkpatch error:
> 	ERROR: return is not a function, parentheses are not required
> 
> Signed-off-by: SeongJae Park <sj38.park@gmail.com>

Thanks for the cleanup.
Might copy trivial@kernel.org on patches like this in the future.

Acked-by: Seth Jennings <sjennings@variantweb.net>

> ---
>  mm/zswap.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index c0c9b7c..34b75cc 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -204,7 +204,7 @@ static struct kmem_cache *zswap_entry_cache;
>  static int zswap_entry_cache_create(void)
>  {
>  	zswap_entry_cache = KMEM_CACHE(zswap_entry, 0);
> -	return (zswap_entry_cache == NULL);
> +	return zswap_entry_cache == NULL;
>  }
>  
>  static void zswap_entry_cache_destory(void)
> @@ -408,8 +408,8 @@ cleanup:
>  **********************************/
>  static bool zswap_is_full(void)
>  {
> -	return (totalram_pages * zswap_max_pool_percent / 100 <
> -		zswap_pool_pages);
> +	return totalram_pages * zswap_max_pool_percent / 100 <
> +		zswap_pool_pages;
>  }
>  
>  /*********************************
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
