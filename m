Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 044D46B0062
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:37:53 -0400 (EDT)
Date: Fri, 3 Aug 2012 09:02:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [02/19] slub: Use kmem_cache for the kmem_cache
 structure
In-Reply-To: <501BD7CE.1080300@parallels.com>
Message-ID: <alpine.DEB.2.00.1208030858230.2332@router.home>
References: <20120802201506.266817615@linux.com> <20120802201531.490489455@linux.com> <501BD019.70803@parallels.com> <alpine.DEB.2.00.1208030851160.2332@router.home> <501BD7CE.1080300@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Fri, 3 Aug 2012, Glauber Costa wrote:

> On 08/03/2012 05:52 PM, Christoph Lameter wrote:
> >> When a non-alias cache is freed, both sysfs_slab_remove and
> >> > kmem_cache_release are called.
> >> >
> >> > You are freeing structures on both, so you have two double frees.
> >> >
> >> > slab_sysfs_remove() is the correct place for it, so you need to remove
> >> > them from kmem_cache_release(), which becomes an empty function.
> > So this is another bug in Linus's tree.
> >
>
> Indeed, but only when !SYSFS.
>
> When we have sysfs on, sysfs_slab_remove actually did no freeing - as
> you figured out yourself, so it was actually "correct".

Right so the correct solution is to leave it in kmem_cache_release() and
remove from sysfs_slab_remove. Basically dropping the last hunk of my
patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
