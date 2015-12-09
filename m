Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A43576B0256
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:42:27 -0500 (EST)
Received: by pabur14 with SMTP id ur14so35923433pab.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:27 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id xk9si15106192pab.38.2015.12.09.13.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:42:24 -0800 (PST)
Received: by pacej9 with SMTP id ej9so35940459pac.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:24 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v5 3/7] x86: mm/gup: add gup trace points
Date: Wed,  9 Dec 2015 13:22:27 -0800
Message-Id: <1449696151-4195-4-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
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
 arch/x86/mm/gup.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index ae9a37b..df5f3ab 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -12,6 +12,8 @@
 
 #include <asm/pgtable.h>
 
+#include <trace/events/gup.h>
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #ifndef CONFIG_X86_PAE
@@ -270,6 +272,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 					(void __user *)start, len)))
 		return 0;
 
+	trace_gup_get_user_pages_fast(start, nr_pages);
+
 	/*
 	 * XXX: batch / limit 'nr', to avoid large irq off latency
 	 * needs some instrumenting to determine the common sizes used by
@@ -373,6 +377,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
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
