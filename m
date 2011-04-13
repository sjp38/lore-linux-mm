Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D7D2D900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:36:29 -0400 (EDT)
Date: Wed, 13 Apr 2011 08:36:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix a typo in config name
In-Reply-To: <alpine.DEB.2.00.1104121913410.15979@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1104130835360.16214@router.home>
References: <4DA3FDB2.9090100@cn.fujitsu.com> <alpine.DEB.2.00.1104121301430.14692@router.home> <alpine.DEB.2.00.1104121913410.15979@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 12 Apr 2011, David Rientjes wrote:

> On Tue, 12 Apr 2011, Christoph Lameter wrote:
>
> > On Tue, 12 Apr 2011, Li Zefan wrote:
> >
> > > There's no config named SLAB_DEBUG, and it should be a typo
> > > of SLUB_DEBUG.
> > >
> > > Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> > > ---
> > >
> > > not slub expert, don't know how this bug affects slub debugging.
> >
> > Affects the bootstrap code.
> >
>
> I don't see how, there should be no partial or full slabs for either
> kmem_cache or kmem_cache_node at this point in the boot sequence.  I think
> kmem_cache_bootstrap_fixup() should only need to add the cache to the list
> of slab caches and set the refcount accordingly.

Hmmm... That depends on the number of objects in a slab page. If that is
one then we may have an issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
