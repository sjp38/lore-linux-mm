Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BBB766B005A
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 04:04:48 -0500 (EST)
Date: Tue, 3 Mar 2009 10:04:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
Message-ID: <20090303090442.GA17042@wotan.suse.de>
References: <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr> <20090302112122.GC21145@csn.ul.ie> <20090302113936.GJ1257@wotan.suse.de> <20090302121632.GA14217@csn.ul.ie> <20090303044239.GC3973@wotan.suse.de> <20090303082511.GA2809@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303082511.GA2809@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 08:25:12AM +0000, Mel Gorman wrote:
> On Tue, Mar 03, 2009 at 05:42:40AM +0100, Nick Piggin wrote:
> > or if some change resulted in more cross-cpu operations then it
> > could result in worse cache efficiency.
> > 
> 
> It occured to me before sleeping last night that there could be a lot
> of cross-cpu operations taking place in the buddy allocator itself. When
> bulk-freeing pages, we have to examine all the buddies and merge them. In
> the case of a freshly booted system, many of the pages of interest will be
> within the same MAX_ORDER blocks. If multiple CPUs bulk free their pages,
> they'll bounce the struct pages between each other a lot as we are writing
> those cache lines. However, this would be incurring with or without my patches.

Oh yes it would definitely be a factor I think.

 
> > OK, but the dynamic behaviour too. Free page A, free page B, allocate page
> > A allocate page B etc.
> > 
> > The hot/cold removal would be an obvious example of what I mean, although
> > that wasn't included in this recent patchset anyway.
> > 
> 
> I get your point though, I'll keep it in mind. I've gone from plain
> "reduce the clock cycles" to "reduce the cache misses" as if OLTP is
> sensitive to this it has to be addressed as well.

OK cool. The patchset did look pretty good for reducing clock cycles
though, so hopefully it turns out to be something simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
