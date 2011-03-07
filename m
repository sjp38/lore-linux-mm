Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 129AD8D003C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:17 -0500 (EST)
Message-Id: <20110307172207.309211374@chello.nl>
Date: Mon, 07 Mar 2011 18:14:02 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 12/15] mm, mips: Convert mips to generic tlb
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=mips-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ralf Baechle <ralf@linux-mips.org>

Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/mips/Kconfig           |    1 +
 arch/mips/include/asm/tlb.h |   10 ----------
 2 files changed, 1 insertion(+), 10 deletions(-)

Index: linux-2.6/arch/mips/Kconfig
===================================================================
--- linux-2.6.orig/arch/mips/Kconfig
+++ linux-2.6/arch/mips/Kconfig
@@ -22,6 +22,7 @@ config MIPS
 	select HAVE_GENERIC_HARDIRQS
 	select GENERIC_IRQ_PROBE
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_MMU_GATHER_RANGE
 
 menu "Machine selection"
 
Index: linux-2.6/arch/mips/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/mips/include/asm/tlb.h
+++ linux-2.6/arch/mips/include/asm/tlb.h
@@ -1,16 +1,6 @@
 #ifndef __ASM_TLB_H
 #define __ASM_TLB_H
 
-/*
- * MIPS doesn't need any special per-pte or per-vma handling, except
- * we need to flush cache for area to be unmapped.
- */
-#define tlb_start_vma(tlb, vma) 				\
-	do {							\
-		if (!tlb->fullmm)				\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	}  while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 #include <asm-generic/tlb.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
