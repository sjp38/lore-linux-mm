Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 760A86B01D7
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 12:27:56 -0400 (EDT)
Date: Fri, 11 Jun 2010 12:27:51 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/6] vmscan: Write out ranges of pages contiguous to the
 inode where possible
Message-ID: <20100611162751.GB24707@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <1275987745-21708-6-git-send-email-mel@csn.ul.ie>
 <20100610231045.7fcd6f9d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100610231045.7fcd6f9d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 10, 2010 at 11:10:45PM -0700, Andrew Morton wrote:
> I did this, umm ~8 years ago and ended up reverting it because it was
> complex and didn't seem to buy us anything.  Of course, that was before
> we broke the VM and started writing out lots of LRU pages.  That code
> was better than your code - it grabbed the address_space and did
> writearound around the target page.

> Or don't take a look - we shouldn't need to do any of this anyway.

Doing nearly 100% of the writepage from the flusher threads would
also be preferable from the filesystem point of view - getting I/O
from one thread helps to make it more local and work around all the
stupid I/O controller logic that tries to make our life difficult.

Of course getting rid of ->writepage from the AOPs API one day would
also be nice to simplify the filesystems code, but it's not that
important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
