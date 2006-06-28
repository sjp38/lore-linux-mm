From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 28 Jun 2006 22:17:57 +0200
Message-Id: <20060628201757.8792.1177.sendpatchset@lappy>
In-Reply-To: <20060628201702.8792.69638.sendpatchset@lappy>
References: <20060628201702.8792.69638.sendpatchset@lappy>
Subject: [PATCH 5/6] mm: small cleanup of install_page()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Smallish cleanup to install_page(), could save a memory read
(haven't checked the asm output) and sure looks nicer.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

---
 mm/fremap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: 2.6-mm/mm/fremap.c
===================================================================
--- 2.6-mm.orig/mm/fremap.c	2006-06-19 16:20:52.000000000 +0200
+++ 2.6-mm/mm/fremap.c	2006-06-19 16:20:57.000000000 +0200
@@ -79,9 +79,9 @@ int install_page(struct mm_struct *mm, s
 		inc_mm_counter(mm, file_rss);
 
 	flush_icache_page(vma, page);
-	set_pte_at(mm, addr, pte, mk_pte(page, prot));
+	pte_val = mk_pte(page, prot);
+	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
-	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
 	lazy_mmu_prot_update(pte_val);
 	err = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
