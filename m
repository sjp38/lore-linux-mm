Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3520B6B0036
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:09 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so2928539pbc.26
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/34] m32r: fix potential NULL-pointer dereference
Date: Thu, 10 Oct 2013 21:05:28 +0300
Message-Id: <1381428359-14843-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hirokazu Takata <takata@linux-m32r.org>

Add missing check for memory allocation fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hirokazu Takata <takata@linux-m32r.org>
---
 arch/m32r/include/asm/pgalloc.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/m32r/include/asm/pgalloc.h b/arch/m32r/include/asm/pgalloc.h
index 0fc7361989..ac4208bcc5 100644
--- a/arch/m32r/include/asm/pgalloc.h
+++ b/arch/m32r/include/asm/pgalloc.h
@@ -43,6 +43,8 @@ static __inline__ pgtable_t pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 
+	if (!pte)
+		return NULL;
 	pgtable_page_ctor(pte);
 	return pte;
 }
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
