Date: Tue, 23 Sep 2008 20:46:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080923194655.GA25542@csn.ul.ie>
References: <20080922162152.GB7716@csn.ul.ie> <1222102098.8533.62.camel@nimitz> <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (23/09/08 21:15), KOSAKI Motohiro didst pronounce:
> > > The corollary is that someone running with a 64K base page kernel may be
> > > surprised that the pagesize is always 4K. However I'll check if there is
> > > a simple way of checking out if the MMU size differs from PAGE_SIZE.
> > 
> > Sure.  If it isn't easy, the best thing to do is probably just to
> > document the "interesting" behavior.
> 
> Dave, please let me know getpagesize() function return to 4k or 64k on ppc64.
> I think the PageSize line of the /proc/pid/smap and getpagesize() result should be matched.
> 
> otherwise, enduser may be confused.
> 

To distinguish between the two, I now report the kernel pagesize and the
mmu pagesize like so

KernelPageSize:       64 kB
MMUPageSize:           4 kB

This is running a kernel with a 64K base pagesize on a PPC970MP which
does not support 64K hardware pagesizes.

Does this make sense?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
