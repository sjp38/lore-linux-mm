Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EAF78620113
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:14:30 -0400 (EDT)
Date: Tue, 3 Aug 2010 21:22:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: stop periodic/background work on seeing
 sync works
Message-ID: <20100803132216.GA31893@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729121423.332557547@intel.com>
 <20100729162027.GF12690@quack.suse.cz>
 <20100730040306.GA5694@localhost>
 <20100802205152.GL3278@quack.suse.cz>
 <20100803030125.GA12070@localhost>
 <20100803105520.GA3322@quack.suse.cz>
 <20100803123922.GC3322@quack.suse.cz>
 <20100803125924.GA31827@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803125924.GA31827@localhost>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> >   Fengguang, how about merging also the attached simple patch together with
> > my fix? With these two patches, I'm not able to trigger any sync livelock
> > while without one of them I hit them quite easily...
> 
> This looks OK. However note that redirty_tail() can modify
> dirtied_when unexpectedly. So the more we rely on wb_start, the more
> possibility an inode is (wrongly) skipped by sync. I have a bunch of
> patches to remove redirty_tail(). However they may not be good
> candidates for 2.6.36..

It looks that setting wb_start at the beginning of
writeback_inodes_wb() won't be easily affected by redirty_tail().

So

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
