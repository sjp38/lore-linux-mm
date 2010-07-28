Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5097A6B02B4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 07:08:34 -0400 (EDT)
Date: Wed, 28 Jul 2010 07:08:07 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 9/9] writeback: Prioritise dirty inodes encountered by
 reclaim for background flushing
Message-ID: <20100728110807.GB31360@infradead.org>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
 <1280312843-11789-10-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1280312843-11789-10-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 11:27:23AM +0100, Mel Gorman wrote:
> It is preferable that as few dirty pages are dispatched for cleaning from
> the page reclaim path. When dirty pages are encountered by page reclaim,
> this patch marks the inodes that they should be dispatched immediately. When
> the background flusher runs, it moves such inodes immediately to the dispatch
> queue regardless of inode age.

Thus whole thing looks rather hacky to me.  Does it really give a large
enough benefit to be worth all the hacks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
