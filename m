Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 045676B003C
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 00:19:36 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so227075pde.13
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 21:19:36 -0700 (PDT)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id eg2si7808637pac.305.2014.04.26.21.19.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 26 Apr 2014 21:19:35 -0700 (PDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so4599200pbc.34
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 21:19:35 -0700 (PDT)
Message-ID: <535C854C.1070105@gmail.com>
Date: Sun, 27 Apr 2014 12:19:24 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: update the comment for high_memory
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, peterz@infradead.org, mingo@kernel.org, riel@redhat.com, mgorman@suse.de, hannes@cmpxchg.org, hughd@google.com, linux-mm@kvack.org


The system variable is not used for x86 only now. Remove the
"x86" strings.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 93e332d..1615a64 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -85,14 +85,13 @@ EXPORT_SYMBOL(mem_map);
 #endif

 /*
- * A number of key systems in x86 including ioremap() rely on the assumption
- * that high_memory defines the upper bound on direct map memory, then end
- * of ZONE_NORMAL.  Under CONFIG_DISCONTIG this means that max_low_pfn and
+ * A number of key systems including ioremap() rely on the assumption that
+ * high_memory defines the upper bound on direct map memory, then end of
+ * ZONE_NORMAL.  Under CONFIG_DISCONTIG this means that max_low_pfn and
  * highstart_pfn must be the same; there must be no gap between ZONE_NORMAL
  * and ZONE_HIGHMEM.
  */
 void * high_memory;
-
 EXPORT_SYMBOL(high_memory);

 /*
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
