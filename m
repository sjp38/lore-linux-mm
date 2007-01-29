Date: Mon, 29 Jan 2007 22:50:01 +0000
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between movable and non-movable pages
Message-ID: <20070129225000.GG6602@flint.arm.linux.org.uk>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie> <20070126030753.03529e7a.akpm@osdl.org> <Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com> <20070126114615.5aa9e213.akpm@osdl.org> <Pine.LNX.4.64.0701261147300.15394@schroedinger.engr.sgi.com> <20070126122747.dde74c97.akpm@osdl.org> <Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com> <20070129143654.27fcd4a4.akpm@osdl.org> <Pine.LNX.4.64.0701291441260.1102@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701291441260.1102@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 29, 2007 at 02:45:06PM -0800, Christoph Lameter wrote:
> On Mon, 29 Jan 2007, Andrew Morton wrote:
> 
> > > All 64 bit machine will only have a single zone if we have such a range 
> > > alloc mechanism. The 32bit ones with HIGHMEM wont be able to avoid it, 
> > > true. But all arches that do not need gymnastics to access their memory 
> > > will be able run with a single zone.
> > 
> > What is "such a range alloc mechanism"?
> 
> As I mentioned above: A function that allows an allocation to specify 
> which physical memory ranges are permitted.
> 
> > So please stop telling me what a wonderful world it is to not have multiple
> > zones.  It just isn't going to happen for a long long time.  The
> > multiple-zone kernel is the case we need to care about most by a very large
> > margin indeed.  Single-zone is an infinitesimal corner-case.
> 
> We can still reduce the number of zones for those that require highmem to 
> two which may allows us to avoid ZONE_DMA/DMA32 issues  and allow dma 
> devices to avoid bunce buffers that can do I/O to memory ranges not 
> compatible with the current boundaries of DMA/DMA32. And I am also 
> repeating myself.

This sounds like it could help ARM where we have some weird DMA areas.

What will help even more is if the block layer can also be persuaded that
a device dma mask is precisely that - a mask - and not a set of leading
ones followed by a set of zeros, then we could eliminate the really ugly
dmabounce code.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
