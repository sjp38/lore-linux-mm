Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A125D6B0003
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 07:45:18 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t22-v6so6265833pfi.13
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 04:45:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v68-v6sor5298817pfv.20.2018.11.04.04.45.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Nov 2018 04:45:17 -0800 (PST)
From: Yangtao Li <tiny.windzz@gmail.com>
Subject: [PATCH] mm: mmap: remove unnecessary unlikely()
Date: Sun,  4 Nov 2018 07:44:56 -0500
Message-Id: <20181104124456.3424-1-tiny.windzz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, rientjes@google.com, linux@dominikbrodowski.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yangtao Li <tiny.windzz@gmail.com>

WARN_ON() already contains an unlikely(), so it's not necessary to use
unlikely.

Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
---
 mm/mmap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6c04292e16a7..2077008ade0c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2965,10 +2965,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
-		WARN_ON(1);
+	if (WARN_ON(down_read_trylock(&mm->mmap_sem)))
 		up_read(&mm->mmap_sem);
-	}
 #endif
 }
 
-- 
2.17.0
