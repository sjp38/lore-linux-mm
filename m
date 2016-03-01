Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAE76B0256
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 08:43:26 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 124so51455756pfg.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:43:26 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id q136si17146434pfq.209.2016.03.01.05.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 05:43:25 -0800 (PST)
Received: by mail-pa0-x236.google.com with SMTP id fl4so112471821pad.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:43:25 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH] mm/page_ref: fix build failure for xtensa
Date: Tue,  1 Mar 2016 22:43:13 +0900
Message-Id: <1456839793-31276-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <201603012155.h5NIKpFO%fengguang.wu@intel.com>
References: <201603012155.h5NIKpFO%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patch includes struct page definition to fix build failure on xtensa.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/debug_page_ref.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/debug_page_ref.c b/mm/debug_page_ref.c
index 87e60e8..1aef3d5 100644
--- a/mm/debug_page_ref.c
+++ b/mm/debug_page_ref.c
@@ -1,3 +1,4 @@
+#include <linux/mm_types.h>
 #include <linux/tracepoint.h>
 
 #define CREATE_TRACE_POINTS
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
