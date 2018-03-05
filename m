Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84FF76B0009
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:00:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q13so7657218pgt.17
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:00:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u12-v6sor4431144plm.10.2018.03.05.11.00.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 11:00:12 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <6a31164a-af3f-91ea-d385-7c6d1888b28c@gmail.com>
Date: Mon, 5 Mar 2018 11:00:08 -0800
MIME-Version: 1.0
In-Reply-To: <20180228200620.30026-2-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

.
.


On 2/28/18 12:06 PM, Igor Stoppa wrote:
> +
> +/**
> + * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
> + * @pool: pool to allocate from
> + * @size: number of bytes to allocate from the pool
> + * @dma: dma-view physical address return value.  Use NULL if unneeded.
> + *
> + * Allocate the requested number of bytes from the specified pool.
> + * Uses the pool allocation function (with first-fit algorithm by default).
> + * Can not be used in NMI handler on architectures without
> + * NMI-safe cmpxchg implementation.
> + *
> + * Return:
> + * * address of the memory allocated	- success
> + * * NULL				- error
> + */
> +void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma);
> +

OK, so gen_pool_dma_alloc() is defined here, which believe is the API 
line being drawn for this series.

so,
.
.
.
>
>   
>   /**
> - * gen_pool_dma_alloc - allocate special memory from the pool for DMA usage
> + * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
>    * @pool: pool to allocate from
>    * @size: number of bytes to allocate from the pool
>    * @dma: dma-view physical address return value.  Use NULL if unneeded.
> @@ -342,14 +566,15 @@ EXPORT_SYMBOL(gen_pool_alloc_algo);
>    * Uses the pool allocation function (with first-fit algorithm by default).
>    * Can not be used in NMI handler on architectures without
>    * NMI-safe cmpxchg implementation.
> + *
> + * Return:
> + * * address of the memory allocated	- success
> + * * NULL				- error
>    */
>   void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>   {
>   	unsigned long vaddr;
>   
> -	if (!pool)
> -		return NULL;
> -
why is this being removed?A  I don't believe this code was getting 
removed from your v17 series patches.
>   	vaddr = gen_pool_alloc(pool, size);
>   	if (!vaddr)
>   		return NULL;
> @@ -362,10 +587,10 @@ void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
>   EXPORT_SYMBOL(gen_pool_dma_alloc);
>   
>
Otherwise, looks good,

Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
