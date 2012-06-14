Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 80B996B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:19:07 -0400 (EDT)
Message-ID: <4FD99DE4.1080107@parallels.com>
Date: Thu, 14 Jun 2012 12:16:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [14/20] Always use the name "kmem_cache" for the slab
 cache with the kmem_cache structure.
References: <20120613152451.465596612@linux.com> <20120613152522.780459464@linux.com>
In-Reply-To: <20120613152522.780459464@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 06/13/2012 07:25 PM, Christoph Lameter wrote:
> -	cache_cache.object_size = cache_cache.size;
> -	cache_cache.size = ALIGN(cache_cache.size,
> +	kmem_cache->size = kmem_cache->size;

You actually mean kmem_cache->object_size = kmem_cache->size.
Besides size = size making no sense, This had the effect for me to have 
allocations that were supposed to be zeroed not being so particularly in 
the edges of the objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
