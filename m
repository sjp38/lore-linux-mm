Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id D78FB6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 12:24:58 -0500 (EST)
Received: by iofh3 with SMTP id h3so99899626iof.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 09:24:58 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id c141si21357394ioc.40.2015.12.10.09.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 09:24:58 -0800 (PST)
Date: Thu, 10 Dec 2015 11:24:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151210152632.GA11488@esperanza>
Message-ID: <alpine.DEB.2.20.1512101124001.16497@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul> <20151208161903.21945.33876.stgit@firesoul> <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org> <20151209195325.68eaf314@redhat.com> <alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
 <20151210161018.28cedb68@redhat.com> <alpine.DEB.2.20.1512100918010.15476@east.gentwo.org> <20151210152632.GA11488@esperanza>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 10 Dec 2015, Vladimir Davydov wrote:

> IMHO kmem_cache_alloc_bulk/kfree_bulk looks awkward, especially taking
> into account the fact that we pair kmem_cache_alloc/kmem_cache_free and
> kmalloc/kfree, but never kmem_cache_alloc/kfree.
>
> So I'd vote for kmem_cache_free_bulk taking a kmem_cache as an argument,
> but I'm not a potential user of this API, so please don't count my vote
> :-)

One way to have it less awkward is to keep naming it kmem_cache_free_bulk
but omit the kmem_cache parameter like what I did initially.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
