Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 536518D0001
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 08:15:27 -0400 (EDT)
Date: Fri, 5 Nov 2010 13:15:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] writeback: stop background/kupdate works from
 livelocking other works
Message-ID: <20101105121513.GC23393@cmpxchg.org>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
 <20101101121408.GB9006@localhost>
 <20101101122252.GA10637@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101122252.GA10637@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 08:22:52PM +0800, Wu Fengguang wrote:
> From: Jan Kara <jack@suse.cz>
> 
> Background writeback are easily livelockable (from a definition of their
> target). This is inconvenient because it can make sync(1) stall forever waiting
> on its queued work to be finished. Generally, when a flusher thread has
> some work queued, someone submitted the work to achieve a goal more specific
> than what background writeback does. So it makes sense to give it a priority
> over a generic page cleaning.
> 
> Thus we interrupt background writeback if there is some other work to do. We
> return to the background writeback after completing all the queued work.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
