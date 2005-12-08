From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208113015.6309.56630.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 07/07] Remove page_dup_rmap
Date: Thu,  8 Dec 2005 20:27:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Remove page_dup_rmap.

This patch simply removes page_dup_rmap(). It is not needed anymore.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 include/linux/rmap.h |    2 --
 mm/memory.c          |    1 -
 2 files changed, 3 deletions(-)

--- from-0008/include/linux/rmap.h
+++ to-work/include/linux/rmap.h	2005-12-08 18:14:37.000000000 +0900
@@ -75,8 +75,6 @@ void __anon_vma_link(struct vm_area_stru
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
 
-static inline void page_dup_rmap(struct page *page) {}
-
 int update_page_mapped(struct page *);
 
 /*
--- from-0008/mm/memory.c
+++ to-work/mm/memory.c	2005-12-08 18:17:52.000000000 +0900
@@ -453,7 +453,6 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
 		rss[!!PageAnon(page)]++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
