Date: Wed, 3 May 2006 19:00:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: RFC: RCU protected page table walking
In-Reply-To: <200605031846.51657.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com>
References: <4458CCDC.5060607@bull.net> <200605031846.51657.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2006, Andi Kleen wrote:
> 
> The page is not freed until all CPUs who had the mm mapped are flushed.
> See mmu_gather in asm-generic/tlb.h
> 
> > Even if this security window is small, it does exist.
> 
> It doesn't at least on architectures that use the generic tlbflush.h

Those architectures (including i386 and x86_64) which #define their
__pte_free_tlb etc. to tlb_remove_page are safe as is.  But Zoltan's
ia64 #defines it to pte_free, which looks like it may free_page before
the TLB flush.  But it is surprising if it has actually been unsafe
there on ia64 - perhaps Christoph can explain how it is safe?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
