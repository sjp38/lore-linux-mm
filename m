Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6F260072B
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 08:37:30 -0400 (EDT)
Date: Tue, 29 Jun 2010 08:37:22 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Message-ID: <20100629123722.GA725@infradead.org>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
 <1277811288-5195-15-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277811288-5195-15-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

I don't see a patch in this set which refuses writeback from the memcg
context, which we identified as having large stack footprint in hte
discussion of the last patch set.

Meanwhile I've submitted a patch to xfs to allow reclaim from kswapd,
and just prevent it from direct and memcg reclaim.

Btw, it might be worth to also allow kswap to all writeout on ext4,
but doing that will be a bit more complicated than the btrfs and xfs
variants as the code is rather convoluted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
