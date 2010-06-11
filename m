Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA5E6B01AD
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:17:45 -0400 (EDT)
Date: Fri, 11 Jun 2010 19:17:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100611181724.GC9946@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100610225749.c8cc3bc3.akpm@linux-foundation.org> <20100611123320.GA8798@csn.ul.ie> <20100611163026.GD24707@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100611163026.GD24707@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 12:30:26PM -0400, Christoph Hellwig wrote:
> On Fri, Jun 11, 2010 at 01:33:20PM +0100, Mel Gorman wrote:
> > Ok, I was under the mistaken impression that filesystems wanted to be
> > given ranges of pages where possible. Considering that there has been no
> > reaction to the patch in question from the filesystem people cc'd, I'll
> > drop the problem for now.
> 
> Yes, we'd prefer them if possible.  Then again we'd really prefer to
> get as much I/O as possible from the flusher threads, and not kswapd.
> 

Ok, for the moment I'll put it on the maybe pile and drop it from the
series. We can revisit if a use is found for it and we're happy that
there wasn't some other bug leaving dirty pages on the LRU for too long.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
