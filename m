Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 168C56B0096
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 17:46:37 -0400 (EDT)
Received: by wghl18 with SMTP id l18so4857141wgh.11
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 14:46:36 -0700 (PDT)
Received: from xavier.telenet-ops.be (xavier.telenet-ops.be. [195.130.132.52])
        by mx.google.com with ESMTP id my16si3563963wic.59.2015.03.10.14.46.35
        for <linux-mm@kvack.org>;
        Tue, 10 Mar 2015 14:46:35 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] zsmalloc: Add missing #include <linux/sched.h>
Date: Tue, 10 Mar 2015 22:46:31 +0100
Message-Id: <1426023991-30407-1-git-send-email-geert@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-next@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

mips/allmodconfig:

mm/zsmalloc.c: In function '__zs_compact':
mm/zsmalloc.c:1747:2: error: implicit declaration of function
'cond_resched' [-Werror=implicit-function-declaration]

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
http://kisskb.ellerman.id.au/kisskb/buildresult/12379881/
---
 mm/zsmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 73400f0534a773e7..dccc20c208725548 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -91,6 +91,7 @@
 #include <linux/cpu.h>
 #include <linux/vmalloc.h>
 #include <linux/hardirq.h>
+#include <linux/sched.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/debugfs.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
