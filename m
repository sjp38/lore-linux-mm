Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 205EA6B00E7
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 09:37:31 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so12296359pde.18
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 06:37:30 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id lm4si22904884pab.217.2014.11.12.06.37.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 06:37:29 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so12877768pab.26
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 06:37:29 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zram: correct ZRAM_ZERO flag bit position
Date: Wed, 12 Nov 2014 22:37:18 +0800
Message-Id: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ngupta@vflare.org, minchan@kernel.org, weijie.yang@samsung.com, sergey.senozhatsky@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

In struct zram_table_entry, the element *value* contains obj size and
obj zram flags. Bit 0 to bit (ZRAM_FLAG_SHIFT - 1) represent obj size,
and bit ZRAM_FLAG_SHIFT to the highest bit of unsigned long represent obj
zram_flags. So the first zram flag(ZRAM_ZERO) should be from ZRAM_FLAG_SHIFT
instead of (ZRAM_FLAG_SHIFT + 1).

This patch fixes this issue.

Also this patch fixes a typo, "page in now accessed" -> "page is now accessed"

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 drivers/block/zram/zram_drv.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index c6ee271..b05a816 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -66,8 +66,8 @@ static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
 /* Flags for zram pages (table[page_no].value) */
 enum zram_pageflags {
 	/* Page consists entirely of zeros */
-	ZRAM_ZERO = ZRAM_FLAG_SHIFT + 1,
-	ZRAM_ACCESS,	/* page in now accessed */
+	ZRAM_ZERO = ZRAM_FLAG_SHIFT,
+	ZRAM_ACCESS,	/* page is now accessed */
 
 	__NR_ZRAM_PAGEFLAGS,
 };
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
