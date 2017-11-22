Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE6F6B026A
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:18 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r12so17264401pgu.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k13si14160054pgo.207.2017.11.22.13.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:17 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 10/62] unicore32: Turn flush_dcache_mmap_lock into a no-op
Date: Wed, 22 Nov 2017 13:06:47 -0800
Message-Id: <20171122210739.29916-11-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Unicore doesn't walk the VMA tree in its flush_dcache_page()
implementation, so has no need to take the tree_lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/unicore32/include/asm/cacheflush.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/unicore32/include/asm/cacheflush.h b/arch/unicore32/include/asm/cacheflush.h
index a5e08e2d5d6d..1d9132b66039 100644
--- a/arch/unicore32/include/asm/cacheflush.h
+++ b/arch/unicore32/include/asm/cacheflush.h
@@ -170,10 +170,8 @@ extern void flush_cache_page(struct vm_area_struct *vma,
 #define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 1
 extern void flush_dcache_page(struct page *);
 
-#define flush_dcache_mmap_lock(mapping)			\
-	spin_lock_irq(&(mapping)->tree_lock)
-#define flush_dcache_mmap_unlock(mapping)		\
-	spin_unlock_irq(&(mapping)->tree_lock)
+#define flush_dcache_mmap_lock(mapping)		do { } while (0)
+#define flush_dcache_mmap_unlock(mapping)	do { } while (0)
 
 #define flush_icache_user_range(vma, page, addr, len)	\
 	flush_dcache_page(page)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
