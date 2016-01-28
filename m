Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 70C036B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:44:41 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id f81so46080014iof.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 23:44:41 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id b9si2749986igx.85.2016.01.27.23.44.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 23:44:40 -0800 (PST)
Date: Thu, 28 Jan 2016 16:44:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
Message-ID: <20160128074442.GB15426@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
 <7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:
> This patch adds KASAN hooks to SLAB allocator.
> 
> This patch is based on the "mm: kasan: unified support for SLUB and
> SLAB allocators" patch originally prepared by Dmitry Chernenkov.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  Documentation/kasan.txt  |  5 ++-

...

> +#ifdef CONFIG_SLAB
> +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> +					const void *object)
> +{
> +	return (void *)object + cache->kasan_info.alloc_meta_offset;
> +}
> +
> +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> +				      const void *object)
> +{
> +	return (void *)object + cache->kasan_info.free_meta_offset;
> +}
> +#endif

I cannot find the place to store stack info for free. get_free_info()
isn't used except print_object(). Plese let me know where.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
