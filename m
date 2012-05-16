Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B1C436B00E7
	for <linux-mm@kvack.org>; Wed, 16 May 2012 10:28:28 -0400 (EDT)
Date: Wed, 16 May 2012 09:28:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 3/9] Extract common fields from struct
 kmem_cache
In-Reply-To: <4FB35E7F.8030303@parallels.com>
Message-ID: <alpine.DEB.2.00.1205160926470.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201610.559075441@linux.com> <4FB35E7F.8030303@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> >   /*
> > + * Common fields provided in kmem_cache by all slab allocators
> > + */
> > +#define SLAB_COMMON \
> > +	unsigned int size, align;					\
> > +	unsigned long flags;						\
> > +	const char *name;						\
> > +	int refcount;							\
> > +	void (*ctor)(void *);						\
> > +	struct list_head list;
> > +
> > +/*
> >    * struct kmem_cache related prototypes
>
> Isn't it better to define struct kmem_cache here, and then put the non-common
> fields under proper ifdefs ?

Then we would move the definition to include/linux/slab.h. The allocator
kmem_cache struct definitions rely on other allocator specific
declarations at this point. Wont work.

> > Index: linux-2.6/mm/slob.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slob.c	2012-05-11 08:34:31.792522763 -0500
> > +++ linux-2.6/mm/slob.c	2012-05-11 09:42:52.032437799 -0500
> > @@ -538,13 +538,6 @@ size_t ksize(const void *block)
> >   }
> >   EXPORT_SYMBOL(ksize);
> >
> > -struct kmem_cache {
> > -	unsigned int size, align;
> > -	unsigned long flags;
> > -	const char *name;
> > -	void (*ctor)(void *);
> > -};
> > -
>
> Who defines struct kmem_cache for the slob now ?

Its defined in include/linux/slob_def.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
