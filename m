Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 711436B016B
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 23:30:26 -0400 (EDT)
Message-Id: <20110816022006.348714319@intel.com>
Date: Tue, 16 Aug 2011 10:20:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/5] IO-less dirty throttling v9 
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi,

The core bits of the IO-less balance_dirty_pages().

        git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v9

Changes since v8:

- a lot of renames and comment/changelog rework
- use 3rd order polynomial as the global control line (Peter)
- stabilize dirty_ratelimit by decreasing update step size on small errors
- limit per-CPU dirtied pages to avoid dirty pages run away on 1k+ tasks (Peter)

Thanks a lot to Peter and Andrea, Vivek for the careful reviews!

shortlog:
        
        Wu Fengguang (5):
              writeback: account per-bdi accumulated dirtied pages
              writeback: dirty position control
              writeback: dirty rate control
              writeback: per task dirty rate limit
              writeback: IO-less balance_dirty_pages()

        The last 4 patches are one single logical change, but splitted here to
        make it easier to review the different parts of the algorithm.

diffstat:

	 fs/fs-writeback.c                |    2 
	 include/linux/backing-dev.h      |    8 
	 include/linux/sched.h            |    7 
	 include/linux/writeback.h        |    1 
	 include/trace/events/writeback.h |   24 -
	 kernel/fork.c                    |    3 
	 mm/backing-dev.c                 |    3 
	 mm/page-writeback.c              |  544 ++++++++++++++++++++---------
	 8 files changed, 414 insertions(+), 178 deletions(-)

Thanks,
Fengguang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
