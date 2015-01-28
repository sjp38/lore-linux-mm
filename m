Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id E83436B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:33:51 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so17114240qcx.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:33:51 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id j4si6505511qao.97.2015.01.28.08.33.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 08:33:51 -0800 (PST)
Date: Wed, 28 Jan 2015 10:33:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2 2/3] slub: fix kmem_cache_shrink return value
In-Reply-To: <7ee54d0d26f6c61e2ecf50300ee955610749b344.1422461573.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1501281032220.32147@gentwo.org>
References: <cover.1422461573.git.vdavydov@parallels.com> <7ee54d0d26f6c61e2ecf50300ee955610749b344.1422461573.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 Jan 2015, Vladimir Davydov wrote:

> @@ -3419,6 +3420,9 @@ int __kmem_cache_shrink(struct kmem_cache *s)
>  		for (i = SHRINK_PROMOTE_MAX - 1; i >= 0; i--)
>  			list_splice_init(promote + i, &n->partial);
>
> +		if (n->nr_partial || slabs_node(s, node))

The total number of slabs obtained via slabs_node always contains the
number of partial ones. So no need to check n->nr_partial.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
