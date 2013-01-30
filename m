Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EB1F16B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 04:41:16 -0500 (EST)
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: [PATCH] mm/nommu: Use get_nr_swap_pages()
Date: Wed, 30 Jan 2013 10:41:12 +0100
Message-Id: <1359538872-29910-1-git-send-email-thierry.reding@avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This fixes a build failure introduced by commit ac07b1f ("swap: add per-
partition lock for swapfile") which changed the access pattern of the
nr_swap_pages variable but failed to update the no-MMU case.

Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
---
 mm/nommu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index b7fdaa7..bf74898 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1906,7 +1906,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 */
 		free -= global_page_state(NR_SHMEM);
 
-		free += nr_swap_pages;
+		free += get_nr_swap_pages();
 
 		/*
 		 * Any slabs which are created with the
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
