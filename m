Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9627E6B0009
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:26:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u68so7421107pfk.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:26:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g23si163089pfb.87.2018.03.13.06.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:26:43 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 03/61] arm64: Turn flush_dcache_mmap_lock into a no-op
Date: Tue, 13 Mar 2018 06:25:41 -0700
Message-Id: <20180313132639.17387-4-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

ARM64 doesn't walk the VMA tree in its flush_dcache_page()
implementation, so has no need to take the tree_lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/include/asm/cacheflush.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/cacheflush.h b/arch/arm64/include/asm/cacheflush.h
index 7dfcec4700fe..0094c6653b06 100644
--- a/arch/arm64/include/asm/cacheflush.h
+++ b/arch/arm64/include/asm/cacheflush.h
@@ -140,10 +140,8 @@ static inline void __flush_icache_all(void)
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
