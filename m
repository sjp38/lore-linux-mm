From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 20/47] writeback: use do_div in bw calculation
Date: Mon, 13 Dec 2010 14:43:09 +0800
Message-ID: <20101213064839.406113721@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-use-do_div.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:28.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:28.000000000 +0800
@@ -658,10 +658,10 @@ static void balance_dirty_pages(struct a
 		 */
 		bw = bdi->write_bandwidth;
 		bw = bw * (bdi_thresh - bdi_dirty);
-		bw = bw / (bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
+		do_div(bw, bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
 
 		bw = bw * (task_thresh - bdi_dirty);
-		bw = bw / (bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
+		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
 		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
 		pause = clamp_val(pause, 1, HZ/10);


