Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 527676B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 11:22:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b6so11412394pff.18
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 08:22:14 -0800 (PST)
Received: from out0-194.mail.aliyun.com (out0-194.mail.aliyun.com. [140.205.0.194])
        by mx.google.com with ESMTPS id y10si12182280pfl.122.2017.11.06.08.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 08:22:13 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH v2] mm: filemap: remove include of hardirq.h
Date: Tue, 07 Nov 2017 00:21:59 +0800
Message-Id: <1509985319-38633-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, willy@infradead.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

in_atomic() has been moved to include/linux/preempt.h, and the filemap.c
doesn't use in_atomic() directly at all, so it sounds unnecessary to
include hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
v1 --> v2:
* Removed the wrong message about kernel size change

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
