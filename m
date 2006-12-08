Date: Thu, 7 Dec 2006 18:20:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
In-Reply-To: <4578BE37.1010109@goop.org>
Message-ID: <Pine.LNX.4.64.0612071817280.11503@schroedinger.engr.sgi.com>
References: <20061204113051.4e90b249.akpm@osdl.org>
 <Pine.LNX.4.64.0612041133020.32337@schroedinger.engr.sgi.com>
 <20061204120611.4306024e.akpm@osdl.org> <Pine.LNX.4.64.0612041211390.32337@schroedinger.engr.sgi.com>
 <20061204131959.bdeeee41.akpm@osdl.org> <Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com>
 <20061204142259.3cdda664.akpm@osdl.org> <Pine.LNX.4.64.0612050754560.11213@schroedinger.engr.sgi.com>
 <20061205112541.2a4b7414.akpm@osdl.org> <Pine.LNX.4.64.0612051159510.18687@schroedinger.engr.sgi.com>
 <20061205214721.GE20614@skynet.ie> <Pine.LNX.4.64.0612051521060.20570@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0612060903161.7238@skynet.skynet.ie>
 <Pine.LNX.4.64.0612060921230.26185@schroedinger.engr.sgi.com>
 <4578BE37.1010109@goop.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006, Jeremy Fitzhardinge wrote:

> You can also deal with memory hotplug by adding a Xen-style
> pseudo-physical vs machine address abstraction.  This doesn't help with
> making space for contiguous allocations, but it does allow you to move
> "physical" pages from one machine page to another if you want to.  The
> paravirt ops infrastructure has already appeared in -git, and I'll soon
> have patches to allow Xen's paravirtualized mmu mode to work with it,
> which is a superset of what would be required to implement movable pages
> for hotpluggable memory.
> 
> (I don't know if you actually want to consider this approach; I'm just
> pointing out that it definitely a bad idea to conflate the two problems
> of memory fragmentation and hotplug.)

The same can be done using the virtual->physical mappings that exist on 
many platforms for the kernel address space (ia64 dynamically calculates 
those, x86_64 uses a page table with 2M pages for mapping the kernel). The 
problem is that the 1-1 mapping between physical and virtual addresses 
will have to be (at least partially) sacrificed which may lead to 
complications with DMA devices.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
