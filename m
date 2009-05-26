Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 486F96B0085
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:40:55 -0400 (EDT)
Subject: Re: [PATCH] drm: i915: ensure objects are allocated below 4GB on
 PAE
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1243373730.8400.26.camel@gaiman.anholt.net>
References: <20090526162717.GC14808@bombadil.infradead.org>
	 <1243365473.23657.32.camel@twins>
	 <1243373730.8400.26.camel@gaiman.anholt.net>
Content-Type: text/plain
Date: Tue, 26 May 2009 23:41:25 +0200
Message-Id: <1243374085.6600.25.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric Anholt <eric@anholt.net>
Cc: Kyle McMartin <kyle@mcmartin.ca>, airlied@redhat.com, dri-devel@lists.sf.net, linux-kernel@vger.kernel.org, jbarnes@virtuousgeek.org, stable@kernel.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, shaohua.li@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-05-26 at 14:35 -0700, Eric Anholt wrote:
> On Tue, 2009-05-26 at 21:17 +0200, Peter Zijlstra wrote:
> > On Tue, 2009-05-26 at 12:27 -0400, Kyle McMartin wrote:
> > > From: Kyle McMartin <kyle@redhat.com>
> > > 
> > > Ensure we allocate GEM objects below 4GB on PAE machines, otherwise
> > > misery ensues. This patch is based on a patch found on dri-devel by
> > > Shaohua Li, but Keith P. expressed reticence that the changes unfairly
> > > penalized other hardware.
> > > 
> > > (The mm/shmem.c hunk is necessary to ensure the DMA32 flag isn't used
> > >  by the slab allocator via radix_tree_preload, which will hit a
> > >  WARN_ON.)
> > 
> > Why is this, is the gart not PAE friendly?
> > 
> > Seems to me its a grand way of promoting 64bit hard/soft-ware.
> 
> No, the GART's fine.  But the APIs required to make the AGP code
> PAE-friendly got deprecated, so the patches to fix the AGP code got
> NAKed, and Venkatesh  never sent out his patches to undeprecate the APIs
> and use them.
> 
> It's been like 6 months now, and it's absurd.  I'd like to see this
> patch go in so people's graphics can start working again and stop
> corrupting system memory.

For .30 yes, for .31 we need to resolve that AGP issue, 6 months does
seem excessive to get something like that sorted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
