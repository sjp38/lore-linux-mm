Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 871E46B0088
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:42:53 -0400 (EDT)
Date: Tue, 26 May 2009 17:43:13 -0400
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] drm: i915: ensure objects are allocated below 4GB on
	PAE
Message-ID: <20090526214313.GA16929@bombadil.infradead.org>
References: <20090526162717.GC14808@bombadil.infradead.org> <1243365473.23657.32.camel@twins> <1243373730.8400.26.camel@gaiman.anholt.net> <1243374085.6600.25.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243374085.6600.25.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Eric Anholt <eric@anholt.net>, Kyle McMartin <kyle@mcmartin.ca>, airlied@redhat.com, dri-devel@lists.sf.net, linux-kernel@vger.kernel.org, jbarnes@virtuousgeek.org, stable@kernel.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, shaohua.li@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 11:41:25PM +0200, Peter Zijlstra wrote:
> On Tue, 2009-05-26 at 14:35 -0700, Eric Anholt wrote:
> > On Tue, 2009-05-26 at 21:17 +0200, Peter Zijlstra wrote:
> > > On Tue, 2009-05-26 at 12:27 -0400, Kyle McMartin wrote:
> > > > From: Kyle McMartin <kyle@redhat.com>
> > > > 
> > > > Ensure we allocate GEM objects below 4GB on PAE machines, otherwise
> > > > misery ensues. This patch is based on a patch found on dri-devel by
> > > > Shaohua Li, but Keith P. expressed reticence that the changes unfairly
> > > > penalized other hardware.
> > > > 
> > > > (The mm/shmem.c hunk is necessary to ensure the DMA32 flag isn't used
> > > >  by the slab allocator via radix_tree_preload, which will hit a
> > > >  WARN_ON.)
> > > 
> > > Why is this, is the gart not PAE friendly?
> > > 
> > > Seems to me its a grand way of promoting 64bit hard/soft-ware.
> > 
> > No, the GART's fine.  But the APIs required to make the AGP code
> > PAE-friendly got deprecated, so the patches to fix the AGP code got
> > NAKed, and Venkatesh  never sent out his patches to undeprecate the APIs
> > and use them.
> > 
> > It's been like 6 months now, and it's absurd.  I'd like to see this
> > patch go in so people's graphics can start working again and stop
> > corrupting system memory.
> 
> For .30 yes, for .31 we need to resolve that AGP issue, 6 months does
> seem excessive to get something like that sorted.
> 

Yeah, sorry, I should have explained it in the description better, this
is just a paper-over fix for the problem on >4GB 32-bit machines (which
is why I CC'd stable@.)

Thanks,
	Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
