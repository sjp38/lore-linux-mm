Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 9B0996B0069
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:48:01 -0400 (EDT)
Message-ID: <50656374.8080600@parallels.com>
Date: Fri, 28 Sep 2012 12:44:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [10/13] Do not define KMALLOC array definitions for SLOB
References: <20120926200005.911809821@linux.com> <0000013a043aca17-be81d17b-47c7-4511-9a52-853a493a0437-000000@email.amazonses.com>
In-Reply-To: <0000013a043aca17-be81d17b-47c7-4511-9a52-853a493a0437-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 09/27/2012 12:18 AM, Christoph Lameter wrote:
> SLOB has no support for an array of kmalloc caches. Create a section
> in include/linux/slab.h that is dedicated to the kmalloc cache
> definition but disabled if SLOB is selected.
> 
> slab_common.c also has functions that are not needed for slob.
> Disable those as well.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 


> Index: linux/mm/slab_common.c
> ===================================================================
> --- linux.orig/mm/slab_common.c	2012-09-18 12:13:16.230754925 -0500
> +++ linux/mm/slab_common.c	2012-09-18 12:16:28.354706953 -0500
> @@ -218,6 +218,8 @@ int slab_is_available(void)
>  	return slab_state >= UP;
>  }
>  
> +#ifndef CONFIG_SLOB
> +
>  /* Create a cache during boot when no slab services are available yet */
>  void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
>  		unsigned long flags)
I don't see why you can't fold this directly in the patch where those
things are created.

> @@ -249,3 +251,5 @@ struct kmem_cache *__init create_kmalloc
>  	s->refcount = 1;
>  	return s;
>  }
> +
> +#endif /* !CONFIG_SLOB */
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
