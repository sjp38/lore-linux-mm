Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 99B796B00F2
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:03:57 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gl10so549742lab.5
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:03:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o1si26571153lah.115.2014.06.12.03.03.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jun 2014 03:03:56 -0700 (PDT)
Date: Thu, 12 Jun 2014 14:03:46 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 5/8] slub: make slab_free non-preemptable
Message-ID: <20140612100344.GB19221@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
 <20140612065842.GE19918@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140612065842.GE19918@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Thu, Jun 12, 2014 at 03:58:42PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 06, 2014 at 05:22:42PM +0400, Vladimir Davydov wrote:
> > @@ -2673,18 +2673,11 @@ static __always_inline void slab_free(struct kmem_cache *s,
> >  
> >  	slab_free_hook(s, x);
> >  
> > -redo:
> > -	/*
> > -	 * Determine the currently cpus per cpu slab.
> > -	 * The cpu may change afterward. However that does not matter since
> > -	 * data is retrieved via this pointer. If we are on the same cpu
> > -	 * during the cmpxchg then the free will succedd.
> > -	 */
> >  	preempt_disable();
> 
> Could you add some code comment why this preempt_disable/enable() is
> needed? We don't have any clue that kmemcg depends on these things
> on code, so someone cannot understand why it is here.
> 
> If possible, please add similar code comment on slab_alloc in mm/slab.c.

Sure.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
