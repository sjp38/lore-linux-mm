Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 27DC46B01D5
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 12:25:34 -0400 (EDT)
Date: Fri, 11 Jun 2010 12:25:23 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/6] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100611162523.GA24707@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <1275987745-21708-7-git-send-email-mel@csn.ul.ie>
 <20100610231706.1d7528f2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100610231706.1d7528f2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 10, 2010 at 11:17:06PM -0700, Andrew Morton wrote:
> As it stands, it would be wildly incautious to make a change like
> this without first working out why we're pulling so many dirty pages
> off the LRU tail, and fixing that.

Note that unlike the writepage vs writepages from kswapd which can
be fixed by the right tuning this is a black or white issue.  Writeback
from direct reclaim will kill your stack if the caller happens to be
the wrong one, and just making it happen less often is not a fix - it
must not happen at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
