Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15E036B0055
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:26:14 -0400 (EDT)
Date: Fri, 20 Mar 2009 16:27:16 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
Message-ID: <20090320162716.GP24586@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201059240.3740@qirst.com> <20090320153723.GO24586@csn.ul.ie> <alpine.DEB.1.10.0903201205260.18010@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903201205260.18010@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 12:07:22PM -0400, Christoph Lameter wrote:
> On Fri, 20 Mar 2009, Mel Gorman wrote:
> 
> > good idea one way or the other. Course, this meant a search of the PCP
> > lists or increasing the size of the PCP structure - swings and
> > roundabouts :/
> 
> The PCP list structure irks me a bit. Manipulating doubly linked lists
> means touching at least 3 cachelines.

Yeah, and bloats the structure quite a bit. It's what hits the
one-list-per-migratetype the hardest.

> Is it possible to go to a simple
> linked list (one cacheline to be touched)?

I considered it but it breaks the hot/cold allocation/freeing logic and
the search code became weird enough looking fast enough that I dropped
it.

> Or an array of pointers to
> pages instead (one cacheline may contian multiple pointers to pcp pages
> which means multiple pages could be handled with a single cacheline)?
> 

An array of pointers is promising but it would bloat the structure quiet a
bit too.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
