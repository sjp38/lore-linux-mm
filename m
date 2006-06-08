From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] shared page table for hugetlb page
Date: Wed, 7 Jun 2006 18:39:31 -0700
Message-ID: <000201c68a9c$635ba700$d534030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <200606080325.19994.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andi Kleen' <ak@suse.de>
Cc: Dave McCracken <dmccr@us.ibm.com>, 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote on Wednesday, June 07, 2006 6:25 PM
> > @@ -18,16 +18,102 @@
> >  #include <asm/tlb.h>
> >  #include <asm/tlbflush.h>
> >  
> > +#ifdef CONFIG_X86_64
> 
> Why is this done for x86-64 only? 


Do you mean not for i386?  I'm too chicken to do it for 32-bit PAE mode. There
are tons of other issue that application has to fight through with highmem and
playing with only limited 32-bit virtual address space, I thought this usage
might be very limited for 32-bit x86.

If you meant patch doesn't include ppc/sparc/ia64, it will be added soon.


> >  pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> >  {
> > +	/*
> > +	 * to be fixed: pass me the darn vma pointer.
> > +	 */
> 
> Just fix it?

OK.


> Overall it looks nice&clean though.

Thanks for reviewing and your warm comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
