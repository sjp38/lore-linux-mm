Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6516F6B00B3
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 11:37:03 -0500 (EST)
Received: by yia25 with SMTP id 25so3602837yia.14
        for <linux-mm@kvack.org>; Mon, 03 Jan 2011 08:37:02 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] writeback: fix typo of global_dirty_limits comment
Date: Tue,  4 Jan 2011 01:36:48 +0900
Message-Id: <1294072608-3172-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Change runtime with real-time

Cc: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/page-writeback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c340536..98b79e2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -384,7 +384,7 @@ unsigned long determine_dirtyable_memory(void)
  * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
  * - vm.dirty_ratio             or  vm.dirty_bytes
  * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
- * runtime tasks.
+ * real-time tasks.
  */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
