Date: Wed, 23 Apr 2008 17:38:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 04/18] hugetlb: modular state
Message-ID: <20080423153832.GD16769@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.054070000@nick.local0.net> <1208964098.16652.13.camel@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1208964098.16652.13.camel@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 10:21:38AM -0500, Jon Tollefson wrote:
> 
> On Wed, 2008-04-23 at 11:53 +1000, npiggin@suse.de wrote:
> 
> <snip>
> 
> > Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
> > ===================================================================
> > --- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
> > +++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
> > @@ -128,7 +128,7 @@ pte_t *huge_pte_offset(struct mm_struct 
> >  	return NULL;
> >  }
> > 
> > -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> > +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)
> 
> The sz has to be an unsigned long to match the definition in the header.
> The same is true for the other architectures too.

Ah, sorry I forgot to do an arch sweep after the change :P

Thanks for picking that up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
