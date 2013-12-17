Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 714876B003B
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:41 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so6501968pbc.34
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:41 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sa6si10874967pbb.23.2013.12.16.22.11.38
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:40 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/5] zram: add copyright
Date: Tue, 17 Dec 2013 15:12:00 +0900
Message-Id: <1387260723-15817-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1387260723-15817-1-git-send-email-minchan@kernel.org>
References: <1387260723-15817-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Add my copyright to the zram source code which I maintain.

Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c |    1 +
 drivers/block/zram/zram_drv.h |    1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 134d605836ca..f9711c520269 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -2,6 +2,7 @@
  * Compressed RAM block device
  *
  * Copyright (C) 2008, 2009, 2010  Nitin Gupta
+ *               2012, 2013 Minchan Kim
  *
  * This code is released using a dual license strategy: BSD/GPL
  * You can choose the licence that better fits your requirements.
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 92f70e8f457c..0e46953c08e9 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -2,6 +2,7 @@
  * Compressed RAM block device
  *
  * Copyright (C) 2008, 2009, 2010  Nitin Gupta
+ *               2012, 2013 Minchan Kim
  *
  * This code is released using a dual license strategy: BSD/GPL
  * You can choose the licence that better fits your requirements.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
