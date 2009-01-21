Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A20106B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 10:17:48 -0500 (EST)
Date: Wed, 21 Jan 2009 16:17:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090121151743.GW24891@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <20090121145918.GA11311@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121145918.GA11311@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 03:59:18PM +0100, Ingo Molnar wrote:
> 
> * Nick Piggin <npiggin@suse.de> wrote:
> 
> > +/*
> > + * Management object for a slab cache.
> > + */
> > +struct kmem_cache {
> > +	unsigned long flags;
> > +	int hiwater;		/* LIFO list high watermark */
> > +	int freebatch;		/* LIFO freelist batch flush size */
> > +	int objsize;		/* The size of an object without meta data */
> > +	int offset;		/* Free pointer offset. */
> > +	int objects;		/* Number of objects in slab */
> > +
> > +	int size;		/* The size of an object including meta data */
> > +	int order;		/* Allocation order */
> > +	gfp_t allocflags;	/* gfp flags to use on allocation */
> > +	unsigned int colour_range;	/* range of colour counter */
> > +	unsigned int colour_off;		/* offset per colour */
> > +	void (*ctor)(void *);
> > +
> 
> Mind if i nitpick a bit about minor style issues? Since this is going to 
> be the next Linux SLAB allocator we might as well do it perfectly :-)

Well, let's not get ahead of ourselves :) But it's very appreciated.

I think most if not all of your suggestions are good ones, although
I probably won't convert to ftrace just for the moment.

I'll come up with an incremental patch....

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
