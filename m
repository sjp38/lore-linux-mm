Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF2458D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 16:41:19 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v5 3/9] writeback: convert variables to unsigned
Date: Fri, 25 Feb 2011 13:35:54 -0800
Message-Id: <1298669760-26344-4-git-send-email-gthelen@google.com>
In-Reply-To: <1298669760-26344-1-git-send-email-gthelen@google.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

Convert two balance_dirty_pages() page counter variables (nr_reclaimable
and nr_writeback) from 'long' to 'unsigned long'.

These two variables are used to store results from global_page_state().
global_page_state() returns unsigned long and carefully sums per-cpu
counters explicitly avoiding returning a negative value.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v4:
- Created this patch for clarity.  Previously this patch was integrated within
  the "writeback: create dirty_info structure" patch.

 mm/page-writeback.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2cb01f6..4408e54 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -478,8 +478,10 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long write_chunk)
 {
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
+	unsigned long nr_reclaimable;
+	long bdi_nr_reclaimable;
+	unsigned long nr_writeback;
+	long bdi_nr_writeback;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
