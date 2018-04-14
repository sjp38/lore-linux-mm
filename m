Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 644786B0006
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f3-v6so7023972plf.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g67si6147312pfk.90.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 1/8] mm: Rename PF argument to modify
Date: Fri, 13 Apr 2018 21:31:38 -0700
Message-Id: <20180414043145.3953-2-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

I find the word 'enforce' misleading; this flag is set for Set and Clear
and clear for Test, so the word 'modify' seems more descriptive than
'enforce'.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/page-flags.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e34a27727b9a..593a5505bbb4 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -188,16 +188,16 @@ static inline int PagePoisoned(const struct page *page)
 #define PF_POISONED_CHECK(page) ({					\
 		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
 		page; })
-#define PF_ANY(page, enforce)	PF_POISONED_CHECK(page)
-#define PF_HEAD(page, enforce)	PF_POISONED_CHECK(compound_head(page))
-#define PF_ONLY_HEAD(page, enforce) ({					\
+#define PF_ANY(page, modify)	PF_POISONED_CHECK(page)
+#define PF_HEAD(page, modify)	PF_POISONED_CHECK(compound_head(page))
+#define PF_ONLY_HEAD(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
 		PF_POISONED_CHECK(page); })
-#define PF_NO_TAIL(page, enforce) ({					\
-		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
+#define PF_NO_TAIL(page, modify) ({					\
+		VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);	\
 		PF_POISONED_CHECK(compound_head(page)); })
-#define PF_NO_COMPOUND(page, enforce) ({				\
-		VM_BUG_ON_PGFLAGS(enforce && PageCompound(page), page);	\
+#define PF_NO_COMPOUND(page, modify) ({				\
+		VM_BUG_ON_PGFLAGS(modify && PageCompound(page), page);	\
 		PF_POISONED_CHECK(page); })
 
 /*
-- 
2.16.3
