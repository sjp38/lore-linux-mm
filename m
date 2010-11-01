Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EED426B0189
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 11:13:29 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:13:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/4] writeback: quit background/periodic work when
 other works are enqueued
Message-ID: <20101101151318.GD15406@quack.suse.cz>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
 <20101101120733.GA9006@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101120733.GA9006@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon 01-11-10 20:07:33, Wu Fengguang wrote:
> You patches are more complete than mine, so let's use them. However I
> do prefer to have a standalone wb_check_background_flush() that is
> called _after_ wb_check_old_data_flush(). This helps make the writeout
> a bit more ordered and the separation itself looks a bit more clean to
> me.
> 
> Followed are the slightly updated patches. IMHO they are straightforward
> fixes that could be merged before other writeback changes.
  One more question - who's going to merge it with Linus? Would you send
the patches to Jens' to merge them via the block tree (note that Jens has
a new email address since he joined FusionIO)? Or maybe to Andrew?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
