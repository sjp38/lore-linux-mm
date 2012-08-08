Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 317546B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 13:32:44 -0400 (EDT)
Date: Wed, 8 Aug 2012 12:31:31 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [13/20] Move kmem_cache allocations into common code.
In-Reply-To: <CAAmzW4OjSm+o+dwB-EBGprQyr9TP7j3jK3=FHEFVuf97eWcrzg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1208081228490.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192155.337884418@linux.com> <CAAmzW4OjSm+o+dwB-EBGprQyr9TP7j3jK3=FHEFVuf97eWcrzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Sun, 5 Aug 2012, JoonSoo Kim wrote:

> > Index: linux-2.6/mm/slab_common.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slab_common.c     2012-08-03 13:17:27.000000000 -0500
> > +++ linux-2.6/mm/slab_common.c  2012-08-03 13:20:48.080876182 -0500
> > @@ -104,19 +104,21 @@ struct kmem_cache *kmem_cache_create(con
> >                 goto out_locked;
> >         }
> >
> > -       s = __kmem_cache_create(n, size, align, flags, ctor);
> > -
> > +       s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> >         if (s) {
>
> Is it necessary that kmem_cache_zalloc() is invoked with GFP_NOWAIT?
> As I understand, before patch, it is called with GFP_KERNEL.

Correct. GFP_NOWAIT would be used in a boot situation. Was doing this
while also working on bootstrap issues. Fixed in next release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
