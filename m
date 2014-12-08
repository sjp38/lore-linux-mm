Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id DFDB76B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 09:49:35 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so4628412iec.15
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 06:49:35 -0800 (PST)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id f39si25161802iod.60.2014.12.08.06.49.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 06:49:34 -0800 (PST)
Date: Mon, 8 Dec 2014 08:49:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] memcg: fix possible use-after-free in
 memcg_kmem_get_cache
In-Reply-To: <1417969947-4072-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1412080848240.21299@gentwo.org>
References: <1417969947-4072-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 7 Dec 2014, Vladimir Davydov wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index 95d214255663..7ddf01e2a465 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2450,6 +2450,7 @@ redo:
>
>  	slab_post_alloc_hook(s, gfpflags, object);
>
> +	memcg_kmem_put_cache(s);
>  	return object;
>  }

The function should be added to slab_post_alloc().

Also move the memcg_kmem_get_cache() into slab_pre_alloc_hook().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
