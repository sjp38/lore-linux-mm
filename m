Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id CF7026B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 10:00:57 -0400 (EDT)
Date: Fri, 1 Jun 2012 09:00:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common 04/22] [slab] Use page struct fields instead of casting
In-Reply-To: <alpine.DEB.2.00.1205311422440.2764@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206010856310.6302@router.home>
References: <20120523203433.340661918@linux.com> <20120523203507.324764286@linux.com> <alpine.DEB.2.00.1205311422440.2764@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 31 May 2012, David Rientjes wrote:

> On Wed, 23 May 2012, Christoph Lameter wrote:
>
> > Add fields to the page struct so that it is properly documented that
> > slab overlays the lru fields.
> >
> > This cleans up some casts in slab.
> >
>
> Sounds good, but...
>
> > Index: linux-2.6/include/linux/mm_types.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm_types.h	2012-05-22 09:05:49.716464025 -0500
> > +++ linux-2.6/include/linux/mm_types.h	2012-05-22 09:21:28.532444572 -0500
> > @@ -90,6 +90,10 @@ struct page {
> >  				atomic_t _count;		/* Usage count, see below. */
> >  			};
> >  		};
> > +		struct {		/* SLAB */
> > +			struct kmem_cache *slab_cache;
> > +			struct slab *slab_page;
> > +		};
> >  	};
> >
> >  	/* Third double word block */
>
> The lru fields are in the third double word block.

Right. This slipped somehow into an earlier double word block. Next
patchset fixes that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
