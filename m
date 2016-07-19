Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A92B6B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 22:08:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so10036362pfg.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:08:23 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id r8si29829615pav.187.2016.07.18.19.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 19:08:22 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id h186so342894pfg.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:08:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: hugetlb: remove incorrect comment
Date: Tue, 19 Jul 2016 11:08:18 +0900
Message-Id: <1468894098-12099-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhan Chen <zhanc1@andrew.cmu.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

dequeue_hwpoisoned_huge_page() can be called without page lock hold,
so let's remove incorrect comment.

Reported-by: Zhan Chen <zhanc1@andrew.cmu.edu>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git v4.7-rc7/mm/hugetlb.c v4.7-rc7_patched/mm/hugetlb.c
index c1f3c0b..26f735c 100644
--- v4.7-rc7/mm/hugetlb.c
+++ v4.7-rc7_patched/mm/hugetlb.c
@@ -4401,7 +4401,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 
 /*
  * This function is called from memory failure code.
- * Assume the caller holds page lock of the head page.
  */
 int dequeue_hwpoisoned_huge_page(struct page *hpage)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
