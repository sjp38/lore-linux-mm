Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19B9B6006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:24:55 -0400 (EDT)
Date: Mon, 19 Jul 2010 15:24:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/8] vmscan: tracing: Update trace event to track if
	page reclaim IO is for anon or file pages
Message-ID: <20100719142436.GO13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-3-git-send-email-mel@csn.ul.ie> <20100719141501.GA12510@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100719141501.GA12510@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 10:15:01AM -0400, Christoph Hellwig wrote:
> On Mon, Jul 19, 2010 at 02:11:24PM +0100, Mel Gorman wrote:
> > It is useful to distinguish between IO for anon and file pages. This
> > patch updates
> > vmscan-tracing-add-trace-event-when-a-page-is-written.patch to include
> > that information. The patches can be merged together.
> 
> I think the trace would be nicer if you #define flags for both
> cases and then use __print_flags on them.  That'll also make it more
> extensible in case we need to add more flags later.
> 

Not a bad idea, I'll check it out. Thanks. The first flags would be;

RECLAIM_WB_ANON
RECLAIM_WB_FILE

Does anyone have problems with the naming?


> And a purely procedural question:  This is supposed to get rolled into
> the original patch before it gets commited to a git tree, right?
> 

That is my expectation.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
