Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2718D003C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:48:52 -0500 (EST)
Message-Id: <20110307172207.242624219@chello.nl>
Date: Mon, 07 Mar 2011 18:14:01 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 11/15] mm, avr32: Convert avr32 to generic tlb
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=avr32-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>

Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/avr32/Kconfig           |    1 +
 arch/avr32/include/asm/tlb.h |    6 ------
 2 files changed, 1 insertion(+), 6 deletions(-)

Index: linux-2.6/arch/avr32/Kconfig
===================================================================
--- linux-2.6.orig/arch/avr32/Kconfig
+++ linux-2.6/arch/avr32/Kconfig
@@ -7,6 +7,7 @@ config AVR32
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
+	select HAVE_MMU_GATHER_RANGE
 	help
 	  AVR32 is a high-performance 32-bit RISC microprocessor core,
 	  designed for cost-sensitive embedded applications, with particular
Index: linux-2.6/arch/avr32/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/avr32/include/asm/tlb.h
+++ linux-2.6/arch/avr32/include/asm/tlb.h
@@ -8,12 +8,6 @@
 #ifndef __ASM_AVR32_TLB_H
 #define __ASM_AVR32_TLB_H
 
-#define tlb_start_vma(tlb, vma) \
-	flush_cache_range(vma, vma->vm_start, vma->vm_end)
-
-#define tlb_end_vma(tlb, vma) \
-	flush_tlb_range(vma, vma->vm_start, vma->vm_end)
-
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while(0)
 
 #include <asm-generic/tlb.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
