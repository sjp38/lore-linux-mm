Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B47506B0087
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:52:23 -0400 (EDT)
Received: by yhr47 with SMTP id 47so11004286yhr.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 13:52:22 -0700 (PDT)
Date: Thu, 2 Aug 2012 13:52:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common [02/19] slub: Use kmem_cache for the kmem_cache
 structure
In-Reply-To: <20120802201531.490489455@linux.com>
Message-ID: <alpine.DEB.2.00.1208021352000.5454@chino.kir.corp.google.com>
References: <20120802201506.266817615@linux.com> <20120802201531.490489455@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> Do not use kmalloc() but kmem_cache_alloc() for the allocation
> of the kmem_cache structures in slub.
> 
> This is the way its supposed to be. Recent merges lost
> the freeing of the kmem_cache structure and so this is also
> fixing memory leak on kmem_cache_destroy() by adding
> the missing free action to sysfs_slab_remove().
> 

Nice catch of the memory leak!

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
