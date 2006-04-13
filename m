Date: Thu, 13 Apr 2006 21:01:43 +0100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFD hugetlbfs] strict accounting and wasteful reservations
Message-ID: <20060413200143.GA13729@localhost.localdomain>
References: <1144949802.10795.99.camel@localhost.localdomain> <20060413191801.GA9195@localhost.localdomain> <1144957873.10795.110.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1144957873.10795.110.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 13, 2006 at 02:51:12PM -0500, Adam Litke wrote:
> On Thu, 2006-04-13 at 20:18 +0100, 'David Gibson' wrote:
> > On Thu, Apr 13, 2006 at 12:36:42PM -0500, Adam Litke wrote:
> > > Sorry to bring this up after the strict accounting patch was merged but
> > > things moved along a bit too fast for me to intervene.
> > > 
> > > In the thread beginning at http://lkml.org/lkml/2006/3/8/47 , a
> > > discussion was had to compare the patch from David Gibson (the patch
> > > that was ultimately merged) with an alternative patch from Ken Chen.
> > > The main functional difference is how we handle arbitrary file offsets
> > > into a hugetlb file.  The current patch reserves enough huge pages to
> > > populate the whole file up to the highest file offset in use.  Ken's
> > > patch supported arbitrary blocks.
> > > 
> > > For libhugetlbfs, we would like to have sparsely populated hugetlb files
> > > without wasting all the extra huge pages that the current implementation
> > > requires.  That aside, having yet another difference in behavior for
> > > hugetlbfs files (that isn't necessary) seems like a bad idea.
> > 
> > We would?  Why?
> 
> We are thinking about switching the implementation of the ELF segment
> remapping code to store all of the remapped segments in one hugetlbfs
> file.  That way we have one hugetlb file per executable.  This makes
> managing the segments much easier, especially when doing things like
> global sharing.  When doing this, we'd like the file offset to
> correspond to the virtual address of the mapped segment.  So I admit
> that altering the kernel behavior helps libhugetlbfs, but I think my
> second justification above is even more important.  I like removing
> anomalies from hugetlbfs whenever possible.

Hrm... I'm not entirely convinced attempting to directly map vaddr to
file offset is a good idea.  But give it a shot, I guess.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
