Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2887A6B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 08:48:55 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so2774186pad.4
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 05:48:54 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id pn5si5649719pbb.72.2015.01.24.05.48.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 Jan 2015 05:48:54 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id g10so3260801pdj.0
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 05:48:53 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: add log for module load/unload
Date: Sat, 24 Jan 2015 21:48:41 +0800
Message-Id: <1422107321-9973-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Sometimes, we want to know whether a module is loaded or unloaded
from the log.

This patch adds some log.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2d5f5be..16617e9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -72,6 +72,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #ifdef CONFIG_ZSMALLOC_DEBUG
 #define DEBUG
 #endif
@@ -1460,6 +1462,8 @@ static int __init zs_init(void)
 {
 	int ret = zs_register_cpu_notifier();
 
+	pr_info("loaded\n");
+
 	if (ret)
 		goto notifier_fail;
 
@@ -1474,6 +1478,7 @@ static int __init zs_init(void)
 		pr_err("zs stat initialization failed\n");
 		goto stat_fail;
 	}
+
 	return 0;
 
 stat_fail:
@@ -1483,6 +1488,8 @@ stat_fail:
 notifier_fail:
 	zs_unregister_cpu_notifier();
 
+	pr_info("unloaded\n");
+
 	return ret;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
