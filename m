Date: Sat, 28 May 2005 09:53:27 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/15] PTI: clean page table interface
Message-ID: <20050528085327.GA19047@infradead.org>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050521024331.GA6984@cse.unsw.EDU.AU>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 21, 2005 at 12:43:31PM +1000, Paul Davies wrote:
> Here are a set of 15 patches against 2.6.12-rc4 to provide a clean
> page table interface so that alternate page tables can be fitted
> to Linux in the future.  This patch set is produced on behalf of
> the Gelato research group at the University of New South Wales.
> 
> LMbench results are included at the end of this patch set.  The
> results are very good although the mmap latency figures were
> slightly higher than expected.
> 
> I look forward to any feedback that will assist me in putting
> together a page table interface that will benefit the whole linux
> community. 

I've not looked over it a lot, but your code organization is a bit odd
and non-standard:

 - generic implementations for per-arch abstractions go into asm-generic
   and every asm-foo/ header that wants to use it includes it.  In your
   case that would be an asm-generic/page_table.h for the generic 3level
   page tables.  Please avoid #includes for generic implementations from
   architecture-independent headers guarded by CONFIG_ symbols.
 - I don't think the subdirectory under mm/ makes sense.  Just call the
   file mm/3level-page-table.c or something.
 - similar please avoid the include/mm directory.  It might or might not
   make sense to have a subdirectory for mm headers, but please don't
   start one as part of a large patch series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
