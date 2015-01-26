Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4E16E6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 12:04:28 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so12971218pde.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:04:28 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nm9si12765057pbc.221.2015.01.26.09.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 09:04:27 -0800 (PST)
Date: Mon, 26 Jan 2015 20:04:18 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
Message-ID: <20150126170418.GC28978@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1501260949150.15849@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501260949150.15849@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 09:49:47AM -0600, Christoph Lameter wrote:
> On Mon, 26 Jan 2015, Vladimir Davydov wrote:
> 
> > @@ -2400,11 +2400,16 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
> >  	return (ret ? 1 : 0);
> >  }
> >
> > +void __kmem_cache_shrink(struct kmem_cache *cachep)
> > +{
> > +	__cache_shrink(cachep);
> > +}
> > +
> 
> Why do we need this wrapper? Rename __cache_shrink to __kmem_cache_shrink
> instead?
> 

__cache_shrink() is used not only in __kmem_cache_shrink(), but also in
SLAB's __kmem_cache_shutdown(), where we do need its return value to
check if the cache is empty.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
