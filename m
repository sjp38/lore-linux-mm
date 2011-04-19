Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 30500900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:10:22 -0400 (EDT)
Message-Id: <20110419030003.108796967@intel.com>
Date: Tue, 19 Apr 2011 11:00:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/6] writeback: moving expire targets for background/kupdate works
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>


Andrew,

This aims to reduce possible pageout() calls by making the flusher
concentrate a bit more on old/expired dirty inodes.

Patches 04, 05 have been updated since last post, please review.
The concerns from last review have been addressed.

It runs fine on simple workloads over ext3/4, xfs, btrfs and NFS.

Trond, will you take the last patch? The fixed "bug" has no real impact for now.

make dirty expire time a moving target
        [PATCH 1/6] writeback: pass writeback_control down to move_expired_inodes()
        [PATCH 2/6] writeback: the kupdate expire timestamp should be a moving target
        [PATCH 3/6] writeback: sync expired inodes first in background writeback

loop condition fixes (the most tricky part)
        [PATCH 4/6] writeback: introduce writeback_control.inodes_cleaned
        [PATCH 5/6] writeback: try more writeback as long as something was written

NFS fix
        [PATCH 6/6] NFS: return -EAGAIN when skipped commit in nfs_commit_unstable_pages()

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
