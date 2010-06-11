Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AEE866B01AD
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 13:49:10 -0400 (EDT)
Date: Fri, 11 Jun 2010 13:49:00 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/6] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100611174900.GA32761@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <1275987745-21708-7-git-send-email-mel@csn.ul.ie>
 <20100610231706.1d7528f2.akpm@linux-foundation.org>
 <20100611162523.GA24707@infradead.org>
 <20100611104331.d8463580.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100611104331.d8463580.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 10:43:31AM -0700, Andrew Morton wrote:
> Of course, but making a change like that in the current VM will cause a
> large number of dirty pages to get refiled, so the impact of this
> change on some workloads could be quite bad.

Note that ext4, btrfs and xfs all error out on ->writepage from reclaim
context.  That is both kswapd and direct reclaim because there is no way
to distinguish between the two.  Things seem to work fine with these
filesystems, so the issue can't be _that_ bad.  Of course reducing this
to just error out from direct reclaim, and fixing them VM to better
cope with it is even better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
