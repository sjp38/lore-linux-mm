Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B5B056B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 01:34:11 -0400 (EDT)
Date: Fri, 30 Jul 2010 13:34:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/5]  [RFC] transfer ASYNC vmscan writeback IO to the
 flusher threads
Message-ID: <20100730053406.GC8811@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729160947.GE12690@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100729160947.GE12690@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 12:09:47AM +0800, Jan Kara wrote:
> On Thu 29-07-10 19:51:42, Wu Fengguang wrote:
> > Andrew,
> > 
> > It's possible to transfer ASYNC vmscan writeback IOs to the flusher threads.
> > This simple patchset shows the basic idea. Since it's a big behavior change,
> > there are inevitably lots of details to sort out. I don't know where it will
> > go after tests and discussions, so the patches are intentionally kept simple.
> > 
> > sync livelock avoidance (need more to be complete, but this is minimal required for the last two patches)
> > 	[PATCH 1/5] writeback: introduce wbc.for_sync to cover the two sync stages
> > 	[PATCH 2/5] writeback: stop periodic/background work on seeing sync works
> > 	[PATCH 3/5] writeback: prevent sync livelock with the sync_after timestamp
>   Well, essentially any WB_SYNC_NONE writeback is still livelockable if you
> just grow a file constantly. So your changes are a step in the right
> direction but won't fix the issue completely.

Right. We have complementary patches to prevent livelocks both inside
file and among files.

> But what we could do to fix
> the issue completely would be to just set wbc->nr_to_write to LONG_MAX
> before writing inode for sync use my livelock avoidance using page-tagging
> for this case (it wouldn't have the possible performance issue because we
> are going to write all the inode anyway).

Yeah your patches are good to avoid livelocking in one single busy file.
I didn't forgot them :)

>   I can write the patch but frankly there are so many patches floating
> around that I'm not sure what I should base it on...

Me confused too. It may take some time to quiet down..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
