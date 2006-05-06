Message-Id: <4sur0l$vjssd@fmsmga001.fm.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 0/2][RFC] New version of shared page tables
Date: Fri, 5 May 2006 20:37:22 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <445BA6B2.4030807@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Brian Twichell' <tbrian@us.ibm.com>, Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, slpratt@us.ibm.com
List-ID: <linux-mm.kvack.org>

Brian Twichell wrote on Friday, May 05, 2006 12:26 PM
> We also measured the benefit of shared pagetables on our larger setups.  
> On our 4-way x86-64 setup with 64 GB memory, using small pages for the 
> bufferpools, shared pagetables provided a 33% increase in transaction 
> throughput.  Using hugepages for the bufferpools, shared pagetables 
> provided a 3% increase.  Performance with small pages and shared 
> pagetables was within 4% of the performance using hugepages without 
> shared pagetables.
> 
> On our ppc64 setups we used both Oracle and DB2 to evaluate the benefit 
> of shared pagetables.  When database bufferpools were in small pages, 
> shared pagetables provided an increase in database transaction 
> throughput in the range of 60-65%, while in the hugepage case the 
> improvement was up to 2.4%.


I would also like to add that I have run this set of patches on ia64 and
observed similar performance upside. We have multiple data points showing
that this feature benefits several architectures.  I'm advocating for the
upstream inclusion.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
