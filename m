Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B67AA6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 00:19:42 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fy10so4746038pac.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 21:19:42 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id u69si56081286pfa.253.2016.02.16.21.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 21:19:42 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id x65so4802896pfb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 21:19:41 -0800 (PST)
Date: Wed, 17 Feb 2016 14:20:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: drop unused member 'mapping_area->huge'
Message-ID: <20160217052058.GA620@swordfish>
References: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YiPing Xu <xuyiping@huawei.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, suzhuangluan@hisilicon.com, puck.chen@hisilicon.com, dan.zhao@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>

On (02/17/16 09:56), YiPing Xu wrote:
> When unmapping a huge class page in zs_unmap_object, the page will
> be unmapped by kmap_atomic. the "!area->huge" branch in
> __zs_unmap_object is alway true, and no code set "area->huge" now,
> so we can drop it.
> 

the patch looks good to me, thanks.
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> Signed-off-by: YiPing Xu <xuyiping@huawei.com>
> ---
>  mm/zsmalloc.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 2d7c4c1..43e4cbc 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -281,7 +281,6 @@ struct mapping_area {
>  #endif
>  	char *vm_addr; /* address of kmap_atomic()'ed pages */
>  	enum zs_mapmode vm_mm; /* mapping mode */
> -	bool huge;
>  };
>  
>  static int create_handle_cache(struct zs_pool *pool)
> @@ -1127,11 +1126,9 @@ static void __zs_unmap_object(struct mapping_area *area,
>  		goto out;
>  
>  	buf = area->vm_buf;
> -	if (!area->huge) {
> -		buf = buf + ZS_HANDLE_SIZE;
> -		size -= ZS_HANDLE_SIZE;
> -		off += ZS_HANDLE_SIZE;
> -	}
> +	buf = buf + ZS_HANDLE_SIZE;
> +	size -= ZS_HANDLE_SIZE;
> +	off += ZS_HANDLE_SIZE;
>  
>  	sizes[0] = PAGE_SIZE - off;
>  	sizes[1] = size - sizes[0];
> -- 
> 1.8.3.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
