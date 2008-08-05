Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m75HrSPw000512
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 13:53:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m75HrRZS207804
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 13:53:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m75HrRJp012734
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 13:53:27 -0400
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080805162800.GJ20243@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	 <20080730014308.2a447e71.akpm@linux-foundation.org>
	 <20080730172317.GA14138@csn.ul.ie>
	 <20080730103407.b110afc2.akpm@linux-foundation.org>
	 <20080730193010.GB14138@csn.ul.ie>
	 <20080730130709.eb541475.akpm@linux-foundation.org>
	 <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz>
	 <20080805111147.GD20243@csn.ul.ie> <1217952748.10907.18.camel@nimitz>
	 <20080805162800.GJ20243@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 05 Aug 2008 10:53:25 -0700
Message-Id: <1217958805.10907.45.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-05 at 17:28 +0100, Mel Gorman wrote:
> Ok sure, you could do direct inserts for MAP_PRIVATE as conceptually it
> suits this patch.  However, I don't see what you gain. By reusing hugetlbfs,
> we get things like proper reservations which we can do for MAP_PRIVATE these
> days. Again, we could call that sort of thing directly if the reservation
> layer was split out separate from hugetlbfs but I still don't see the gain
> for all that churn.
> 
> What am I missing?

This is good for getting us incremental functionality.  It is probably
the smallest amount of code to get it functional.

My concern is that we're going down a path that all large page usage
should be through the one and only filesystem.  Once we establish that
dependency, it is going to be awfully hard to undo it; just think of all
of the inherent behavior in hugetlbfs.  So, we better be sure that the
filesystem really is the way to go, especially if we're going to start
having other areas of the kernel depend on it internally.

That said, this particular patch doesn't appear *too* bound to hugetlb
itself.  But, some of its limitations *do* come from the filesystem,
like its inability to handle VM_GROWS...  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
