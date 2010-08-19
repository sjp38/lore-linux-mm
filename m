Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C0DAA6B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:20:05 -0400 (EDT)
Date: Thu, 19 Aug 2010 18:20:05 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008191819420.7903@router.home>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com> <alpine.DEB.2.00.1008191627100.5611@router.home>
 <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, David Rientjes wrote:

> On Thu, 19 Aug 2010, Christoph Lameter wrote:
>
> > Correct. Then we also do not need the sysfs_slab_add in
> > create_kmalloc_cache.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> This doesn't apply on top of this patchset, it was generated from the
> entire SLUB+Q patchset (we don't have __ALIEN_CACHE yet).  Besides the
> conflicts, the patch is good.
>
> Acked-by: David Rientjes <rientjes@google.com>

Right. I will merge this correctly for the next release that has all
patches acked by you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
