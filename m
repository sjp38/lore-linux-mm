Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id DC19E6B005A
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 06:49:22 -0500 (EST)
Date: Mon, 17 Dec 2012 11:49:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Suppress mm/memory.o warning on older compilers if
 !CONFIG_NUMA_BALANCING
Message-ID: <20121217114917.GF9887@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>

The kbuild test robot reported the following after the merge of Automatic
NUMA Balancing when cross-compiling for avr32.

mm/memory.c: In function 'do_pmd_numa_page':
mm/memory.c:3593: warning: no return statement in function returning non-void

The code is unreachable but the avr32 cross-compiler was not new enough
to know that. This patch suppresses the warning.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index e6a3b93..23f1fdf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3590,6 +3590,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		     unsigned long addr, pmd_t *pmdp)
 {
 	BUG();
+	return 0;
 }
 #endif /* CONFIG_NUMA_BALANCING */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
