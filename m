Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC2A6B01B9
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 08:52:03 -0400 (EDT)
Date: Tue, 29 Jun 2010 13:51:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Message-ID: <20100629125143.GB31561@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie> <1277811288-5195-15-git-send-email-mel@csn.ul.ie> <20100629123722.GA725@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100629123722.GA725@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 29, 2010 at 08:37:22AM -0400, Christoph Hellwig wrote:
> I don't see a patch in this set which refuses writeback from the memcg
> context, which we identified as having large stack footprint in hte
> discussion of the last patch set.
> 

It wasn't clear to me what the right approach was there and should
have noted that in the intro. The last note I have on it is this message
http://kerneltrap.org/mailarchive/linux-kernel/2010/6/17/4584087 which might
avoid the deep stack usage but I wasn't 100% sure. As kswapd doesn't clean
pages for memcg, I left memcg being able to direct writeback to see what
the memcg people preferred.

> Meanwhile I've submitted a patch to xfs to allow reclaim from kswapd,
> and just prevent it from direct and memcg reclaim.
> 

Good stuff.

> Btw, it might be worth to also allow kswap to all writeout on ext4,
> but doing that will be a bit more complicated than the btrfs and xfs
> variants as the code is rather convoluted.
> 

Fully agreed. I looked into it and got caught in its twisty web so
postponed it until this much can be finalised, agreed upon or rejected -
all pre-requisities to making the ext4 work worthwhile.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
