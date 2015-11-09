Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id B0FBE6B0256
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 17:04:53 -0500 (EST)
Received: by igl9 with SMTP id 9so41047881igl.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 14:04:53 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id l80si879542iod.135.2015.11.09.14.04.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 09 Nov 2015 14:04:53 -0800 (PST)
Date: Mon, 9 Nov 2015 16:04:51 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
In-Reply-To: <20151109191335.GM31308@esperanza>
Message-ID: <alpine.DEB.2.20.1511091603240.26497@east.gentwo.org>
References: <20151109181604.8231.22983.stgit@firesoul> <20151109181703.8231.66384.stgit@firesoul> <20151109191335.GM31308@esperanza>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 9 Nov 2015, Vladimir Davydov wrote:

> I think it must be &object
>
> BTW why is object defined as void **? I suspect we can safely drop one
> star.

See get_freepointer()

static inline void *get_freepointer(struct kmem_cache *s, void *object)
{
        return *(void **)(object + s->offset);
}

The object at some point has a freepointer and ** allows the use of the
s->offset field to get to it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
