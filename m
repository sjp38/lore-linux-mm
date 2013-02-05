Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 998DF6B000D
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 18:45:25 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zram: fix warning of print format
Date: Wed,  6 Feb 2013 08:45:22 +0900
Message-Id: <1360107922-21725-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

kbuild bot whinges due to print format mistmatch caused by
zram: force disksize setting before using zram.

This patch fixes it.

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 85055c4..3318b0f 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -519,7 +519,7 @@ int zram_init_device(struct zram *zram)
 		"ratio. Note that zram uses about 0.1%% of the size of "
 		"the disk when not in use so a huge zram is "
 		"wasteful.\n"
-		"\tMemory Size: %zu kB\n"
+		"\tMemory Size: %lu kB\n"
 		"\tSize you selected: %llu kB\n"
 		"Continuing anyway ...\n",
 		(totalram_pages << PAGE_SHIFT) >> 10, zram->disksize >> 10
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
