Date: Fri, 21 Dec 2007 11:47:01 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221104701.GE28484@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476B96D6.2010302@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 21, 2007 at 11:35:02AM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> >>>AFAIK, sparsemem keeps track of all sections for pfn_valid(), which would
> >>>work. Any plans to convert s390 to it? ;)
> >>I think vmem_map is superior to sparsemem, because a 
> >>single-dimensional mem_map array is faster work with (single step 
> >>lookup). And we've got plenty of virtual address space for the 
> >>vmem_map array on 64bit.
> >
> >But it doesn't still retain sparsemem sections behind that? Ie. so that
> >pfn_valid could be used? (I admittedly don't know enough eabout the memory
> >model code).
> Not as far as I know. But arch/s390/mm/vmem.c has:
> 
> struct memory_segment {
>         struct list_head list;
>         unsigned long start;
>         unsigned long size;
> };
> 
> static LIST_HEAD(mem_segs);
> 
> This is maintained every time we map a segment/unmap a segment. And we 
> could add a bit to struct memory_segment meaning "refcount this one". 
> This way, we could tell core mm whether or not a pfn should be refcounted.

Right, this should work.

BTW. having a per-arch function sounds reasonable for a start. I'd just give
it a long name, so that people don't start using it for weird things ;)
mixedmap_refcount_pfn() or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
