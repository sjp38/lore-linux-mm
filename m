Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 299D56006A9
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:41:05 -0400 (EDT)
Date: Mon, 19 Jul 2010 15:40:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
	writeback
Message-ID: <20100719144046.GR13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-8-git-send-email-mel@csn.ul.ie> <20100719142145.GD12510@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100719142145.GD12510@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 10:21:45AM -0400, Christoph Hellwig wrote:
> On Mon, Jul 19, 2010 at 02:11:29PM +0100, Mel Gorman wrote:
> > From: Wu Fengguang <fengguang.wu@intel.com>
> > 
> > A background flush work may run for ever. So it's reasonable for it to
> > mimic the kupdate behavior of syncing old/expired inodes first.
> > 
> > This behavior also makes sense from the perspective of page reclaim.
> > File pages are added to the inactive list and promoted if referenced
> > after one recycling. If not referenced, it's very easy for pages to be
> > cleaned from reclaim context which is inefficient in terms of IO. If
> > background flush is cleaning pages, it's best it cleans old pages to
> > help minimise IO from reclaim.
> 
> Yes, we absolutely do this. 

Do you mean we absolutely want to do this?

> Wu, do you have an improved version of the
> pending or should we put it in this version for now?
> 

Some insight on how the other writeback changes that are being floated
around might affect the number of dirty pages reclaim encounters would also
be helpful. The tracepoints are there for people to figure it out but any
help figuring it out is useful.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
