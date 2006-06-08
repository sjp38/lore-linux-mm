From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] shared page table for hugetlb page
Date: Thu, 8 Jun 2006 09:31:13 +0200
References: <000201c68a9c$635ba700$d534030a@amr.corp.intel.com>
In-Reply-To: <000201c68a9c$635ba700$d534030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606080931.13481.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 08 June 2006 03:39, Chen, Kenneth W wrote:
> Andi Kleen wrote on Wednesday, June 07, 2006 6:25 PM
> > > @@ -18,16 +18,102 @@
> > >  #include <asm/tlb.h>
> > >  #include <asm/tlbflush.h>
> > >  
> > > +#ifdef CONFIG_X86_64
> > 
> > Why is this done for x86-64 only? 
> 
> 
> Do you mean not for i386?  I'm too chicken to do it for 32-bit PAE mode. There
> are tons of other issue that application has to fight through with highmem and
> playing with only limited 32-bit virtual address space, I thought this usage
> might be very limited for 32-bit x86.

I don't see how highmem should make any difference for shared ptes though.
The ptes can be in highmem, but you should handle this already. 

Of course highmem by itself is unpleasant, but it shouldn't affect this
particular problem much.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
