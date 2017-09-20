Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 488BA6B026A
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 85so4573314ith.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u67sor1997233itc.42.2017.09.20.08.33.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:28 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 5/7] fs-writeback: make wb_start_writeback() static
Date: Wed, 20 Sep 2017 09:33:00 -0600
Message-Id: <1505921582-26709-6-git-send-email-axboe@kernel.dk>
In-Reply-To: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz, Jens Axboe <axboe@kernel.dk>

We don't have any callers outside of fs-writeback.c anymore,
make it private.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Chris Mason <clm@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
---
 fs/fs-writeback.c           | 4 ++--
 include/linux/backing-dev.h | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index c7f99fd2c7f0..ecbd26d1121d 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -933,8 +933,8 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
-			bool range_cyclic, enum wb_reason reason)
+static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
+			       bool range_cyclic, enum wb_reason reason)
 {
 	struct wb_writeback_work *work;
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 854e1bdd0b2a..157e950a70dc 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -38,8 +38,6 @@ static inline struct backing_dev_info *bdi_alloc(gfp_t gfp_mask)
 	return bdi_alloc_node(gfp_mask, NUMA_NO_NODE);
 }
 
-void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
-			bool range_cyclic, enum wb_reason reason);
 void wb_start_background_writeback(struct bdi_writeback *wb);
 void wb_workfn(struct work_struct *work);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
