Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 48ECE6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 07:21:06 -0400 (EDT)
Date: Tue, 26 Jul 2011 21:20:55 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
Message-ID: <20110726112055.GC8048@dastard>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 21, 2011 at 05:28:42PM +0100, Mel Gorman wrote:
> Warning: Long post with lots of figures. If you normally drink coffee
> and you don't have a cup, get one or you may end up with a case of
> keyboard face.

[snip]

> Overall, having kswapd avoiding writes does improve performance
> which is not a surprise. Dave asked "do we even need IO at all from
> reclaim?". On NUMA machines, the answer is "yes" unless the VM can
> wake the flusher thread to clean a specific node.

Great answer, Mel. ;)

> When kswapd never
> writes, processes can stall for significant periods of time waiting on
> flushers to clean the correct pages. If all writing is to be deferred
> to flushers, it must ensure that many writes on one node would not
> starve requests for cleaning pages on another node.

Ok, so that's a direction we need to work towards, then.

> I'm currently of the opinion that we should consider merging patches
> 1-7 and discuss what is required before merging. It can be tackled
> later how the flushers can prioritise writing of pages belonging to
> a particular zone before disabling all writes from reclaim.

Sounds reasonable to me.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
