Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A51C6B01AD
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 13:44:39 -0400 (EDT)
Date: Fri, 11 Jun 2010 10:43:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/6] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100611104331.d8463580.akpm@linux-foundation.org>
In-Reply-To: <20100611162523.GA24707@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
	<1275987745-21708-7-git-send-email-mel@csn.ul.ie>
	<20100610231706.1d7528f2.akpm@linux-foundation.org>
	<20100611162523.GA24707@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 12:25:23 -0400 Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 10, 2010 at 11:17:06PM -0700, Andrew Morton wrote:
> > As it stands, it would be wildly incautious to make a change like
> > this without first working out why we're pulling so many dirty pages
> > off the LRU tail, and fixing that.
> 
> Note that unlike the writepage vs writepages from kswapd which can
> be fixed by the right tuning this is a black or white issue.  Writeback
> from direct reclaim will kill your stack if the caller happens to be
> the wrong one, and just making it happen less often is not a fix - it
> must not happen at all.

Of course, but making a change like that in the current VM will cause a
large number of dirty pages to get refiled, so the impact of this
change on some workloads could be quite bad.

If, however, we can get things back to the state where few dirty pages
ever reach the tail of the LRU then the adverse impact of this change
will be much less.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
