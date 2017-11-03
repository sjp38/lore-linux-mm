Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 581966B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 14:48:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11so3519406pfk.23
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 11:48:11 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id y66si6611968pgb.156.2017.11.03.11.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 11:48:10 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH] mm: filemap: remove include of hardirq.h
Date: Sat, 04 Nov 2017 02:47:48 +0800
Message-Id: <1509734868-120762-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

in_atomic() has been moved to include/linux/preempt.h, and the filemap.c
doesn't use in_atomic() directly at all, so it sounds unnecessary to
include hardirq.h.
With removing hardirq.h, around 32 bytes can be saved for x86_64 bzImage
with allnoconfig.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/filemap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 594d73f..57238f4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -31,7 +31,6 @@
 #include <linux/blkdev.h>
 #include <linux/security.h>
 #include <linux/cpuset.h>
-#include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
