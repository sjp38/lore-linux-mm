Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4NKWVPM005611
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:32:31 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4NKWV6T112078
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:32:31 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4NKWUv0017321
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:32:30 -0400
Date: Fri, 23 May 2008 13:32:28 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 13/18] hugetlb: support boot allocate different sizes
Message-ID: <20080523203228.GC23924@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.027712000@nick.local0.net> <20080425184041.GH9680@us.ibm.com> <20080523053641.GM13071@wotan.suse.de> <20080523060438.GC4520@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523060438.GC4520@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.05.2008 [08:04:39 +0200], Nick Piggin wrote:
> On Fri, May 23, 2008 at 07:36:41AM +0200, Nick Piggin wrote:
> > On Fri, Apr 25, 2008 at 11:40:41AM -0700, Nishanth Aravamudan wrote:
> > > 
> > > So, you made max_huge_pages an array of the same size as the hstates
> > > array, right?
> > > 
> > > So why can't we directly use h->max_huge_pagees everywhere, and *only*
> > > touch max_huge_pages in the sysctl path.
> > 
> > It's just to bring up the max_huge_pages array initially for the
> > sysctl read path. I guess the array could be built every time the
> > sysctl handler runs as another option... that might hide away a
> > bit of the ugliness into the sysctl code I suppose. I'll see how
> > it looks.
> 
> Hmm, I think we could get into problems with the issue of kernel
> parameter passing vs hstate setup, so things might get a bit fragile.
> I think it is robust at this point in time to retain the
> max_huge_pages array if the hugetlb vs arch hstate registration setup
> gets revamped, it might be something to look at, but I prefer to keep
> it rather than tinker at this point.

Sure and that's fair.

But I'm approaching it from the perspective that the multi-valued
sysctl will go away with the sysfs interface. So perhaps I'll do a
cleanup then.

Also, we will want to update the linux-mm.org wiki diagrams if we change
what states hugepages can be in and the meaning of any of them. I'm not
sure that is the case now, but it might be.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
