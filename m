Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C35B46B0258
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:42:38 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so16240941pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:42:38 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id fo7si21881391pac.56.2015.07.24.09.42.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 09:42:36 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS000K1U3QVRJ60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jul 2015 17:42:31 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 4/7] arm64: move PGD_SIZE definition to pgalloc.h
Date: Fri, 24 Jul 2015 19:41:56 +0300
Message-id: <1437756119-12817-5-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>

This will be used by KASAN latter.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/include/asm/pgalloc.h | 1 +
 arch/arm64/mm/pgd.c              | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index 7642056..c150539 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -27,6 +27,7 @@
 #define check_pgt_cache()		do { } while (0)
 
 #define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
 
 #if CONFIG_PGTABLE_LEVELS > 2
 
diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
index 71ca104..cb3ba1b 100644
--- a/arch/arm64/mm/pgd.c
+++ b/arch/arm64/mm/pgd.c
@@ -28,8 +28,6 @@
 
 #include "mm.h"
 
-#define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
-
 static struct kmem_cache *pgd_cache;
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
