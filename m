Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D3D876B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 01:10:09 -0400 (EDT)
Date: Fri, 30 Jul 2010 13:10:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/5] writeback: introduce wbc.for_sync to cover the two
 sync stages
Message-ID: <20100730051005.GA8811@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729121423.184456417@intel.com>
 <20100729150413.GD12690@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100729150413.GD12690@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 11:04:13PM +0800, Jan Kara wrote:
> On Thu 29-07-10 19:51:43, Wu Fengguang wrote:
> > The sync() is performed in two stages: the WB_SYNC_NONE sync and
> > the WB_SYNC_ALL sync. It is necessary to tag both stages with
> > wbc.for_sync, so as to prevent either of them being livelocked.
> > 
> > The basic livelock scheme will be based on the sync_after timestamp.
> > Inodes dirtied after that won't be queued for IO. The timestamp could be
> > recorded as early as the sync() time, this patch lazily sets it in
> > writeback_inodes_sb()/sync_inodes_sb(). This will stop livelock, but
> > may do more work than necessary.
> > 
> > Note that writeback_inodes_sb() is called by not only sync(), they
> > are treated the same because the other callers need the same livelock
> > prevention.

>   OK, but the patch does nothing, doesn't it? I'd prefer if the fields
> you introduce were actually used in this patch.

OK, I'll merge it with the third patch.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
