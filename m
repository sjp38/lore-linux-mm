Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id BC4126B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:47:29 -0400 (EDT)
Message-ID: <501A92FB.8020906@parallels.com>
Date: Thu, 2 Aug 2012 18:47:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com> <alpine.DEB.2.00.1208020912340.23049@router.home> <501A8BE4.4060206@parallels.com> <alpine.DEB.2.00.1208020941150.23049@router.home>
In-Reply-To: <alpine.DEB.2.00.1208020941150.23049@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 06:45 PM, Christoph Lameter wrote:
> On Thu, 2 Aug 2012, Glauber Costa wrote:
> 
>> It also works okay both before the patches are applied, and with slab.
> 
> Ok. I am seeing the same problem when using the following patch. That is
> pretty early during boot and so there may be issues with sysfs that the
> patchset caused. Looking into it.
>
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2012-08-02 09:36:04.855637689 -0500
> +++ linux-2.6/mm/slub.c	2012-08-02 09:42:04.358089667 -0500
> @@ -3768,6 +3768,16 @@
>  		caches, cache_line_size(),
>  		slub_min_order, slub_max_order, slub_min_objects,
>  		nr_cpu_ids, nr_node_ids);
> +
> +	{ struct kmem_cache *qq;
> +
> +		qq = create_kmalloc_cache("qq", 800, 0);
> +		kmem_cache_destroy(qq);
> +
> +		qq = create_kmalloc_cache("qq", 800, 0);
> +		kmem_cache_destroy(qq);
> +	}
> +
>  }
> 
>  void __init kmem_cache_init_late(void)
>

Mine is similar, except:
1) I don't create a kmalloc cache (shouldn't matter)
2) I do it after SLAB_FULL.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
