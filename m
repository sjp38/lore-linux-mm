Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B387E6B027A
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:03:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s11so3881342pgc.13
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 15:03:19 -0800 (PST)
Received: from out0-195.mail.aliyun.com (out0-195.mail.aliyun.com. [140.205.0.195])
        by mx.google.com with ESMTPS id 74si3860982pfk.175.2017.11.17.15.03.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 15:03:18 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 1/8] mm: kmemleak: remove unused hardirq.h
Date: Sat, 18 Nov 2017 07:02:14 +0800
Message-Id: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>

Preempt counter APIs have been split out, currently, hardirq.h just
includes irq_enter/exit APIs which are not used by kmemleak at all.

So, remove the unused hardirq.h.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/kmemleak.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 7780cd8..25b977f 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -91,7 +91,6 @@
 #include <linux/stacktrace.h>
 #include <linux/cache.h>
 #include <linux/percpu.h>
-#include <linux/hardirq.h>
 #include <linux/bootmem.h>
 #include <linux/pfn.h>
 #include <linux/mmzone.h>
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
