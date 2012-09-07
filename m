Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 1AA186B0068
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 20:55:37 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: Fix compile warning of mmotm-2012-09-06-16-46
Date: Fri,  7 Sep 2012 09:57:10 +0900
Message-Id: <1346979430-23110-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>

When I compiled today, I met following warning.
Correct it.

mm/memory.c: In function a??copy_page_rangea??:
include/linux/mmu_notifier.h:235:38: warning: a??mmun_enda?? may be used uninitialized in this function [-Wuninitialized]
mm/memory.c:1043:16: note: a??mmun_enda?? was declared here
include/linux/mmu_notifier.h:235:38: warning: a??mmun_starta?? may be used uninitialized in this function [-Wuninitialized]
mm/memory.c:1042:16: note: a??mmun_starta?? was declared here
  LD      mm/built-in.o

Cc: Sagi Grimberg <sagig@mellanox.com>
Cc: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 10e9b38..d000449 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1039,8 +1039,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	unsigned long uninitialized_var(mmun_start);	/* For mmu_notifiers */
+	unsigned long uninitialized_var(mmun_end);	/* For mmu_notifiers */
 	int ret;
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
