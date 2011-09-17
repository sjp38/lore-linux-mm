Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DC8C39000BD
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 09:37:15 -0400 (EDT)
From: Li Haifeng <omycle@gmail.com>
Subject: [PATCH] mm: Fix the comment the kunmap_high() 
Date: Sat, 17 Sep 2011 21:36:55 +0800
Message-Id: <1316266615-10212-1-git-send-email-omycle@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Haifeng <omycle@gmail.com>

Fix the comment of kunmap_high()

Signed-off-by: Li Haifeng <omycle@gmail.com>
---
 mm/highmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 5ef672c..7b2e544 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -250,7 +250,7 @@ void *kmap_high_get(struct page *page)
 #endif
 
 /**
- * kunmap_high - map a highmem page into memory
+ * kunmap_high - unmap a highmem page from memory
  * @page: &struct page to unmap
  *
  * If ARCH_NEEDS_KMAP_HIGH_GET is not defined then this may be called
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
