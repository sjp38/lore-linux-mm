Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD4E88D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:46:13 -0400 (EDT)
Message-Id: <20110420080336.441157866@intel.com>
Date: Wed, 20 Apr 2011 16:03:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/6] writeback: moving expire targets for background/kupdate works v2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>

Andrew,

This aims to reduce possible pageout() calls by making the flusher
concentrate a bit more on old/expired dirty inodes.

Rationals and benchmark numbers are added in patches 05, 06.

It runs fine on simple workloads over ext3/4, xfs, btrfs and NFS.

code refactor
	[PATCH 1/6] writeback: pass writeback_control down to move_expired_inodes()

loop condition fixes
	[PATCH 2/6] writeback: introduce writeback_control.inodes_cleaned
	[PATCH 3/6] writeback: try more writeback as long as something was written

make dirty expire time a moving target
	[PATCH 4/6] writeback: the kupdate expire timestamp should be a moving target
	[PATCH 5/6] writeback: sync expired inodes first in background writeback

consistent requeue policy
it's not an integral part of this patchset, however do depends on patch 03
	[PATCH 6/6] writeback: refill b_io iff empty


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
