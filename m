Date: Fri, 27 Oct 2006 19:12:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061027190452.6ff86cae.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
 <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
 <20061026150938.bdf9d812.akpm@osdl.org> <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2006, Andrew Morton wrote:

> On Fri, 27 Oct 2006 18:00:42 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > But I cannot find any justification in my contexts to complete work on 
> > this functionality because plainly all the hardware that I use does not 
> > have problem laden DMA controllers and works just fine with a single 
> > zone.
> 
> How about memory hot-unplug?

Cannot figure out how that relates to what I said above. Memory hot unplug 
seems to have been dropped in favor of baloons.

> The only feasible way we're going to implement that is to support it on
> user allocations only.  IOW: for all those allocations which were performed
> with __GFP_HIGHMEM.

The alloc_page_range() functionality was intended for device drivers and 
other ZONE_DMA users. I am not sure what the point is of user space 
having the ability to allocate memory in specific physical memory areas. 
User space has virtual address areas that are mapped by the kernel to 
physical addresses. The physical addresses for DMA is allocated through 
alloc_dma_coherent.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
