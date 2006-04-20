Date: Thu, 20 Apr 2006 19:33:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-ID: <20060420173334.GD21660@wotan.suse.de>
References: <20060228202202.14172.60409.sendpatchset@linux.site> <20060228202212.14172.59536.sendpatchset@linux.site> <20060420172205.GC21659@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060420172205.GC21659@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 20, 2006 at 06:22:05PM +0100, Christoph Hellwig wrote:
> On Thu, Apr 20, 2006 at 07:06:18PM +0200, Nick Piggin wrote:
> > Add a remap_vmalloc_range and get rid of as many remap_pfn_range and
> > vm_insert_page loops as possible.
> > 
> > remap_vmalloc_range can do a whole lot of nice range checking even
> > if the caller gets it wrong (which it looks like one or two do).
> 
> This looks very nice, thanks!

Thank you

> Although it might be better to split it
> into one patch to introduce remap_vmalloc_range and various patches to
> switch over one susbsyetm for merging purposes.

Sure, if anyone insists ;)

I tend to agree. I would tend to do it in just 2 patches
(1 for implementation, 1 for conversion) to make administrative
overheads smaller -- the conversions are small and very well
contained. Is there a good reason to split further?

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
