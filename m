Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2766B01DB
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 12:30:33 -0400 (EDT)
Date: Fri, 11 Jun 2010 12:30:26 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100611163026.GD24707@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100610225749.c8cc3bc3.akpm@linux-foundation.org>
 <20100611123320.GA8798@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100611123320.GA8798@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 01:33:20PM +0100, Mel Gorman wrote:
> Ok, I was under the mistaken impression that filesystems wanted to be
> given ranges of pages where possible. Considering that there has been no
> reaction to the patch in question from the filesystem people cc'd, I'll
> drop the problem for now.

Yes, we'd prefer them if possible.  Then again we'd really prefer to
get as much I/O as possible from the flusher threads, and not kswapd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
