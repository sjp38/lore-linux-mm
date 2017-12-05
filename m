Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8D56B0069
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 10:15:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 200so365955pge.12
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 07:15:41 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 3si196000pgi.649.2017.12.05.07.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 07:15:40 -0800 (PST)
From: Hareesh Gundu <hareeshg@codeaurora.org>
Subject: [PATCH] mm: Export unmapped_area*() functions
Date: Tue,  5 Dec 2017 20:45:27 +0530
Message-Id: <1512486927-32349-1-git-send-email-hareeshg@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, hareeshg@codeaurora.org

Add EXPORT_SYMBOL to unmapped_area()
and unmapped_area_topdown(). So they
are usable from modules.

Signed-off-by: Hareesh Gundu <hareeshg@codeaurora.org>
---
 mm/mmap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 924839f..aba4f51 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1882,6 +1882,7 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 	VM_BUG_ON(gap_start + info->length > gap_end);
 	return gap_start;
 }
+EXPORT_SYMBOL(unmapped_area);
 
 unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 {
@@ -1981,6 +1982,7 @@ unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 	VM_BUG_ON(gap_end < gap_start);
 	return gap_end;
 }
+EXPORT_SYMBOL(unmapped_area_topdown);
 
 /* Get an address range which is currently unmapped.
  * For shmat() with addr=0.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
