Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3486B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 07:18:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g14so18029481pgu.9
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 04:18:35 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id x13si1547531pgq.222.2017.07.18.04.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 04:18:33 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id z1so2481193pgs.0
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 04:18:33 -0700 (PDT)
From: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Subject: [PATCH] mm: Fixing checkpatch errors
Date: Tue, 18 Jul 2017 16:48:23 +0530
Message-Id: <1500376703-2876-1-git-send-email-pushkar.iit@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Pushkar Jambhlekar <pushkar.iit@gmail.com>

checkpath reports error for declaring the way code is handling pointer. Fixing those errors

Signed-off-by: Pushkar Jambhlekar <pushkar.iit@gmail.com>
---
 mm/highmem.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 50b4ca6..20ffba3 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -126,7 +126,7 @@ unsigned int nr_free_highpages (void)
 static int pkmap_count[LAST_PKMAP];
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
 
-pte_t * pkmap_page_table;
+pte_t *pkmap_page_table;
 
 /*
  * Most architectures have no use for kmap_high_get(), so let's abstract
@@ -287,7 +287,7 @@ void *kmap_high(struct page *page)
 	pkmap_count[PKMAP_NR(vaddr)]++;
 	BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 2);
 	unlock_kmap();
-	return (void*) vaddr;
+	return (void *) vaddr;
 }
 
 EXPORT_SYMBOL(kmap_high);
@@ -314,7 +314,7 @@ void *kmap_high_get(struct page *page)
 		pkmap_count[PKMAP_NR(vaddr)]++;
 	}
 	unlock_kmap_any(flags);
-	return (void*) vaddr;
+	return (void *) vaddr;
 }
 #endif
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
