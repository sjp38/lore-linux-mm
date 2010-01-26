Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD866B007D
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 15:04:02 -0500 (EST)
Date: Tue, 26 Jan 2010 20:03:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 21 of 31] split_huge_page_mm/vma
Message-ID: <20100126200347.GW16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <9cb2a8a61d32163dced8.1264513936@v2.random> <20100126173450.GE16468@csn.ul.ie> <20100126194947.GV30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100126194947.GV30452@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 08:49:47PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 05:34:51PM +0000, Mel Gorman wrote:
> > I guess this is the part that breaks huge pages when smaps is read. That
> > is a bit of a snag as a normal user could cause a lot of churn by
> > reading those files a lot.
> 
> yep, this is the highest priority split_huge_page to remove, along
> with fixing lru stats. mprotect and mremap are much lower prio. I
> think I mentioned the removal of split_huge_page from smaps in earlier
> emails too.
> 

Probably. It rings a bell for sure.

> > In the event that gets fixed up, it's worth considering what KernelPageSize:
> > and MMUPageSize: should be printing in smaps for regions of memory backed
> > by a mix of base and huge pages.
> 
> Suggestions and patches welcome. I just deferred it for later and no
> app on my system seems to cat those files but it's definitely
> something to fix or it's just spurious overhead given to khugepaged...
> 

I'd be very surprised if there are apps that cat those files because
they are expensive to read from a kernel perspective and not the
cheapest to parse either. It's intended for monitoring tools that report
on hugepage usage on a per-application basis.

Not a high priority and I'll give it some thought. Just mentioning it in
case I forgot to bring it up later.

Otherwise;

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
