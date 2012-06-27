Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 73F9D6B007D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:48 -0400 (EDT)
Message-Id: <20120627212831.940876924@chello.nl>
Date: Wed, 27 Jun 2012 23:15:59 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 19/20] mm, sparc32: Convert sparc32 to generic tlb
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=sparc32-mmu_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/sparc/Kconfig              |    1 +
 arch/sparc/include/asm/tlb_32.h |   10 ----------
 2 files changed, 1 insertion(+), 10 deletions(-)
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -41,6 +41,7 @@ config SPARC32
 	def_bool !64BIT
 	select GENERIC_ATOMIC64
 	select CLZ_TAB
+	select HAVE_MMU_GATHER_RANGE
 
 config SPARC64
 	def_bool 64BIT
--- a/arch/sparc/include/asm/tlb_32.h
+++ b/arch/sparc/include/asm/tlb_32.h
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
