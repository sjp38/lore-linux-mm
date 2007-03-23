Date: Thu, 22 Mar 2007 23:52:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <20070322223927.bb4caf43.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Mar 2007, Andrew Morton wrote:

> On Thu, 22 Mar 2007 23:28:41 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > 1. Proven code from the IA64 arch.
> > 
> > 	The method used here has been fine tuned for years and
> > 	is NUMA aware. It is based on the knowledge that accesses
> > 	to page table pages are sparse in nature. Taking a page
> > 	off the freelists instead of allocating a zeroed pages
> > 	allows a reduction of number of cachelines touched
> > 	in addition to getting rid of the slab overhead. So
> > 	performance improves.
> 
> By how much?

About 40% on fork+exit. See 

http://marc.info/?l=linux-ia64&m=110942798406005&w=2

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
