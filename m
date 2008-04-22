Date: Tue, 22 Apr 2008 08:45:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 01/17] hugetlb: modular state
Message-ID: <20080422064516.GA23770@wotan.suse.de>
References: <20080410170232.015351000@nick.local0.net> <20080410171100.425293000@nick.local0.net> <1208811084.11866.10.camel@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1208811084.11866.10.camel@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 21, 2008 at 03:51:24PM -0500, Jon Tollefson wrote:
> 
> On Fri, 2008-04-11 at 03:02 +1000, npiggin@suse.de wrote:
> 
> <snip>
> 
> > Index: linux-2.6/include/linux/hugetlb.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/hugetlb.h
> > +++ linux-2.6/include/linux/hugetlb.h
> > @@ -40,7 +40,7 @@ extern int sysctl_hugetlb_shm_group;
> > 
> >  /* arch callbacks */
> > 
> > -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
> > +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz);
> 
> <snip>
> 
> The sz here needs to be a long to handle sizes such as 16G on powerpc.
> 
> There are other places in hugetlb.c where the size also needs to be a
> long, but this one affects the arch code too since it is public.

Thanks, I've fixed that and found (hopefully) the rest of the ones
in the hugetlb.c code.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
