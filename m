Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id E6B746B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:23:25 -0500 (EST)
Received: by igbhv6 with SMTP id hv6so2583773igb.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:23:25 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id a19si17132792igr.11.2015.11.10.07.23.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Nov 2015 07:23:25 -0800 (PST)
Date: Tue, 10 Nov 2015 09:23:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
In-Reply-To: <20151110083042.GS31308@esperanza>
Message-ID: <alpine.DEB.2.20.1511100922500.8420@east.gentwo.org>
References: <20151109181604.8231.22983.stgit@firesoul> <20151109181703.8231.66384.stgit@firesoul> <20151109191335.GM31308@esperanza> <alpine.DEB.2.20.1511091603240.26497@east.gentwo.org> <20151110083042.GS31308@esperanza>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 10 Nov 2015, Vladimir Davydov wrote:

> But it doesn't mean we have to define it as (void **) in
> slab_alloc_node. Actually, the fact that object is of type (void **) is
> never used in slab_alloc_node, and all functions called by it accept
> (void *) for object, not (void **). Dropping one star there doesn't
> break anything and looks less confusing IMO.

I just tried to point out that this is a historical artifact. Can be
removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
