Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F3BEA6B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 06:08:44 -0400 (EDT)
Date: Sat, 15 Aug 2009 11:08:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
Message-ID: <20090815100843.GA20361@csn.ul.ie>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain> <20090729181205.23716.25002.sendpatchset@localhost.localdomain> <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com> <20090731103632.GB28766@csn.ul.ie> <1249067452.4674.235.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 03:38:43PM -0700, David Rientjes wrote:
> On Fri, 31 Jul 2009, Lee Schermerhorn wrote:
> 
> > PATCH/RFC 5/4 hugetlb:  register per node hugepages attributes
> > 
> > Against: 2.6.31-rc4-mmotm-090730-0510
> > and the hugetlb rework and mempolicy-based nodes_allowed
> > series
> > 
> 
> Andrew, Lee, what's the status of this patchset?  I don't see it, or the 
> mempolicy support version, in mmotm-2009-08-12-13-55.
> 

Lee went on holidays and I dropped the ball somewhat in that I didn't review
the combined set he posted just before he left. As the two approaches are
not mutually exclusive, my expectation was that at at least one more patchset
would be posted combining both approaches before merging to -mm.

> I think there are use cases for both the per-node hstate attributes and 
> the mempolicy restricted hugepage allocation support and both features can 
> co-exist in the kernel.
> 

Agreed.

> My particular interest is in the per-node hstate attributes because it 
> allows job schedulers to preallocate hugepages in nodes attached to a 
> cpuset with ease and allows node-targeted hugepage freeing for balanced 
> allocations, which is a prerequisite for effective interleave 
> optimizations.
> 
> I'd encourage the addition of the per-node hstate attributes to mmotm.  
> Thanks Lee for implementing this feature.
> 

I'd like to see at least one patchset without the RFCs attached and have
one more read-through before it's merged.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
