Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 14E876B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 09:48:45 -0400 (EDT)
Date: Mon, 21 May 2012 08:48:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 04/12] slabs: Extract common code for
 kmem_cache_create
In-Reply-To: <4FBA09C6.9090302@parallels.com>
Message-ID: <alpine.DEB.2.00.1205210848170.27592@router.home>
References: <20120518161906.207356777@linux.com> <20120518161929.264565121@linux.com> <4FBA09C6.9090302@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On Mon, 21 May 2012, Glauber Costa wrote:

> On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> > Index: linux-2.6/mm/slab.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slab.c	2012-05-11 09:36:35.308445605 -0500
> > +++ linux-2.6/mm/slab.c	2012-05-11 09:43:33.160436947 -0500
> > @@ -1585,7 +1585,7 @@ void __init kmem_cache_init(void)
> >   	 * bug.
> >   	 */
> >
> > -	sizes[INDEX_AC].cs_cachep = kmem_cache_create(names[INDEX_AC].name,
> > +	sizes[INDEX_AC].cs_cachep = __kmem_cache_create(names[INDEX_AC].name,
> >   					sizes[INDEX_AC].cs_size,
> >   					ARCH_KMALLOC_MINALIGN,
> >   					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
>
> So, before your patch, the kmalloc caches were getting all the sanity checking
> done. No we're skipping them. Any particular reason?

I can visually do the sanity checking since the parameters are all in the
source. No need to do these checks again at runtime.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
