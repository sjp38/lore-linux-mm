Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD7FC6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:52:40 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so108616418pfx.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:52:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z30si909330plh.61.2017.02.06.06.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:52:39 -0800 (PST)
Date: Mon, 6 Feb 2017 06:52:38 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
Message-ID: <20170206145238.GI2267@bombadil.infradead.org>
References: <20170203181008.24898-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203181008.24898-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Fri, Feb 03, 2017 at 07:10:08PM +0100, Vlastimil Babka wrote:
> diff --git a/mm/slab.c b/mm/slab.c
> index a95fd4fed0a8..ede31b59bb9f 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1293,7 +1293,8 @@ void __init kmem_cache_init(void)
>  	 * Initialize the caches that provide memory for the  kmem_cache_node
>  	 * structures first.  Without this, further allocations will bug.
>  	 */
> -	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
> +	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
> +				get_kmalloc_cache_name(INDEX_NODE),

Could we lose the 'get_' from the front?  I think 'kmalloc_cache_name()' is
just as informative.

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
