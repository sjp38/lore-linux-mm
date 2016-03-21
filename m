Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 85F396B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:08:38 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id n5so262538501pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:08:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o126si16660924pfo.29.2016.03.21.05.08.37
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 05:08:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] mm: drop PAGE_CACHE_* and page_cache_{get,release} definition
Date: Mon, 21 Mar 2016 15:06:38 +0300
Message-Id: <1458561998-126622-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

All users gone. We can remove these macros.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index b3fc0370c14f..7e1ab155c67c 100644
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
