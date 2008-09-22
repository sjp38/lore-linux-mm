Date: Mon, 22 Sep 2008 17:21:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080922162152.GB7716@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie> <1222047492-27622-2-git-send-email-mel@csn.ul.ie> <1222098955.8533.50.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1222098955.8533.50.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (22/09/08 08:55), Dave Hansen didst pronounce:
> On Mon, 2008-09-22 at 02:38 +0100, Mel Gorman wrote:
> > It is useful to verify that a hugepage-aware application is using the expected
> > pagesizes in each of its memory regions. This patch reports the pagesize
> > backing the VMA in /proc/pid/smaps. This should not break any sensible
> > parser as the file format is multi-line and it should skip information it
> > does not recognise.
> 
> Time to play devil's advocate. :)
> 
> To be fair, this doesn't return the MMU pagesize backing the VMA.  It
> returns pagesize that hugetlb reports *or* the kernel's base PAGE_SIZE.
> 

True. In the vast majority of cases, this is the MMU size with ppc64 on
pro

> The ppc64 case where we have a 64k PAGE_SIZE, but no hardware 64k
> support means that we'll have a 4k MMU pagesize that we're pretending is
> a 64k MMU page.  That might confuse someone seeing 16x the number of TLB
> misses they expect.

The corollary is that someone running with a 64K base page kernel may be
surprised that the pagesize is always 4K. However I'll check if there is
a simple way of checking out if the MMU size differs from PAGE_SIZE.

> This also doesn't work if, in the future, we get multiple page sizes
> mapped under one VMA.  But, I guess that all only matters if you worry
> about how the kernel is treating the pages vs. the MMU hardware.
> 

Will deal with that problem if and when we encounter it. It may be a
case that VMAs split or that we could report how many pages of each MMU
size are in that VMA.

Thanks


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
