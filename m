Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A9EE86B0038
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 04:52:56 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so267109638pab.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 01:52:56 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id mx8si2845613pdb.255.2015.04.22.01.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 01:52:55 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NN700HWNA5KDR30@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Apr 2015 09:56:08 +0100 (BST)
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Subject: [PATCH v2 1/2] zram: remove obsolete ZRAM_DEBUG option
Date: Wed, 22 Apr 2015 10:52:35 +0200
Message-id: <1429692756-15197-2-git-send-email-m.jabrzyk@samsung.com>
In-reply-to: <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
References: <1429615220-20676-1-git-send-email-m.jabrzyk@samsung.com>
 <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kyungmin.park@samsung.com, Marcin Jabrzyk <m.jabrzyk@samsung.com>

This config option doesn't provide any usage for zram.

Signed-off-by: Marcin Jabrzyk <m.jabrzyk@samsung.com>
---
 drivers/block/zram/Kconfig    | 10 +---------
 drivers/block/zram/zram_drv.c |  4 ----
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index 6489c0fd0ea6..386ba3d1a6ee 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -23,12 +23,4 @@ config ZRAM_LZ4_COMPRESS
 	default n
 	help
 	  This option enables LZ4 compression algorithm support. Compression
-	  algorithm can be changed using `comp_algorithm' device attribute.
-
-config ZRAM_DEBUG
-	bool "Compressed RAM block device debug support"
-	depends on ZRAM
-	default n
-	help
-	  This option adds additional debugging code to the compressed
-	  RAM block device driver.
+	  algorithm can be changed using `comp_algorithm' device attribute.
\ No newline at end of file
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index fe67ebbe6c18..ea10f291d722 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -15,10 +15,6 @@
 #define KMSG_COMPONENT "zram"
 #define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
 
-#ifdef CONFIG_ZRAM_DEBUG
-#define DEBUG
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/bio.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
