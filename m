Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5C3D5900087
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:36 -0400 (EDT)
Message-Id: <20110416132546.765212221@intel.com>
Date: Sat, 16 Apr 2011 21:25:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/12] IO-less dirty throttling v7 
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Andrew,

This revision undergoes a number of simplifications, cleanups and fixes.
Independent patches are separated out. The core patches (07, 08) now have
easier to understand changelog. Detailed rationals can be found in patch 08.

In response to the complexity complaints, an introduction document is
written explaining the rationals, algorithm and visual case studies:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf

The full patchset is accessible in

git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v7

Questions, reviews and independent tests will be highly appreciated.

supporting functionalities

	[PATCH 01/12] writeback: account per-bdi accumulated written pages
	[PATCH 02/12] writeback: account per-bdi accumulated dirtied pages
	[PATCH 03/12] writeback: bdi write bandwidth estimation
	[PATCH 04/12] writeback: smoothed global/bdi dirty pages
	[PATCH 05/12] writeback: smoothed dirty threshold and limit
	[PATCH 06/12] writeback: enforce 1/4 gap between the dirty/background thresholds

core changes

	[PATCH 07/12] writeback: base throttle bandwidth and position ratio
	[PATCH 08/12] writeback: IO-less balance_dirty_pages()

tracing

	[PATCH 09/12] writeback: show bdi write bandwidth in debugfs
	[PATCH 10/12] writeback: trace dirty_ratelimit
	[PATCH 11/12] writeback: trace balance_dirty_pages
	[PATCH 12/12] writeback: trace global_dirty_state

 fs/fs-writeback.c                |    3 
 include/linux/backing-dev.h      |   23 
 include/linux/sched.h            |    8 
 include/linux/writeback.h        |   49 +
 include/trace/events/writeback.h |  179 +++++
 mm/backing-dev.c                 |   51 +
 mm/memory_hotplug.c              |    3 
 mm/page-writeback.c              |  980 +++++++++++++++++++++++------
 8 files changed, 1085 insertions(+), 211 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
