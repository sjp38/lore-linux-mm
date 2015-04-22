Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7564D900015
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 03:02:49 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so264804679pab.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 00:02:49 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id bz4si6341142pab.196.2015.04.22.00.02.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 00:02:48 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NN700HU3524DR00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Apr 2015 08:06:04 +0100 (BST)
Message-id: <55374791.6020300@samsung.com>
Date: Wed, 22 Apr 2015 10:02:41 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] kasan: Remove duplicate definition of the macro
 KASAN_FREE_PAGE
References: <1429683812-2416-1-git-send-email-long.wanglong@huawei.com>
In-reply-to: <1429683812-2416-1-git-send-email-long.wanglong@huawei.com>
Content-type: text/plain; charset=windows-1251
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <long.wanglong@huawei.com>, adech.fo@gmail.com, mmarek@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, peifeiyue@huawei.com

On 04/22/2015 09:23 AM, Wang Long wrote:
> This patch just remove duplicate definition of the macro
> KASAN_FREE_PAGE in mm/kasan/kasan.h
> 
> Signed-off-by: Wang Long <long.wanglong@huawei.com>

Acked-by: Andrey Ryabinin <a.ryabinin@samsung.com>

> ---
>  mm/kasan/kasan.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 4986b0a..c242adf 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -7,7 +7,6 @@
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>  
>  #define KASAN_FREE_PAGE         0xFF  /* page was freed */
> -#define KASAN_FREE_PAGE         0xFF  /* page was freed */
>  #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
>  #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
>  #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
