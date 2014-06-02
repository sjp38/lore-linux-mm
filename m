Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B1F0A6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 05:47:30 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so4036083pbb.31
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 02:47:30 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id da3si15121508pbc.123.2014.06.02.02.47.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 02:47:29 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so1753098pab.10
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 02:47:29 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm/page-writeback.c: remove outdated comment
Date: Mon,  2 Jun 2014 17:47:20 +0800
Message-Id: <1401702440-1884-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, riel@redhat.com, hannes@cmpxchg.org, kosaki.motohiro@jp.fujitsu.com, cldu@marvell.com, nasa4836@gmail.com, handai.szj@taobao.com, paul.gortmaker@windriver.com, mpatlasov@parallels.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is an orphaned prehistoric comment , which used to be against
get_dirty_limits(), the dawn of global_dirtyable_memory().

Back then, the implementation of get_dirty_limits() is complicated and
full of magic numbers, so this comment is necessary. But we now
use the clear and neat global_dirtyable_memory(), which renders this
comment ambiguous and useless. Remove it.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/page-writeback.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a4317da..f2683ac 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -156,24 +156,6 @@ static unsigned long writeout_period_time = 0;
 #define VM_COMPLETIONS_PERIOD_LEN (3*HZ)
 
 /*
- * Work out the current dirty-memory clamping and background writeout
- * thresholds.
- *
- * The main aim here is to lower them aggressively if there is a lot of mapped
- * memory around.  To avoid stressing page reclaim with lots of unreclaimable
- * pages.  It is better to clamp down on writers than to start swapping, and
- * performing lots of scanning.
- *
- * We only allow 1/2 of the currently-unmapped memory to be dirtied.
- *
- * We don't permit the clamping level to fall below 5% - that is getting rather
- * excessive.
- *
- * We make sure that the background writeout level is below the adjusted
- * clamping level.
- */
-
-/*
  * In a memory zone, there is a certain amount of pages we consider
  * available for the page cache, which is essentially the number of
  * free and reclaimable pages, minus some zone reserves to protect
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
