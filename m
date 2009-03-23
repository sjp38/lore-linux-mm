Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 13EF76B00D6
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 06:48:06 -0400 (EDT)
Date: Mon, 23 Mar 2009 11:52:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
Message-ID: <20090323115213.GC6484@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201059240.3740@qirst.com> <20090320153723.GO24586@csn.ul.ie> <alpine.DEB.1.10.0903201205260.18010@qirst.com> <20090320162716.GP24586@csn.ul.ie> <alpine.DEB.1.10.0903201503040.11746@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903201503040.11746@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 03:43:23PM -0400, Christoph Lameter wrote:
> On Fri, 20 Mar 2009, Mel Gorman wrote:
> 
> > > Is it possible to go to a simple
> > > linked list (one cacheline to be touched)?
> >
> > I considered it but it breaks the hot/cold allocation/freeing logic and
> > the search code became weird enough looking fast enough that I dropped
> > it.
> 
> Maybe it would be workable if we drop the cold queue stuff (dubious
> anyways)?
> 

This came up again. There was some evidence when it was introduced that
it worked and micro-benchmarks can show it to be of some use. It's
not-obvious-enough that I'd be wary of deleting it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
