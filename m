Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3906B006E
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 12:06:08 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id b13so3550822wgh.12
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:06:08 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id bk8si1635255wib.57.2014.10.02.09.06.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 09:06:07 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id n3so4570751wiv.15
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:06:07 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: highmem fix pointers
Date: Thu,  2 Oct 2014 17:06:00 +0100
Message-Id: <1412265960-3948-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: jcmvbkbc@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

pointers should be foo *bar

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/highmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 123bcd3..7543624 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -130,7 +130,7 @@ unsigned int nr_free_highpages (void)
 static int pkmap_count[LAST_PKMAP];
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
 
-pte_t * pkmap_page_table;
+pte_t *pkmap_page_table;
 
 /*
  * Most architectures have no use for kmap_high_get(), so let's abstract
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
