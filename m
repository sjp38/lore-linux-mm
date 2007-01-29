Date: Mon, 29 Jan 2007 14:45:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
In-Reply-To: <20070129143654.27fcd4a4.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0701291441260.1102@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070126030753.03529e7a.akpm@osdl.org> <Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
 <20070126114615.5aa9e213.akpm@osdl.org> <Pine.LNX.4.64.0701261147300.15394@schroedinger.engr.sgi.com>
 <20070126122747.dde74c97.akpm@osdl.org> <Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com>
 <20070129143654.27fcd4a4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Andrew Morton wrote:

> > All 64 bit machine will only have a single zone if we have such a range 
> > alloc mechanism. The 32bit ones with HIGHMEM wont be able to avoid it, 
> > true. But all arches that do not need gymnastics to access their memory 
> > will be able run with a single zone.
> 
> What is "such a range alloc mechanism"?

As I mentioned above: A function that allows an allocation to specify 
which physical memory ranges are permitted.

> So please stop telling me what a wonderful world it is to not have multiple
> zones.  It just isn't going to happen for a long long time.  The
> multiple-zone kernel is the case we need to care about most by a very large
> margin indeed.  Single-zone is an infinitesimal corner-case.

We can still reduce the number of zones for those that require highmem to 
two which may allows us to avoid ZONE_DMA/DMA32 issues  and allow dma 
devices to avoid bunce buffers that can do I/O to memory ranges not 
compatible with the current boundaries of DMA/DMA32. And I am also 
repeating myself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
