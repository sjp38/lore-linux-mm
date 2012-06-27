Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 8AC866B006E
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:37 -0400 (EDT)
Message-Id: <20120627212831.724476627@chello.nl>
Date: Wed, 27 Jun 2012 23:15:56 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 16/20] mm, avr32: Convert avr32 to generic tlb
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=avr32-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/avr32/Kconfig           |    1 +
 arch/avr32/include/asm/tlb.h |    6 ------
 2 files changed, 1 insertion(+), 6 deletions(-)
--- a/arch/avr32/Kconfig
+++ b/arch/avr32/Kconfig
@@ -14,6 +14,7 @@ config AVR32
 	select ARCH_HAVE_CUSTOM_GPIO_H
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_CLOCKEVENTS
+	select HAVE_MMU_GATHER_RANGE
 	help
 	  AVR32 is a high-performance 32-bit RISC microprocessor core,
 	  designed for cost-sensitive embedded applications, with particular
--- a/arch/avr32/include/asm/tlb.h
+++ b/arch/avr32/include/asm/tlb.h
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
