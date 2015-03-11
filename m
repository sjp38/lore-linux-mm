Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8818C6B0095
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 23:41:13 -0400 (EDT)
Received: by obbnt9 with SMTP id nt9so6226071obb.12
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 20:41:13 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id zc5si996183oec.52.2015.03.10.20.41.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 20:41:12 -0700 (PDT)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YVXWB-002ucJ-VK
	for linux-mm@kvack.org; Wed, 11 Mar 2015 03:41:12 +0000
From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] zsmalloc: Include linux/sched.h to fix build error
Date: Tue, 10 Mar 2015 20:41:02 -0700
Message-Id: <1426045262-14739-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>

Fix:

mm/zsmalloc.c: In function '__zs_compact':
mm/zsmalloc.c:1747:2: error: implicit declaration of function 'cond_resched'

seen when building mips:allmodconfig.

Fixes: c4d204c38734 ("zsmalloc: support compaction")
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 mm/zsmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 73400f0..b663a8b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -94,6 +94,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/debugfs.h>
+#include <linux/sched.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
