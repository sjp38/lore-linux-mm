Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 98C166B0068
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 14:05:21 -0400 (EDT)
Date: Wed, 1 Aug 2012 13:05:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [2/9] slub: Use kmem_cache for the kmem_cache structure
In-Reply-To: <5018EBDA.4090902@parallels.com>
Message-ID: <alpine.DEB.2.00.1208011301220.4606@router.home>
References: <20120731173620.432853182@linux.com> <20120731173634.744568366@linux.com> <5018EBDA.4090902@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, 1 Aug 2012, Glauber Costa wrote:

> On 07/31/2012 09:36 PM, Christoph Lameter wrote:
> > Do not use kmalloc() but kmem_cache_alloc() for the allocation
> > of the kmem_cache structures in slub.
> >
> > This is the way its supposed to be. Recent merges lost
> > the freeing of the kmem_cache structure and so this is also
> > fixing memory leak on kmem_cache_destroy() by adding
> > the missing free action to sysfs_slab_remove().
>
> This patch seems incomplete to say the least.

Well ok we could have also converted those but these statements will be
removed later anyways. And you can release a kmem_cache allocation
legitimately with kfree so this works just fine. The problem was that the
release in slab_common did a kmem_cache_free() which must have an object
from the correct cache.

Will update those and the Next patchset will include the conversion of
those as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
