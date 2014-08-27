Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BBC976B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:37:36 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so38118pac.11
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:37:36 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTPS id o1si3192356pdi.96.2014.08.27.16.37.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 16:37:35 -0700 (PDT)
Date: Wed, 27 Aug 2014 18:37:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slab: use percpu allocator for cpu cache
In-Reply-To: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408271827010.26560@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

One minor nit. Otherwise

Acked-by: Christoph Lameter <cl@linux.com>

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> @@ -2041,56 +1982,63 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
>  	return left_over;
>  }
>
> +static int alloc_kmem_cache_cpus(struct kmem_cache *cachep, int entries,
> +				int batchcount)
> +{
> +	cachep->cpu_cache = __alloc_kmem_cache_cpus(cachep, entries,
> +							batchcount);
> +	if (!cachep->cpu_cache)
> +		return 1;
> +
> +	return 0;
> +}

Do we really need this trivial function? It doesnt do anything useful as
far as I can tell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
