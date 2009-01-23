Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA3E76B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 07:55:17 -0500 (EST)
Date: Fri, 23 Jan 2009 13:55:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123125508.GG19986@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <87hc3qcpo1.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87hc3qcpo1.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 10:55:26AM +0100, Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> > +#ifdef CONFIG_NUMA
> > +void *__kmalloc_node(size_t size, gfp_t flags, int node);
> > +void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> > +
> > +static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> 
> kmalloc_node should be infrequent, i suspect it can be safely out of lined.

Hmm, it only takes up another couple of hundred bytes for a full
numa kernel. Completely out of lining it can take a slightly slower
path and makes the code slightly different from the kmalloc case.
So I'll leave this change for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
