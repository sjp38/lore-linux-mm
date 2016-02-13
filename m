Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6426B0009
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 17:47:50 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id l127so124970816iof.3
        for <linux-mm@kvack.org>; Sat, 13 Feb 2016 14:47:50 -0800 (PST)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id j28si30666847ioi.27.2016.02.13.14.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Feb 2016 14:47:47 -0800 (PST)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] mm/compaction: don't use modular references for non modular code
Date: Sat, 13 Feb 2016 17:47:34 -0500
Message-ID: <1455403654-28951-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

replace module_init with subsys_initcall ; which will be two
levels earlier, but mm smells like a subsystem to me.

Compile tested only.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[Feel free to squash this into the original, if desired.]

 mm/compaction.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4cb1c2ef5abb..4d99e1f5055c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -20,7 +20,6 @@
 #include <linux/kasan.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
-#include <linux/module.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -1954,7 +1953,6 @@ static int __init kcompactd_init(void)
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;
 }
-
-module_init(kcompactd_init)
+subsys_initcall(kcompactd_init)
 
 #endif /* CONFIG_COMPACTION */
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
