Message-Id: <4t16i2$tp1jo@orsmga001.jf.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: RFC: RCU protected page table walking
Date: Wed, 3 May 2006 19:51:36 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.64.0605031649400.32117@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andi Kleen <ak@suse.de>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr, linux-i64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote on Wednesday, May 03, 2006 4:54 PM
> On Wed, 3 May 2006, Hugh Dickins wrote:
> > Those architectures (including i386 and x86_64) which #define their
> > __pte_free_tlb etc. to tlb_remove_page are safe as is.  But Zoltan's
> > ia64 #defines it to pte_free, which looks like it may free_page before
> > the TLB flush.  But it is surprising if it has actually been unsafe
> 
> Sorry but I am in .au right now with spotty high latency connectivity. 
> But the people on linux-ia64 should know. Ken?

A while back ia64 reinstated per-cpu pgtable quicklist, which bypasses tlb_gather/tlb_finish_mmu for page table pages. It should be
safe AFAICT
because TLB for user address and vhpt are already flushed by the time
pte_free_tlb() is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
