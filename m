Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 96F0B82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:08 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so237533840pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id c90si10337078pfd.233.2016.03.20.11.41.53
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 71/71] mm: drop PAGE_CACHE_* and page_cache_{get,release} definition
Date: Sun, 20 Mar 2016 21:41:18 +0300
Message-Id: <1458499278-1516-72-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 819f89ca6745..5372488c5da0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -86,21 +86,6 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 				(__force unsigned long)mask;
 }
 
-/*
- * The page cache can be done in larger chunks than
- * one page, because it allows for more efficient
- * throughput (it can then be mapped into user
- * space in smaller chunks for same flexibility).
- *
- * Or rather, it _will_ be done in larger chunks.
- */
-#define PAGE_CACHE_SHIFT	PAGE_SHIFT
-#define PAGE_CACHE_SIZE		PAGE_SIZE
-#define PAGE_CACHE_MASK		PAGE_MASK
-#define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
-
-#define page_cache_get(page)		get_page(page)
-#define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, bool cold);
 
 /*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
