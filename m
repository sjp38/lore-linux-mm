Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB2A6B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:44:51 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id m15so701162wgh.26
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:44:50 -0700 (PDT)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id b10si1593638wic.34.2014.10.02.08.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:44:50 -0700 (PDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so3606652wgg.32
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:44:50 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: highmem remove 3 errors
Date: Thu,  2 Oct 2014 16:44:45 +0100
Message-Id: <1412264685-3368-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: akpm@linux-foundation.org, jcmvbkbc@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

pointers should be foo *bar or (foo *)

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/highmem.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 123bcd3..f6dae74 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -130,7 +130,7 @@ unsigned int nr_free_highpages (void)
 static int pkmap_count[LAST_PKMAP];
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
 
-pte_t * pkmap_page_table;
+pte_t *pkmap_page_table;
 
 /*
  * Most architectures have no use for kmap_high_get(), so let's abstract
@@ -291,7 +291,7 @@ void *kmap_high(struct page *page)
 	pkmap_count[PKMAP_NR(vaddr)]++;
 	BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 2);
 	unlock_kmap();
-	return (void*) vaddr;
+	return (void *) vaddr;
 }
 
 EXPORT_SYMBOL(kmap_high);
@@ -318,7 +318,7 @@ void *kmap_high_get(struct page *page)
 		pkmap_count[PKMAP_NR(vaddr)]++;
 	}
 	unlock_kmap_any(flags);
-	return (void*) vaddr;
+	return (void *) vaddr;
 }
 #endif
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
