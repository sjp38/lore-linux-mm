Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 05E4B6B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 08:20:43 -0400 (EDT)
Date: Fri, 23 Jul 2010 20:20:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100723122015.GA8210@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
 <20100722085210.GA26714@localhost>
 <20100722092155.GA28425@localhost>
 <20100722104823.GF13117@csn.ul.ie>
 <20100723094515.GD5043@localhost>
 <20100723105719.GE5300@csn.ul.ie>
 <20100723114915.GA5125@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723114915.GA5125@localhost>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andreas Mohr <andi@lisas.de>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> For the case of of a heavy dirtier (dd) and concurrent light dirtiers
> (some random processes), the light dirtiers won't be easily throttled.
> task_dirty_limit() handles that case well. It will give light dirtiers
> higher threshold than heavy dirtiers so that only the latter will be
> dirty throttled.

The caveat is, the real dirty throttling threshold is not exactly the
value specified by vm.dirty_ratio or vm.dirty_bytes. Instead it's some
value slightly lower than it. That real value differs for each process,
which is a nice trick to throttle heavy dirtiers first. If I remember
it right, that's invented by Peter and Andrew.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
