Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 60A206B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 23:12:26 -0400 (EDT)
Message-ID: <4C4CFCE9.8070303@redhat.com>
Date: Sun, 25 Jul 2010 23:11:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background writeback
References: <20100723094515.GD5043@localhost> <20100723105719.GE5300@csn.ul.ie> <20100725192955.40D5.A69D9226@jp.fujitsu.com> <20100726030813.GA7668@localhost>
In-Reply-To: <20100726030813.GA7668@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On 07/25/2010 11:08 PM, Wu Fengguang wrote:

> We do need some throttling under memory pressure. However stall time
> more than 1s is not acceptable. A simple congestion_wait() may be
> better, since it waits on _any_ IO completion (which will likely
> release a set of PG_reclaim pages) rather than one specific IO
> completion. This makes much smoother stall time.
> wait_on_page_writeback() shall really be the last resort.
> DEF_PRIORITY/3 means 1/16=6.25%, which is closer.

I agree with the max 1 second stall time, but 6.25% of
memory could be an awful lot of pages to scan on a system
with 1TB of memory :)

Not sure what the best approach is, just pointing out
that DEF_PRIORITY/3 may be too much for large systems...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
