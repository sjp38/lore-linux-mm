Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 671B98E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:05:05 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id o25-v6so96923wmh.1
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:05:05 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50091.outbound.protection.outlook.com. [40.107.5.91])
        by mx.google.com with ESMTPS id w12-v6si4695304wrl.27.2018.09.14.06.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 06:05:04 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/3] kvfree(): Fix misleading comment.
Date: Fri, 14 Sep 2018 16:05:10 +0300
Message-Id: <20180914130512.10394-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

vfree() might sleep if called not in interrupt context.
So does kvfree() too. Fix misleading kvfree()'s comment about
allowed context.

Fixes: 04b8e946075d ("mm/util.c: improve kvfree() kerneldoc")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index eeac38a64290..7f1f165f46af 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -442,7 +442,7 @@ EXPORT_SYMBOL(kvmalloc_node);
  * It is slightly more efficient to use kfree() or vfree() if you are certain
  * that you know which one to use.
  *
- * Context: Any context except NMI.
+ * Context: Either preemptible task context or not-NMI interrupt.
  */
 void kvfree(const void *addr)
 {
-- 
2.16.4
