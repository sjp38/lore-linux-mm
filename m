Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B0EA66B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 02:06:33 -0400 (EDT)
Received: by dadi14 with SMTP id i14so521083dad.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 23:06:33 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] mm: adjust final #endif position in mm/internal.h
Date: Tue, 21 Aug 2012 23:06:21 -0700
Message-Id: <1345615581-2653-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Trivial patch: make sure the #endif that terminates the standard
#ifndef / #define / #endif construct gets labeled, and gets positioned
at the end of the file as is normally the case.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/internal.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 2ba87fbfb75b..aea3b7c45854 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -333,7 +333,6 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 #define ZONE_RECLAIM_FULL	-1
 #define ZONE_RECLAIM_SOME	0
 #define ZONE_RECLAIM_SUCCESS	1
-#endif
 
 extern int hwpoison_filter(struct page *p);
 
@@ -347,3 +346,5 @@ extern u32 hwpoison_filter_enable;
 extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long,
         unsigned long, unsigned long);
+
+#endif	/* __MM_INTERNAL_H */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
