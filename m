Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 30ED96B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:49:49 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so7435893qcx.11
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:49:49 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id m64si13550544qge.85.2015.01.26.07.49.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 07:49:48 -0800 (PST)
Date: Mon, 26 Jan 2015 09:49:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
In-Reply-To: <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1501260949150.15849@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> @@ -2400,11 +2400,16 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
>  	return (ret ? 1 : 0);
>  }
>
> +void __kmem_cache_shrink(struct kmem_cache *cachep)
> +{
> +	__cache_shrink(cachep);
> +}
> +

Why do we need this wrapper? Rename __cache_shrink to __kmem_cache_shrink
instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
