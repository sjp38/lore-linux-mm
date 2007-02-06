Date: Tue, 6 Feb 2007 09:55:09 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC/PATCH] prepare_unmapped_area
Message-ID: <20070206095509.GA8714@infradead.org>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net> <1170736938.2620.213.camel@localhost.localdomain> <20070206044516.GA16647@wotan.suse.de> <1170738296.2620.220.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1170738296.2620.220.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2007 at 04:04:56PM +1100, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> On Cell, I have, for performance reasons, a need to create special
> mappings of SPEs that use a different page size as the system base page
> size _and_ as the huge page size.
> 
> Due to the way the PowerPC memory management works, however, I can only
> have one page size per "segment" of 256MB (or 1T) and thus after such a
> mapping have been created in its own segment, I need to constraint
> -other- vma's to stay out of that area.
> 
> This currently cannot be done with the existing arch hooks (because of
> MAP_FIXED). However, the hugetlbfs code already has a hack in there to
> do the exact same thing for huge pages. Thus, this patch moves that hack
> into something that can be overriden by the architectures. This approach
> was choosen as the less ugly of the uglies after discussing with Nick
> Piggin. If somebody has a better idea, I'd love to hear it.
> 
> If it doesn't shoke anybody to death, I'd like to see that in -mm (and
> possibly upstream, I don't know yet if my code using that will make
> 2.6.21 or not, but it would be nice if the list of "dependent" patches
> wasn't 3 pages long anyway :-)

Eeek, this is more than fugly.  Dave Hansen suggested to move these
checks into a file operation in response to Adam Litke's hugetlb cleanups,
and this patch shows he was right :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
