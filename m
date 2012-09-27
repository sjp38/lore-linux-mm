Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A0AA46B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:32:19 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:32:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK1 [04/13] slab: Use the new create_boot_cache function to
 simplify bootstrap
In-Reply-To: <5064538E.7060107@parallels.com>
Message-ID: <0000013a0824765e-b3d9f805-f090-45fd-9cca-e6ade916b14d-000000@email.amazonses.com>
References: <20120926200005.911809821@linux.com> <0000013a043aca11-926da326-bd96-42b0-8d69-92ce9833912b-000000@email.amazonses.com> <5064538E.7060107@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 27 Sep 2012, Glauber Costa wrote:

> On 09/27/2012 12:18 AM, Christoph Lameter wrote:
> > -	node = numa_mem_id();
> > -
> >  	/* 1) create the kmem_cache */
> > -	INIT_LIST_HEAD(&slab_caches);
> > -	list_add(&kmem_cache->list, &slab_caches);
> > -	kmem_cache->colour_off = cache_line_size();
> > -	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
> >
> >  	/*
> Don't you have to initialize this list head somewhere ?
> You are deleting this code, but not putting it back anywhere.

Thought the declaration would do the initialization in mm/slab_common.c:

enum slab_state slab_state;
LIST_HEAD(slab_caches);
DEFINE_MUTEX(slab_mutex);
struct kmem_cache *kmem_cache;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
