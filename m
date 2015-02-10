Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id E33EB6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 17:43:44 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id z107so15396775qgd.5
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 14:43:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z20si5223158qge.38.2015.02.10.14.43.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 14:43:44 -0800 (PST)
Date: Wed, 11 Feb 2015 11:43:33 +1300
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
Message-ID: <20150211114333.78de64d3@redhat.com>
In-Reply-To: <20150210194811.787556326@linux.com>
References: <20150210194804.288708936@linux.com>
	<20150210194811.787556326@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, brouer@redhat.com



On Tue, 10 Feb 2015 13:48:05 -0600 Christoph Lameter <cl@linux.com> wrote:
[...]
> Index: linux/mm/slab_common.c
> ===================================================================
> --- linux.orig/mm/slab_common.c
> +++ linux/mm/slab_common.c
> @@ -105,6 +105,83 @@ static inline int kmem_cache_sanity_chec
>  }
>  #endif
>  
> +/*
> + * Fallback function that just calls kmem_cache_alloc
> + * for each element. This may be used if not all
> + * objects can be allocated or as a generic fallback
> + * if the allocator cannot support buik operations.
                                      ^^^^
Minor typo "buik" -> "bulk"

> + */
> +int __kmem_cache_alloc_array(struct kmem_cache *s,
> +		gfp_t flags, size_t nr, void **p)
> +{
[...]

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
