Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D58FF6B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:14:41 -0400 (EDT)
Received: by padcn9 with SMTP id cn9so23449431pad.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 06:14:41 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id t8si13202038pbs.231.2015.10.14.06.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 06:14:41 -0700 (PDT)
Received: by payp3 with SMTP id p3so6517622pay.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 06:14:41 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] zsmalloc: use preempt.h for in_interrupt()
Date: Wed, 14 Oct 2015 22:13:20 +0900
Message-Id: <1444828400-4067-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

A cosmetic change.

Commit c60369f01125 ("staging: zsmalloc: prevent mappping
in interrupt context") added in_interrupt() check to
zs_map_object() and 'hardirq.h' include; but in_interrupt()
macro is defined in 'preempt.h' not in 'hardirq.h', so include
it instead.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 7ad5e54..4d5671d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -58,7 +58,7 @@
 #include <linux/cpumask.h>
 #include <linux/cpu.h>
 #include <linux/vmalloc.h>
-#include <linux/hardirq.h>
+#include <linux/preempt.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/debugfs.h>
-- 
2.6.1.134.g4b1fd35

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
