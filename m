Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3BFE16B01BF
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:41:53 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:35:28 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 10/16] slub: Remove static kmem_cache_cpu array for boot
In-Reply-To: <alpine.DEB.2.00.1006261657290.27174@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006291031380.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212106.973996317@quilx.com> <alpine.DEB.2.00.1006261657290.27174@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, David Rientjes wrote:

> > @@ -2105,7 +2096,7 @@ static void early_kmem_cache_node_alloc(
> >
> >  	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
> >
> > -	page = new_slab(kmalloc_caches, GFP_KERNEL, node);
> > +	page = new_slab(kmalloc_caches, GFP_KERNEL & gfp_allowed_mask, node);
> >
> >  	BUG_ON(!page);
> >  	if (page_to_nid(page) != node) {
>
> This needs to be merged into the preceding patch since it had broken new
> slab allocations during early boot while irqs are still disabled; it also
> seems deserving of a big fat comment about why it's required in this
> situation.

AFAICT The earlier patch did not break anything but leave existing
behavior the way it was. Breakage would occur in this patch because it
results in allocations occurring earlier during boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
