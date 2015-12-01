Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 243D76B0257
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:26:06 -0500 (EST)
Received: by pacej9 with SMTP id ej9so19931094pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:05 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id yi10si282988pab.15.2015.12.01.15.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:26:03 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so19845684pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:02 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 3/7] x86: mm/gup: add gup trace points
Date: Tue,  1 Dec 2015 15:06:13 -0800
Message-Id: <1449011177-30686-4-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/x86/mm/gup.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index ae9a37b..ed6cca9 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -10,6 +10,9 @@
 #include <linux/highmem.h>
 #include <linux/swap.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/gup.h>>
+
 #include <asm/pgtable.h>
 
 static inline pte_t gup_get_pte(pte_t *ptep)
@@ -270,6 +273,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -342,6 +347,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		goto slow_irqon;
 #endif
 
+	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
