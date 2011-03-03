Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 56CFC8D003F
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:57 -0500 (EST)
Message-Id: <20110303074948.803361297@intel.com>
Date: Thu, 03 Mar 2011 14:45:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 01/27] writeback: add bdi_dirty_limit() kernel-doc
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-task_dirty_limit-comment.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Clarify the bdi_dirty_limit() comment.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:38:12.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:40:52.000000000 +0800
@@ -437,10 +437,17 @@ void global_dirty_limits(unsigned long *
 	*pdirty = dirty;
 }
 
-/*
+/**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold
+ * @bdi: the backing_dev_info to query
+ * @dirty: global dirty limit in pages
+ *
+ * Returns @bdi's dirty limit in pages. The term "dirty" in the context of
+ * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
+ * And the "limit" in the name is not seriously taken as hard limit in
+ * balance_dirty_pages().
  *
- * Allocate high/low dirty limits to fast/slow devices, in order to prevent
+ * It allocates high/low dirty limits to fast/slow devices, in order to prevent
  * - starving fast devices
  * - piling up dirty pages (that will take long time to sync) on slow devices
  *


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
