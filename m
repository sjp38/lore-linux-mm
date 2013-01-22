Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 1C5B96B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:55:56 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: drop unused memclear_highpage_flush()
Date: Tue, 22 Jan 2013 13:56:41 +0200
Message-Id: <1358855801-25724-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Cong Wang <amwang@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/highmem.h |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index ef788b5..7fb31da 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -219,12 +219,6 @@ static inline void zero_user(struct page *page,
 	zero_user_segments(page, start, start + size, 0, 0);
 }
 
-static inline void __deprecated memclear_highpage_flush(struct page *page,
-			unsigned int offset, unsigned int size)
-{
-	zero_user(page, offset, size);
-}
-
 #ifndef __HAVE_ARCH_COPY_USER_HIGHPAGE
 
 static inline void copy_user_highpage(struct page *to, struct page *from,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
