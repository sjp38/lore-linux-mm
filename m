Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA9282F5F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 18:23:05 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so75728847lbb.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:23:04 -0700 (PDT)
Received: from mail-la0-x243.google.com (mail-la0-x243.google.com. [2a00:1450:4010:c03::243])
        by mx.google.com with ESMTPS id l5si6623859lbs.78.2015.08.10.15.23.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 15:23:03 -0700 (PDT)
Received: by lahi9 with SMTP id i9so2445234lah.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:23:02 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v5 4/6] arm64: move PGD_SIZE definition to pgalloc.h
Date: Tue, 11 Aug 2015 05:18:17 +0300
Message-Id: <1439259499-13913-5-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This will be used by KASAN latter.

Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
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
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
