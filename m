Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3926B0010
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:39:01 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v65-v6so11313106qka.23
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:39:01 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id x46-v6si10487872qvf.286.2018.07.30.08.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Jul 2018 08:38:55 -0700 (PDT)
Date: Mon, 30 Jul 2018 15:38:54 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/7] mm, slab: combine kmalloc_caches and
 kmalloc_dma_caches
In-Reply-To: <20180718133620.6205-2-vbabka@suse.cz>
Message-ID: <01000164ebd7a137-093f1337-e0b0-4ea9-81dd-2e37b6adadb9-000000@email.amazonses.com>
References: <20180718133620.6205-1-vbabka@suse.cz> <20180718133620.6205-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Wed, 18 Jul 2018, Vlastimil Babka wrote:

> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -295,12 +295,28 @@ static inline void __check_heap_object(const void *ptr, unsigned long n,
>  #define SLAB_OBJ_MIN_SIZE      (KMALLOC_MIN_SIZE < 16 ? \
>                                 (KMALLOC_MIN_SIZE) : 16)
>
> +#define KMALLOC_NORMAL	0
> +#ifdef CONFIG_ZONE_DMA
> +#define KMALLOC_DMA	1
> +#define KMALLOC_TYPES	2
> +#else
> +#define KMALLOC_TYPES	1
> +#endif

An emum would be better here I think.

But the patch is ok

Acked-by: Christoph Lameter <cl@linux.com>
