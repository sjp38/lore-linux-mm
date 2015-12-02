Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 02DC56B0256
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:13:27 -0500 (EST)
Received: by pacej9 with SMTP id ej9so53658722pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:26 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id tg4si7556330pab.100.2015.12.02.15.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:13:23 -0800 (PST)
Received: by padhx2 with SMTP id hx2so53625632pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:23 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH V2 3/7] x86: mm/gup: add gup trace points
Date: Wed,  2 Dec 2015 14:53:29 -0800
Message-Id: <1449096813-22436-4-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
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
