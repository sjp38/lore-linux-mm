Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6BC58D003E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:43 -0500 (EST)
Message-Id: <20110307172207.445811237@chello.nl>
Date: Mon, 07 Mar 2011 18:14:04 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 14/15] mm, sparc32: Convert sparc32 to generic tlb
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=sparc32-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/sparc/Kconfig              |    1 +
 arch/sparc/include/asm/tlb_32.h |   10 ----------
 2 files changed, 1 insertion(+), 10 deletions(-)

Index: linux-2.6/arch/sparc/Kconfig
===================================================================
--- linux-2.6.orig/arch/sparc/Kconfig
+++ linux-2.6/arch/sparc/Kconfig
@@ -25,6 +25,7 @@ config SPARC
 	select HAVE_DMA_ATTRS
 	select HAVE_DMA_API_DEBUG
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_MMU_GATHER_RANGE
 
 config SPARC32
 	def_bool !64BIT
Index: linux-2.6/arch/sparc/include/asm/tlb_32.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlb_32.h
+++ linux-2.6/arch/sparc/include/asm/tlb_32.h
@@ -1,16 +1,6 @@
 #ifndef _SPARC_TLB_H
 #define _SPARC_TLB_H
 
-#define tlb_start_vma(tlb, vma) \
-do {								\
-	flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
-} while (0)
-
-#define tlb_end_vma(tlb, vma) \
-do {								\
-	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
-} while (0)
-
 #define __tlb_remove_tlb_entry(tlb, pte, address) \
 	do { } while (0)
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
