Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 74FE06B0080
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 10:52:21 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so4697676qge.12
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 07:52:21 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id c1si13393990qag.106.2014.06.06.07.52.20
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 07:52:20 -0700 (PDT)
Date: Fri, 6 Jun 2014 09:52:17 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
In-Reply-To: <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1406060949430.32229@gentwo.org>
References: <cover.1402060096.git.vdavydov@parallels.com> <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Jun 2014, Vladimir Davydov wrote:

> @@ -740,7 +740,8 @@ static void start_cpu_timer(int cpu)
>  	}
>  }
>
> -static struct array_cache *alloc_arraycache(int node, int entries,
> +static struct array_cache *alloc_arraycache(struct kmem_cache *cachep,
> +					    int node, int entries,
>  					    int batchcount, gfp_t gfp)
>  {
>  	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);

If you pass struct kmem_cache * into alloc_arraycache then we do not need
to pass entries or batchcount because they are available in struct
kmem_cache.

Otherwise this patch looks a bit too large to me. Simplify a bit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
