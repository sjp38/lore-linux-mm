Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 2B2136B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 11:44:45 -0400 (EDT)
Date: Wed, 16 May 2012 10:44:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 5/9] slabs: Common definition for
 boot state of the slab allocators
In-Reply-To: <4FB36318.30600@parallels.com>
Message-ID: <alpine.DEB.2.00.1205161044000.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201611.710540961@linux.com> <4FB36318.30600@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> > @@ -117,10 +117,6 @@ int kmem_cache_shrink(struct kmem_cache
> >   void kmem_cache_free(struct kmem_cache *, void *);
> >   unsigned int kmem_cache_size(struct kmem_cache *);
> >
> > -/* Slab internal function */
> > -struct kmem_cache *__kmem_cache_create(const char *, size_t, size_t,
> > -			unsigned long,
> > -			void (*)(void *));
> >   /*
> >    * Please use this macro to create slab caches. Simply specify the
> >    * name of the structure and maybe some flags that are listed above.
> >
>
> Should be in an earlier patch...

This patch moves the definition to mm/slab.h since it is only used for
allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
