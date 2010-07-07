Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0E5196B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 08:52:31 -0400 (EDT)
Message-ID: <4C347862.4020404@redhat.com>
Date: Wed, 07 Jul 2010 08:51:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
References: <20100702125155.69c02f85.akpm@linux-foundation.org> <20100705134949.GC13780@csn.ul.ie> <20100706093529.CCD1.A69D9226@jp.fujitsu.com> <20100706101235.GE13780@csn.ul.ie> <AANLkTin8FotAC1GvjuoYU9XA2eiSr6FWWh6bwypTdhq3@mail.gmail.com> <20100706152539.GG13780@csn.ul.ie> <20100706202758.GC18210@cmpxchg.org> <AANLkTimOkI95ZkJecE3jxRDDGbHvP9tRUluIoJuhqqMz@mail.gmail.com> <20100707002458.GI13780@csn.ul.ie> <20100707011533.GB3630@infradead.org> <20100707094310.GJ13780@csn.ul.ie>
In-Reply-To: <20100707094310.GJ13780@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 07/07/2010 05:43 AM, Mel Gorman wrote:

> How do you suggest tuning this? The modification I tried was "if N dirty
> pages are found during a SWAP_CLUSTER_MAX scan of pages, assume an average
> dirtying density of at least that during the time those pages were inserted on
> the LRU. In response, ask the flushers to flush 1.5X". This roughly responds
> to the conditions it finds as they are encountered and is based on scanning
> rates instead of time. It seemed like a reasonable option.

Your idea sounds like something we need to have, regardless
of whether or not we fix the flusher to flush older inodes
first (we probably should do that, too).

I believe this for the simple reason that we could have too
many dirty pages in one memory zone, while the flusher's
dirty threshold is system wide.

If we both fix the flusher to flush old inodes first and
kick the flusher from the reclaim code, we should be
golden.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
