Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA666B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:52:57 -0400 (EDT)
Received: by lbbck17 with SMTP id ck17so27178067lbb.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:56 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id k9si11643624lbj.95.2015.10.12.08.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:52:56 -0700 (PDT)
Received: by lbbk10 with SMTP id k10so35199462lbb.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:55 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v7 1/4] arm64: move PGD_SIZE definition to pgalloc.h
Date: Mon, 12 Oct 2015 18:52:57 +0300
Message-Id: <1444665180-301-2-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
2.4.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
