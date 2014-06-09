Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id BA8F26B0082
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 09:04:29 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id n15so3044229lbi.33
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 06:04:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dq5si37028616lbc.18.2014.06.09.06.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jun 2014 06:04:28 -0700 (PDT)
Date: Mon, 9 Jun 2014 17:04:16 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
Message-ID: <20140609130414.GB32192@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1406060949430.32229@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406060949430.32229@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 06, 2014 at 09:52:17AM -0500, Christoph Lameter wrote:
> On Fri, 6 Jun 2014, Vladimir Davydov wrote:
> 
> > @@ -740,7 +740,8 @@ static void start_cpu_timer(int cpu)
> >  	}
> >  }
> >
> > -static struct array_cache *alloc_arraycache(int node, int entries,
> > +static struct array_cache *alloc_arraycache(struct kmem_cache *cachep,
> > +					    int node, int entries,
> >  					    int batchcount, gfp_t gfp)
> >  {
> >  	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
> 
> If you pass struct kmem_cache * into alloc_arraycache then we do not need
> to pass entries or batchcount because they are available in struct
> kmem_cache.

Seems you're right. Will rework.

> Otherwise this patch looks a bit too large to me. Simplify a bit?

Yeah, exactly. I will split it and resend.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
