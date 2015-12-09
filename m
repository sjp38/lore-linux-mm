Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AD4D16B0259
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:42:33 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so35725325pac.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:33 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id va5si15094369pac.165.2015.12.09.13.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:42:27 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so35952989pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:27 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v5 6/7] sh: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 13:22:30 -0800
Message-Id: <1449696151-4195-7-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, linux-sh@vger.kernel.org

Cc: linux-sh@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/sh/mm/gup.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
index e7af6a6..dc80480 100644
--- a/arch/sh/mm/gup.c
+++ b/arch/sh/mm/gup.c
@@ -14,6 +14,8 @@
 #include <linux/highmem.h>
 #include <asm/pgtable.h>
 
+#include <trace/events/gup.h>
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #ifndef CONFIG_X2TLB
@@ -178,6 +180,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	/*
 	 * This doesn't prevent pagetable teardown, but does prevent
 	 * the pagetables and pages from being freed.
@@ -244,6 +248,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_enable();
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
 	return nr;
 
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
