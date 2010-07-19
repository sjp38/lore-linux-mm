Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 22E926006A9
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:43:32 -0400 (EDT)
Date: Mon, 19 Jul 2010 15:43:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/8] fs,xfs: Allow kswapd to writeback pages
Message-ID: <20100719144311.GS13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-7-git-send-email-mel@csn.ul.ie> <20100719142051.GC12510@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100719142051.GC12510@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 10:20:51AM -0400, Christoph Hellwig wrote:
> On Mon, Jul 19, 2010 at 02:11:28PM +0100, Mel Gorman wrote:
> > As only kswapd and memcg are writing back pages, there should be no
> > danger of overflowing the stack. Allow the writing back of dirty pages
> > in xfs from the VM.
> 
> As pointed out during the discussion on one of your previous post memcg
> does pose a huge risk of stack overflows. 

I remember. This is partially to nudge the memcg people to see where
they currently stand with alleviating the problem.

> In the XFS tree we've already
> relaxed the check to allow writeback from kswapd, and until the memcg
> situation we'll need to keep that check.
> 

If memcg remains a problem, I'll drop these two patches.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
