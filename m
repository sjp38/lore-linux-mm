From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/13] writeback patches for 2.6.36
Date: Fri, 06 Aug 2010 00:10:51 +0800
Message-ID: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3Jl-0002rR-Gj
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:17 +0200
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C68A76B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:34 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Andrew,

These are writeback patches intended for 2.6.36.

It's combined from 2 previous patchsets:

	writeback cleanups and trivial fixes <http://lkml.org/lkml/2010/7/10/153>
	writeback: try to write older pages first <http://lkml.org/lkml/2010/7/22/47>

changelog:
- removed patch "writeback: take account of NR_WRITEBACK_TEMP in balance_dirty_pages()"
- added patch "writeback: explicit low bound for vm.dirty_ratio"
- use "if (list_empty(&wb->b_io))" directly in "writeback: sync expired inodes first in background writeback"
- fix misplaced chunk for removing more_io in include/trace/events/ext4.h
- update comments in "writeback: fix queue_io() ordering"
- update comments in "writeback: add comment to the dirty limits functions"
- patch "writeback: try more writeback as long as something was written" will
  no longer livelock sync() with Jan's sync() livelock avoidance patches

	[PATCH 01/13] writeback: reduce calls to global_page_state in balance_dirty_pages()
	[PATCH 02/13] writeback: avoid unnecessary calculation of bdi dirty thresholds
	[PATCH 03/13] writeback: add comment to the dirty limits functions
	[PATCH 04/13] writeback: dont redirty tail an inode with dirty pages
	[PATCH 05/13] writeback: fix queue_io() ordering
	[PATCH 06/13] writeback: merge for_kupdate and !for_kupdate cases
	[PATCH 07/13] writeback: explicit low bound for vm.dirty_ratio
	[PATCH 08/13] writeback: pass writeback_control down to move_expired_inodes()
	[PATCH 09/13] writeback: the kupdate expire timestamp should be a moving target
	[PATCH 10/13] writeback: kill writeback_control.more_io
	[PATCH 11/13] writeback: sync expired inodes first in background writeback
	[PATCH 12/13] writeback: try more writeback as long as something was written
	[PATCH 13/13] writeback: introduce writeback_control.inodes_written

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
