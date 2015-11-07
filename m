Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 58D4282F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 15:55:21 -0500 (EST)
Received: by igvg19 with SMTP id g19so5412697igv.1
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 12:55:21 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id u87si6454585iou.1.2015.11.07.12.55.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 07 Nov 2015 12:55:20 -0800 (PST)
Date: Sat, 7 Nov 2015 14:55:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V2 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
In-Reply-To: <20151107202548.GO29259@esperanza>
Message-ID: <alpine.DEB.2.20.1511071453460.9141@east.gentwo.org>
References: <20151105153704.1115.10475.stgit@firesoul> <20151105153756.1115.41409.stgit@firesoul> <20151105162514.GI29259@esperanza> <20151107175338.12a0368b@redhat.com> <20151107202548.GO29259@esperanza>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 7 Nov 2015, Vladimir Davydov wrote:

> Hmm, I thought that a bunch of objects allocated using
> kmem_cache_alloc_bulk must be freed using kmem_cache_free_bulk. If it
> does not hold, i.e. if one can allocate an array of objects one by one
> using kmem_cache_alloc and then batch-free them using
> kmem_cache_free_bulk, then my proposal is irrelevant.

Nope they can be allocated and freed in multiple ways.

> > With my limited mem cgroups, it looks like memcg works on the slab-page
> > level?
>
> Yes, a memcg has its private copy of each global kmem cache it attempted
> to use, which implies that all objects on the same slab-page must belong
> to the same memcg.

Every memcg duplicates all slab caches and thus these are separate caches.
Bulk freeing to a mixture of cgroups caches does not work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
