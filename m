Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 1EBAF6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 17:23:12 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2507218pbb.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 14:23:11 -0700 (PDT)
Date: Thu, 31 May 2012 14:23:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common 04/22] [slab] Use page struct fields instead of casting
In-Reply-To: <20120523203507.324764286@linux.com>
Message-ID: <alpine.DEB.2.00.1205311422440.2764@chino.kir.corp.google.com>
References: <20120523203433.340661918@linux.com> <20120523203507.324764286@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, 23 May 2012, Christoph Lameter wrote:

> Add fields to the page struct so that it is properly documented that
> slab overlays the lru fields.
> 
> This cleans up some casts in slab.
> 

Sounds good, but...

> Index: linux-2.6/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm_types.h	2012-05-22 09:05:49.716464025 -0500
> +++ linux-2.6/include/linux/mm_types.h	2012-05-22 09:21:28.532444572 -0500
> @@ -90,6 +90,10 @@ struct page {
>  				atomic_t _count;		/* Usage count, see below. */
>  			};
>  		};
> +		struct {		/* SLAB */
> +			struct kmem_cache *slab_cache;
> +			struct slab *slab_page;
> +		};
>  	};
>  
>  	/* Third double word block */

The lru fields are in the third double word block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
