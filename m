Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SIHw7P013323
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:17:58 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SIFY1a152708
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:15:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SIFX8O028530
	for <linux-mm@kvack.org>; Wed, 28 May 2008 14:15:34 -0400
Subject: Re: [PATCH 3/3] Guarantee that COW faults for a process that
	called mmap(MAP_PRIVATE) on hugetlbfs will succeed
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080528160024.GA19349@csn.ul.ie>
References: <20080527185028.16194.57978.sendpatchset@skynet.skynet.ie>
	 <20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
	 <20080528160024.GA19349@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 28 May 2008 13:15:34 -0500
Message-Id: <1211998534.12036.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, apw@shadowen.org, linux-mm@kvack.org, andi@firstfloor.org, kenchen@google.com, abh@cray.com, hannes@saeurebad.de
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-28 at 17:00 +0100, Mel Gorman wrote:
> [PATCH 4/3] Fix prio tree lookup
> 
> I spoke too soon. This is a fix to patch 3/3.
> 
> If a child unmaps the start of the VMA, the start address is different and
> that is perfectly legimite making the BUG_ON check bogus and should be removed.
> While page cache lookups are in HPAGE_SIZE, the vma->vm_pgoff is in PAGE_SIZE
> units, not HPAGE_SIZE. The offset calculation needs to be in PAGE_SIZE units
> to find other VMAs that are mapping the same range of pages. This patch
> fixes the offset calculation and adds an explanation comment as to why it
> is different from a page cache lookup.
> 
> Credit goes to Johannes Weiner for spotting the bogus BUG_ON on IRC which
> led to the discovery of the faulty offset calculation.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
