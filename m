Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AFE8C6B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:26:43 -0500 (EST)
Received: by padhk6 with SMTP id hk6so9054923pad.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:26:43 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x16si20935010pfa.116.2015.12.10.07.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 07:26:43 -0800 (PST)
Date: Thu, 10 Dec 2015 18:26:32 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
Message-ID: <20151210152632.GA11488@esperanza>
References: <20151208161751.21945.53936.stgit@firesoul>
 <20151208161903.21945.33876.stgit@firesoul>
 <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
 <20151209195325.68eaf314@redhat.com>
 <alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
 <20151210161018.28cedb68@redhat.com>
 <alpine.DEB.2.20.1512100918010.15476@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1512100918010.15476@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 10, 2015 at 09:18:26AM -0600, Christoph Lameter wrote:
> On Thu, 10 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > If we drop the "kmem_cache *s" parameter from kmem_cache_free_bulk(),
> > and also make it handle kmalloc'ed objects. Why should we name it
> > "kmem_cache_free_bulk"? ... what about naming it kfree_bulk() ???
> 
> Yes makes sense.

IMHO kmem_cache_alloc_bulk/kfree_bulk looks awkward, especially taking
into account the fact that we pair kmem_cache_alloc/kmem_cache_free and
kmalloc/kfree, but never kmem_cache_alloc/kfree.

So I'd vote for kmem_cache_free_bulk taking a kmem_cache as an argument,
but I'm not a potential user of this API, so please don't count my vote
:-)

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
