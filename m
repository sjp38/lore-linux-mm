Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AD9C16B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 05:16:15 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so4014815pad.1
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 02:16:15 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id vu3si2132052pab.137.2015.01.07.02.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 07 Jan 2015 02:16:14 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHS00E11Y1T4H20@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 07 Jan 2015 10:20:17 +0000 (GMT)
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Subject: [PATCH] mm: fix cleancache debugfs directory path
Date: Wed, 07 Jan 2015 11:14:41 +0100
Message-id: <1420625681-13819-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, trivial@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, b.zolnierkie@samsung.com, Marcin Jabrzyk <m.jabrzyk@samsung.com>

Minor fixes for cleancache about wrong debugfs paths
in documentation and code comment.

Signed-off-by: Marcin Jabrzyk <m.jabrzyk@samsung.com>
---
 Documentation/vm/cleancache.txt | 2 +-
 mm/cleancache.c                 | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/cleancache.txt b/Documentation/vm/cleancache.txt
index 142fbb0f325a..01d76282444e 100644
--- a/Documentation/vm/cleancache.txt
+++ b/Documentation/vm/cleancache.txt
@@ -85,7 +85,7 @@ lock the page to ensure serial behavior.
 CLEANCACHE PERFORMANCE METRICS
 
 If properly configured, monitoring of cleancache is done via debugfs in
-the /sys/kernel/debug/mm/cleancache directory.  The effectiveness of cleancache
+the /sys/kernel/debug/cleancache directory.  The effectiveness of cleancache
 can be measured (across all filesystems) with:
 
 succ_gets	- number of gets that were successful
diff --git a/mm/cleancache.c b/mm/cleancache.c
index d0eac4350403..053bcd8f12fb 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -25,7 +25,7 @@
 static struct cleancache_ops *cleancache_ops __read_mostly;
 
 /*
- * Counters available via /sys/kernel/debug/frontswap (if debugfs is
+ * Counters available via /sys/kernel/debug/cleancache (if debugfs is
  * properly configured.  These are for information only so are not protected
  * against increment races.
  */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
