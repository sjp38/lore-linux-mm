Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4406D6B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 08:39:22 -0500 (EST)
Received: by qgeb1 with SMTP id b1so15648488qge.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 05:39:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si3410117qht.71.2015.12.08.05.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 05:39:21 -0800 (PST)
Date: Tue, 8 Dec 2015 14:39:15 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
Message-ID: <20151208143915.0ffbdf51@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul>
	<20151203155736.3589.67424.stgit@firesoul>
	<alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
	<20151207122549.109e82db@redhat.com>
	<alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com


(To Vladimir can you comment on memcg?)


On Mon, 7 Dec 2015 08:59:25 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

> On Mon, 7 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > > > +
> > > > +	local_irq_disable();
> > > > +	for (i = 0; i < size; i++) {
> > > > +		void *objp = p[i];
> > > > +
> > > > +		s = cache_from_obj(orig_s, objp);
> > >
> > > Does this support freeing objects from a set of different caches?
> >
> > This is for supporting memcg (CONFIG_MEMCG_KMEM).
> >
> > Quoting from commit 033745189b1b ("slub: add missing kmem cgroup
> > support to kmem_cache_free_bulk"):
> >
> >    Incoming bulk free objects can belong to different kmem cgroups, and
> >    object free call can happen at a later point outside memcg context.  Thus,
> >    we need to keep the orig kmem_cache, to correctly verify if a memcg object
> >    match against its "root_cache" (s->memcg_params.root_cache).
> 
> Where is that verification? This looks like SLAB would support freeing
> objects from different caches.

This is for supporting CONFIG_MEMCG_KMEM, thus I would like Vladimir
input on this, as I don't know enough about memcg....

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
