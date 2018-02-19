Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 619E16B0055
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:07 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x2so6693399plv.16
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d2si5764178pgo.342.2018.02.19.11.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:06 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 03/61] arm64: Turn flush_dcache_mmap_lock into a no-op
Date: Mon, 19 Feb 2018 11:44:58 -0800
Message-Id: <20180219194556.6575-4-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

ARM64 doesn't walk the VMA tree in its flush_dcache_page()
implementation, so has no need to take the tree_lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/include/asm/cacheflush.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/cacheflush.h b/arch/arm64/include/asm/cacheflush.h
index bef9f418f089..550b0abea953 100644
--- a/arch/arm64/include/asm/cacheflush.h
+++ b/arch/arm64/include/asm/cacheflush.h
@@ -137,10 +137,8 @@ static inline void __flush_icache_all(void)
 	dsb(ish);
 }
 
-#define flush_dcache_mmap_lock(mapping) \
-	spin_lock_irq(&(mapping)->tree_lock)
-#define flush_dcache_mmap_unlock(mapping) \
-	spin_unlock_irq(&(mapping)->tree_lock)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 
 /*
  * We don't appear to need to do anything here.  In fact, if we did, we'd
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
