Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CAE296006F7
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:07:16 -0400 (EDT)
Date: Wed, 30 Jun 2010 09:05:04 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 13/14] fs,btrfs: Allow kswapd to writeback pages
Message-ID: <20100630130504.GT1993@think>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
 <1277811288-5195-14-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277811288-5195-14-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 29, 2010 at 12:34:47PM +0100, Mel Gorman wrote:
> As only kswapd and memcg are writing back pages, there should be no
> danger of overflowing the stack. Allow the writing back of dirty pages
> in btrfs from the VM.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Signed-off-by: Chris Mason <chris.mason@oracle.com>

But, this is only the metadata writepage.  fs/btrfs/inode.c has another
one for data pages.  (just look for PF_MEMALLOC).

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
