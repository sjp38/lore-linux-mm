Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 88AA16B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:11:25 -0500 (EST)
Received: by igcph11 with SMTP id ph11so96425694igc.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:11:25 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 21si5588188iod.72.2015.12.08.06.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 06:11:24 -0800 (PST)
Date: Tue, 8 Dec 2015 08:11:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151208143915.0ffbdf51@redhat.com>
Message-ID: <alpine.DEB.2.20.1512080809320.20165@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul> <20151203155736.3589.67424.stgit@firesoul> <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org> <20151207122549.109e82db@redhat.com> <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
 <20151208143915.0ffbdf51@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 8 Dec 2015, Jesper Dangaard Brouer wrote:

> > > > Does this support freeing objects from a set of different caches?
> > >
> > > This is for supporting memcg (CONFIG_MEMCG_KMEM).
> > >
> > > Quoting from commit 033745189b1b ("slub: add missing kmem cgroup
> > > support to kmem_cache_free_bulk"):
> > >
> > >    Incoming bulk free objects can belong to different kmem cgroups, and
> > >    object free call can happen at a later point outside memcg context.  Thus,
> > >    we need to keep the orig kmem_cache, to correctly verify if a memcg object
> > >    match against its "root_cache" (s->memcg_params.root_cache).
> >
> > Where is that verification? This looks like SLAB would support freeing
> > objects from different caches.
>
> This is for supporting CONFIG_MEMCG_KMEM, thus I would like Vladimir
> input on this, as I don't know enough about memcg....

Oww... So far objects passed to bulk free must be confined to the *same*
slab cache. Not the same "root_cache". Are we changing that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
