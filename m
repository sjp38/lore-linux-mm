Message-Id: <200405222213.i4MMDFr14447@mail.osdl.org>
Subject: [patch 48/57] rmap 32 zap_pmd_range wrap
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:12:40 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

From: Andrea Arcangeli <andrea@suse.de>

zap_pmd_range, alone of all those page_range loops, lacks the check for
whether address wrapped.  Hugh is in doubt as to whether this makes any
difference to any config on any arch, but eager to fix the odd one out.


---

 25-akpm/mm/memory.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/memory.c~rmap-32-zap_pmd_range-wrap mm/memory.c
--- 25/mm/memory.c~rmap-32-zap_pmd_range-wrap	2004-05-22 14:56:29.082670288 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:35.970259056 -0700
@@ -449,7 +449,7 @@ static void zap_pmd_range(struct mmu_gat
 		zap_pte_range(tlb, pmd, address, end - address, details);
 		address = (address + PMD_SIZE) & PMD_MASK; 
 		pmd++;
-	} while (address < end);
+	} while (address && (address < end));
 }
 
 static void unmap_page_range(struct mmu_gather *tlb,

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
