Date: Fri, 21 Dec 2007 11:20:52 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221102052.GB28484@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476B9000.2090707@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 21, 2007 at 11:05:52AM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> >So then you're back to needing struct pages again. Do you allocate
> >them at hotplug time?
> They get allocated by cathing kernel page faults when accessing the 
> mem_map array and filling in pages on demand. This happens at hotplug 
> time, where we initialize the content of struct page.

Yep OK.


> >AFAIK, sparsemem keeps track of all sections for pfn_valid(), which would
> >work. Any plans to convert s390 to it? ;)
> I think vmem_map is superior to sparsemem, because a 
> single-dimensional mem_map array is faster work with (single step 
> lookup). And we've got plenty of virtual address space for the 
> vmem_map array on 64bit.

But it doesn't still retain sparsemem sections behind that? Ie. so that
pfn_valid could be used? (I admittedly don't know enough eabout the memory
model code).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
