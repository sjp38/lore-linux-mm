Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CF2546B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:35:46 -0500 (EST)
Date: Wed, 24 Feb 2010 09:35:36 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: way to allocate memory within a range ?
In-Reply-To: <alpine.DEB.2.00.1002231744110.3435@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002232014200.15526@router.home>
References: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com> <alpine.DEB.2.00.1002231744110.3435@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Auguste Mome <augustmome@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010, David Rientjes wrote:

> > Or slab/slub system is not designed for this, I should forget it and
> > opt for another system?
> >
>
> No slab allocator is going to be designed for that other than SLAB_DMA to
> allocate from lowmem.  If you don't have need for lowmem, why do you need
> memory only from a certain range?  I can imagine it would have a usecase
> for memory hotplug to avoid allocating slab that cannot be reclaimed on
> certain nodes, but ZONE_MOVABLE seems more appropriate to guarantee such
> migration properties.

Awhile ago I posted a patch to do just that. It was called
alloc_pages_range() and the intend was to replace the dma zone.

http://lkml.indiana.edu/hypermail/linux/kernel/0609.2/2096.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
