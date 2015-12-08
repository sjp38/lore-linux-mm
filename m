Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 295B16B025A
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 15:00:08 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so16921230pac.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:00:07 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id b8si7062639pas.185.2015.12.08.12.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 12:00:00 -0800 (PST)
Received: by pacwq6 with SMTP id wq6so16845762pac.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:00:00 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v3 7/7] sparc64: mm/gup: add gup trace points
Date: Tue,  8 Dec 2015 11:39:55 -0800
Message-Id: <1449603595-718-8-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org

Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/sparc/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 2e5c4fc..d364cc6 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -12,6 +12,9 @@
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -174,6 +177,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
+
 	local_irq_save(flags);
 	pgdp = pgd_offset(mm, addr);
 	do {
@@ -236,6 +241,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	local_irq_enable();
 
+	trace_gup_get_user_pages_fast(start, (unsigned long) nr_pages);
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
