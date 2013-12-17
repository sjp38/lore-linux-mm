Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id F3E8A6B0039
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:40 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so4004160pad.40
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:40 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ek3si10827702pbd.295.2013.12.16.22.11.37
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:38 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/5] zram: remove old private project comment
Date: Tue, 17 Dec 2013 15:11:59 +0900
Message-Id: <1387260723-15817-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1387260723-15817-1-git-send-email-minchan@kernel.org>
References: <1387260723-15817-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

This patch removes old private compcache project address so
upcoming patches should be sent to LKML because we Linux kernel
community will take care.

Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/blockdev/zram.txt |    6 ------
 drivers/block/zram/Kconfig      |    1 -
 drivers/block/zram/zram_drv.c   |    1 -
 drivers/block/zram/zram_drv.h   |    1 -
 4 files changed, 9 deletions(-)

diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index 765d790ae831..2eccddffa6c8 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -1,8 +1,6 @@
 zram: Compressed RAM based block devices
 ----------------------------------------
 
-Project home: http://compcache.googlecode.com/
-
 * Introduction
 
 The zram module creates RAM based block devices named /dev/zram<id>
@@ -69,9 +67,5 @@ Following shows a typical sequence of steps for using zram.
 	resets the disksize to zero. You must set the disksize again
 	before reusing the device.
 
-Please report any problems at:
- - Mailing list: linux-mm-cc at laptop dot org
- - Issue tracker: http://code.google.com/p/compcache/issues/list
-
 Nitin Gupta
 ngupta@vflare.org
diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index 983314c41349..3450be850399 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -14,7 +14,6 @@ config ZRAM
 	  disks and maybe many more.
 
 	  See zram.txt for more information.
-	  Project home: <https://compcache.googlecode.com/>
 
 config ZRAM_DEBUG
 	bool "Compressed RAM block device debug support"
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 108f2733106d..134d605836ca 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -9,7 +9,6 @@
  * Released under the terms of 3-clause BSD License
  * Released under the terms of GNU General Public License Version 2.0
  *
- * Project home: http://compcache.googlecode.com
  */
 
 #define KMSG_COMPONENT "zram"
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index d8f6596513c3..92f70e8f457c 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -9,7 +9,6 @@
  * Released under the terms of 3-clause BSD License
  * Released under the terms of GNU General Public License Version 2.0
  *
- * Project home: http://compcache.googlecode.com
  */
 
 #ifndef _ZRAM_DRV_H_
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
