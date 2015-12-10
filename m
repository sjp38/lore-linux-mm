Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6E76B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:18:28 -0500 (EST)
Received: by ioir85 with SMTP id r85so95465515ioi.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:18:28 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id k65si20688341iok.56.2015.12.10.07.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 07:18:27 -0800 (PST)
Date: Thu, 10 Dec 2015 09:18:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151210161018.28cedb68@redhat.com>
Message-ID: <alpine.DEB.2.20.1512100918010.15476@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul> <20151208161903.21945.33876.stgit@firesoul> <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org> <20151209195325.68eaf314@redhat.com> <alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
 <20151210161018.28cedb68@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 10 Dec 2015, Jesper Dangaard Brouer wrote:

> If we drop the "kmem_cache *s" parameter from kmem_cache_free_bulk(),
> and also make it handle kmalloc'ed objects. Why should we name it
> "kmem_cache_free_bulk"? ... what about naming it kfree_bulk() ???

Yes makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
