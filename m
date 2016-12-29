Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 745466B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:44:59 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so566886870pfk.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 22:44:59 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 63si52518003plf.32.2016.12.28.22.44.57
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 22:44:58 -0800 (PST)
Date: Thu, 29 Dec 2016 15:44:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: fix typo of cache_alloc_zspage()
Message-ID: <20161229064457.GD1815@bbox>
References: <58646FB7.2040502@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58646FB7.2040502@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 29, 2016 at 10:06:47AM +0800, Xishi Qiu wrote:
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/zsmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 9cc3c0b..2d6c92e 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -364,7 +364,7 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
>  {
>  	return kmem_cache_alloc(pool->zspage_cachep,
>  			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
> -};
> +}

Although it's trivial, we need descritpion.
Please, could you resend to Andrew Morton with filling description?

Andrew Morton <akpm@linux-foundation.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
