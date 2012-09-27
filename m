Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BE9BD6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 09:27:54 -0400 (EDT)
Message-ID: <5064538E.7060107@parallels.com>
Date: Thu, 27 Sep 2012 17:24:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [04/13] slab: Use the new create_boot_cache function to simplify
 bootstrap
References: <20120926200005.911809821@linux.com> <0000013a043aca11-926da326-bd96-42b0-8d69-92ce9833912b-000000@email.amazonses.com>
In-Reply-To: <0000013a043aca11-926da326-bd96-42b0-8d69-92ce9833912b-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 09/27/2012 12:18 AM, Christoph Lameter wrote:
> -	node = numa_mem_id();
> -
>  	/* 1) create the kmem_cache */
> -	INIT_LIST_HEAD(&slab_caches);
> -	list_add(&kmem_cache->list, &slab_caches);
> -	kmem_cache->colour_off = cache_line_size();
> -	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
>  
>  	/*
Don't you have to initialize this list head somewhere ?
You are deleting this code, but not putting it back anywhere.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
