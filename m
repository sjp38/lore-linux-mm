Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id BEE006B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:15:22 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so17760389igb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:15:22 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id rt1si5608425igb.69.2015.12.08.06.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 06:15:22 -0800 (PST)
Date: Tue, 8 Dec 2015 08:15:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151208141211.GH11488@esperanza>
Message-ID: <alpine.DEB.2.20.1512080814350.20678@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155736.3589.67424.stgit@firesoul> <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org> <20151207122549.109e82db@redhat.com> <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
 <20151208141211.GH11488@esperanza>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 8 Dec 2015, Vladimir Davydov wrote:

> If producers are represented by different processes, they can belong to
> different memory cgroups, so that objects passed to the consumer will
> come from different kmem caches (per memcg caches), although they are
> all of the same kind. This means, we must call cache_from_obj() on each
> object passed to kmem_cache_free_bulk() in order to free each object to
> the cache it was allocated from.

The we should change the API so that we do not specify kmem_cache on bulk
free. Do it like kfree without any cache spec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
