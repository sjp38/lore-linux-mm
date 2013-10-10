Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 00BEA6B0036
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:07 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3108353pab.34
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 02/34] cris: fix potential NULL-pointer dereference
Date: Thu, 10 Oct 2013 21:05:27 +0300
Message-Id: <1381428359-14843-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>

Add missing check for memory allocation fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
---
 arch/cris/include/asm/pgalloc.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgalloc.h
index 6da975db11..d9504d38c2 100644
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -32,6 +32,8 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addres
 {
 	struct page *pte;
 	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
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
