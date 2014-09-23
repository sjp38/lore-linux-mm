Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD4F6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 22:54:26 -0400 (EDT)
Received: by mail-yk0-f178.google.com with SMTP id 200so1754264ykr.23
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 19:54:26 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c32si8031947yha.68.2014.09.22.19.54.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 19:54:26 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: build error in dump_mm without CONFIG_COMPACTION
Date: Mon, 22 Sep 2014 22:54:15 -0400
Message-Id: <1411440855-27430-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

In the case of CONFIG_NUMA_BALANCING set and CONFIG_COMPACTION isn't,
we'd fail to put a "," at the end of the formatting string and cause
a build failure.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/debug.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 544d8f6..8fbc417 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -192,9 +192,9 @@ void dump_mm(const struct mm_struct *mm)
 		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"
 #endif
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-		"tlb_flush_pending %d\n",
+		"tlb_flush_pending %d\n"
 #endif
-		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
+		, mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
 #ifdef CONFIG_MMU
 		mm->get_unmapped_area,
 #endif
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
