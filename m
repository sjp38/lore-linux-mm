Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CC7D16B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 20:31:06 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so36128291pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 17:31:06 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ck5si8756255pbb.91.2015.10.13.17.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 17:31:05 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so35976530pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 17:31:05 -0700 (PDT)
Date: Wed, 14 Oct 2015 09:31:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: remove useless line in obj_free
Message-ID: <20151014003156.GA1505@swordfish>
References: <20151013080044.GA587@swordfish>
 <1444727220-13030-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444727220-13030-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky@gmail.com, teawater@gmail.com

On (10/13/15 17:07), Hui Zhu wrote:
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Please Cc Andrew Morton to mm/ patches.

	-ss

> ---
>  mm/zsmalloc.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index f135b1b..c7338f0 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1428,8 +1428,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
>  	struct page *first_page, *f_page;
>  	unsigned long f_objidx, f_offset;
>  	void *vaddr;
> -	int class_idx;
> -	enum fullness_group fullness;
>  
>  	BUG_ON(!obj);
>  
> @@ -1437,7 +1435,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
>  	obj_to_location(obj, &f_page, &f_objidx);
>  	first_page = get_first_page(f_page);
>  
> -	get_zspage_mapping(first_page, &class_idx, &fullness);
>  	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
>  
>  	vaddr = kmap_atomic(f_page);
> -- 
> 1.9.1
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
