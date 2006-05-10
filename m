Message-Id: <4t16i2$10ctb8@orsmga001.jf.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 0/2][RFC] New version of shared page tables
Date: Tue, 9 May 2006 19:07:43 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <44600F9B.1060207@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Brian Twichell <tbrian@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote on Monday, May 08, 2006 8:42 PM
> Brian Twichell wrote:
> > In the case of x86-64, if pagetable sharing for small pages was 
> > eliminated, we'd lose more than the 27-33% throughput improvement 
> > observed when the bufferpools are in small pages.  We'd also lose a 
> > significant chunk of the 3% improvement observed when the bufferpools 
> > are in hugepages.  This occurs because there is still small page 
> > pagetable sharing being achieved, minimally for database text, when 
> > the bufferpools are in hugepages.  The performance counters indicated 
> > that ITLB and DTLB page walks were reduced by 28% and 10%, 
> > respectively, in the x86-64/hugepage case.
> 
> 
> Aside, can you just enlighten me as to how TLB misses are improved on 
> x86-64? As far as I knew, it doesn't have ASIDs so I wouldn't have thought
> it could share TLBs anyway...
> But I'm not up to scratch with modern implementations.


Allow me to jump in if I may:  The number of TLB misses did not change that
much (both i-side and d-side and is expected).  What changed is the penalty
of TLB misses are reduced: i.e., number of page table walk performed by the
hardware are reduced. This is due to specialized buffering of information
that reduces the need to perform page walks. With page table sharing, the
overall size of page tables are reduced, in turn, it has a better hit rate
on the buffered items and it helps to mitigate page walks upon a TLB miss.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
