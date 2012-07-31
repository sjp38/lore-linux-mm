Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 2D5B66B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:12:32 -0400 (EDT)
Date: Tue, 31 Jul 2012 09:12:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [13/20] Extract a common function for
 kmem_cache_destroy
In-Reply-To: <5017C90E.7060706@parallels.com>
Message-ID: <alpine.DEB.2.00.1207310910580.32295@router.home>
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com> <5017C90E.7060706@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Tue, 31 Jul 2012, Glauber Costa wrote:

> Problem is that you are now allocating objects from kmem_cache with
> kmem_cache_alloc, but freeing it with kfree - and in multiple locations.

Why would this be an issue"?

> In particular, after the whole series is applied, you will have a call
> to "kfree(s)" in sysfs_slab_remove() that is called from
> kmem_cache_shutdown(), and later on kmem_cache_free(kmem_cache, s) from
> the destruction common code -> a double free.

I will look at that but I have already reworked the patches a couple of
times since then. I hope to be able to post an updated series against
upstream at the end of the week (before the next conference).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
