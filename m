Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3DJpN21030426
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 15:51:23 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3DJpGJJ235704
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 15:51:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3DJpFrm011255
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 15:51:16 -0400
Subject: Re: [RFD hugetlbfs] strict accounting and wasteful reservations
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20060413191801.GA9195@localhost.localdomain>
References: <1144949802.10795.99.camel@localhost.localdomain>
	 <20060413191801.GA9195@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 13 Apr 2006 14:51:12 -0500
Message-Id: <1144957873.10795.110.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: akpm@osdl.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-04-13 at 20:18 +0100, 'David Gibson' wrote:
> On Thu, Apr 13, 2006 at 12:36:42PM -0500, Adam Litke wrote:
> > Sorry to bring this up after the strict accounting patch was merged but
> > things moved along a bit too fast for me to intervene.
> > 
> > In the thread beginning at http://lkml.org/lkml/2006/3/8/47 , a
> > discussion was had to compare the patch from David Gibson (the patch
> > that was ultimately merged) with an alternative patch from Ken Chen.
> > The main functional difference is how we handle arbitrary file offsets
> > into a hugetlb file.  The current patch reserves enough huge pages to
> > populate the whole file up to the highest file offset in use.  Ken's
> > patch supported arbitrary blocks.
> > 
> > For libhugetlbfs, we would like to have sparsely populated hugetlb files
> > without wasting all the extra huge pages that the current implementation
> > requires.  That aside, having yet another difference in behavior for
> > hugetlbfs files (that isn't necessary) seems like a bad idea.
> 
> We would?  Why?

We are thinking about switching the implementation of the ELF segment
remapping code to store all of the remapped segments in one hugetlbfs
file.  That way we have one hugetlb file per executable.  This makes
managing the segments much easier, especially when doing things like
global sharing.  When doing this, we'd like the file offset to
correspond to the virtual address of the mapped segment.  So I admit
that altering the kernel behavior helps libhugetlbfs, but I think my
second justification above is even more important.  I like removing
anomalies from hugetlbfs whenever possible.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
