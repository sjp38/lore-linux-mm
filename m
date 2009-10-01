Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 898AF600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:36:33 -0400 (EDT)
Date: Thu, 1 Oct 2009 16:16:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
Message-ID: <20091001151657.GH21906@csn.ul.ie>
References: <84144f020909221154x820b287r2996480225692fad@mail.gmail.com> <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie> <alpine.DEB.1.10.0909301053550.9450@gentwo.org> <20090930220541.GA31530@csn.ul.ie> <alpine.DEB.1.10.0909301941570.11850@gentwo.org> <20091001104046.GA21906@csn.ul.ie> <alpine.DEB.1.10.0910011028380.3911@gentwo.org> <20091001150346.GD21906@csn.ul.ie> <alpine.DEB.1.10.0910011101390.3911@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0910011101390.3911@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 01, 2009 at 11:03:16AM -0400, Christoph Lameter wrote:
> On Thu, 1 Oct 2009, Mel Gorman wrote:
> 
> > True, it might have been improved more if SLUB knew what local hugepage it
> > resided within as the kernel portion of the address space is backed by huge
> > TLB entries. Note that SLQB could have an advantage here early in boot as
> > the page allocator will tend to give it back pages within a single huge TLB
> > entry. It loses the advantage when the system has been running for a very long
> > time but it might be enough to skew benchmark results on cold-booted systems.
> 
> The page allocator serves pages aligned to huge page boundaries as far as
> I can remember.

You're right, it does, particularly early in boot. It loses the advantage
when the system has been running a long time and memory is mostly full but
the same will apply to SLQB.

> You can actually use huge pages in slub if you set the max
> order to 9. So a page obtained from the page allocator is always aligned
> properly.
> 

Fair point.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
