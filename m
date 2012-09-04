Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 596D26B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 15:10:35 -0400 (EDT)
Date: Tue, 4 Sep 2012 19:10:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: C13 [14/14] Move kmem_cache refcounting to common code
In-Reply-To: <5044C8E7.4000001@parallels.com>
Message-ID: <0000013992b0f412-655e9134-efbc-41ff-b47e-2bc24885cedd-000000@email.amazonses.com>
References: <20120824160903.168122683@linux.com> <00000139596cab0a-61fcd4d7-52b5-4e16-89de-57c8df4dc8a4-000000@email.amazonses.com> <5044C8E7.4000001@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>


On Mon, 3 Sep 2012, Glauber Costa wrote:

> On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> > Index: linux/mm/slob.c
> > ===================================================================
> > --- linux.orig/mm/slob.c	2012-08-22 10:27:54.846388442 -0500
> > +++ linux/mm/slob.c	2012-08-22 10:28:31.658969127 -0500
> > @@ -524,8 +524,6 @@ int __kmem_cache_create(struct kmem_cach
> >  	if (c->align < align)
> >  		c->align = align;
> >
> > -	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
> > -	c->refcount = 1;
> >  	return 0;
> >  }
> >
> Is the removal of kmemleak_alloc intended ?
> Nothing about that is mentioned in the changelog.

The statement should have been removed earlier. Checking is done when
allocating the object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
