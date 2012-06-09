Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id AAB896B0062
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 07:45:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4412549pbb.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 04:45:43 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/page-writeback.c: fix comments error in page-writeback.c
Date: Sat,  9 Jun 2012 19:45:33 +0800
Message-Id: <1339242333-3080-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>, Wanpeng Li <liwp@linux.vnet.ibm.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp@linux.vnet.ibm.com>
---
 mm/page-writeback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 93d8d2f..c833bf0 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -930,7 +930,7 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 */
 
 	/*
-	 * dirty_ratelimit will follow balanced_dirty_ratelimit iff
+	 * dirty_ratelimit will follow balanced_dirty_ratelimit if
 	 * task_ratelimit is on the same side of dirty_ratelimit, too.
 	 * For example, when
 	 * - dirty_ratelimit > balanced_dirty_ratelimit
@@ -941,7 +941,7 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * feel and care are stable dirty rate and small position error.
 	 *
 	 * |task_ratelimit - dirty_ratelimit| is used to limit the step size
-	 * and filter out the sigular points of balanced_dirty_ratelimit. Which
+	 * and filter out the singular points of balanced_dirty_ratelimit. Which
 	 * keeps jumping around randomly and can even leap far away at times
 	 * due to the small 200ms estimation period of dirty_rate (we want to
 	 * keep that period small to reduce time lags).
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
