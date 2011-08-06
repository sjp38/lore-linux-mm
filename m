Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AAB2D6B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 08:20:02 -0400 (EDT)
Message-Id: <20110806084447.388624428@intel.com>
Date: Sat, 06 Aug 2011 16:44:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/5] IO-less dirty throttling v8 
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi all,

The _core_ bits of the IO-less balance_dirty_pages().
Heavily simplified and re-commented to make it easier to review.

	git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v8

Only the bare minimal algorithms are presented, so you will find some rough
edges in the graphs below. But it's usable :)

	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/

And an introduction to the (more complete) algorithms:

	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf

Questions and reviews are highly appreciated!

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

	 include/linux/backing-dev.h      |    8 +
	 include/linux/sched.h            |    7 +
	 include/trace/events/writeback.h |   24 --
	 mm/backing-dev.c                 |    3 +
	 mm/memory_hotplug.c              |    3 -
	 mm/page-writeback.c              |  459 ++++++++++++++++++++++----------------
	 6 files changed, 290 insertions(+), 214 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
