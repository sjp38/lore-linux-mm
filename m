Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41F72440941
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 03:12:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p1so109323557pfl.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 00:12:37 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 1si1160238plh.77.2017.07.15.00.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 00:12:36 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id j186so13009925pge.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 00:12:35 -0700 (PDT)
From: Kinoshita Kazumi <e145702@ie.u-ryukyu.ac.jp>
Subject: [PATCH] fix typo
Date: Sat, 15 Jul 2017 16:12:03 +0900
Message-Id: <20170715071203.63447-1-e145702@ie.u-ryukyu.ac.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kinoshita Kazumi <e145702@ie.u-ryukyu.ac.jp>

Signed-off-by: Kinoshita Kazumi <e145702@ie.u-ryukyu.ac.jp>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f19efcf..f7ef742 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -526,7 +526,7 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 	unsigned long nr_pages = 0;
 	struct vm_area_struct *vma;
 
-	/* Find first overlaping mapping */
+	/* Find first overlapping mapping */
 	vma = find_vma_intersection(mm, addr, end);
 	if (!vma)
 		return 0;
-- 
2.10.1 (Apple Git-78)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
