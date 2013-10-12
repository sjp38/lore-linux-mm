Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 024026B0036
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:16 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so5981478pab.10
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:16 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 02/23] mm/block: remove unnecessary inclusion of bootmem.h
Date: Sat, 12 Oct 2013 17:58:45 -0400
Message-ID: <1381615146-20342-3-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Clean-up to remove depedency with bootmem headers.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 block/blk-ioc.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index 46cd7bd..242df01 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -6,7 +6,6 @@
 #include <linux/init.h>
 #include <linux/bio.h>
 #include <linux/blkdev.h>
-#include <linux/bootmem.h>	/* for max_pfn/max_low_pfn */
 #include <linux/slab.h>
 
 #include "blk.h"
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
