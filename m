Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEFBC6B0261
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u5so348751210pgi.7
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:40 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r7si44810019ple.282.2016.12.26.17.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 04/29] arch, mm: convert all architectures to use 5level-fixup.h
Date: Tue, 27 Dec 2016 04:53:48 +0300
Message-Id: <20161227015413.187403-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If the architecture uses 4level-fixup.h we don't need to do anything as
it includes 5level-fixup.h.

If the architecture uses pgtable-nop*d.h, define __ARCH_USE_5LEVEL_HACK
before inclusion of the header. It makes asm-generic code to use
5level-fixup.h.

If the architecture has 4-level paging or folds levels on its own,
include 5level-fixup.h directly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arc/include/asm/hugepage.h                  | 1 +
 arch/arc/include/asm/pgtable.h                   | 1 +
 arch/arm/include/asm/pgtable.h                   | 1 +
 arch/arm64/include/asm/pgtable-types.h           | 4 ++++
 arch/avr32/include/asm/pgtable-2level.h          | 1 +
 arch/cris/include/asm/pgtable.h                  | 1 +
 arch/frv/include/asm/pgtable.h                   | 1 +
 arch/h8300/include/asm/pgtable.h                 | 1 +
 arch/hexagon/include/asm/pgtable.h               | 1 +
 arch/ia64/include/asm/pgtable.h                  | 2 ++
 arch/metag/include/asm/pgtable.h                 | 1 +
 arch/mips/include/asm/pgtable-32.h               | 1 +
 arch/mips/include/asm/pgtable-64.h               | 1 +
 arch/mn10300/include/asm/page.h                  | 1 +
 arch/nios2/include/asm/pgtable.h                 | 1 +
 arch/openrisc/include/asm/pgtable.h              | 1 +
 arch/powerpc/include/asm/book3s/32/pgtable.h     | 1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h     | 2 ++
 arch/powerpc/include/asm/nohash/32/pgtable.h     | 1 +
 arch/powerpc/include/asm/nohash/64/pgtable-4k.h  | 3 +++
 arch/powerpc/include/asm/nohash/64/pgtable-64k.h | 1 +
 arch/s390/include/asm/pgtable.h                  | 1 +
 arch/score/include/asm/pgtable.h                 | 1 +
 arch/sh/include/asm/pgtable-2level.h             | 1 +
 arch/sh/include/asm/pgtable-3level.h             | 1 +
 arch/sparc/include/asm/pgtable_64.h              | 1 +
 arch/tile/include/asm/pgtable_32.h               | 1 +
 arch/tile/include/asm/pgtable_64.h               | 1 +
 arch/um/include/asm/pgtable-2level.h             | 1 +
 arch/um/include/asm/pgtable-3level.h             | 1 +
 arch/unicore32/include/asm/pgtable.h             | 1 +
 arch/x86/include/asm/pgtable_types.h             | 4 ++++
 arch/xtensa/include/asm/pgtable.h                | 1 +
 33 files changed, 43 insertions(+)

diff --git a/arch/arc/include/asm/hugepage.h b/arch/arc/include/asm/hugepage.h
index 317ff773e1ca..b18fcb606908 100644
--- a/arch/arc/include/asm/hugepage.h
+++ b/arch/arc/include/asm/hugepage.h
@@ -11,6 +11,7 @@
 #define _ASM_ARC_HUGEPAGE_H
 
 #include <linux/types.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 static inline pte_t pmd_pte(pmd_t pmd)
diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index e94ca72b974e..ee22d40afef4 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -37,6 +37,7 @@
 
 #include <asm/page.h>
 #include <asm/mmu.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 #include <linux/const.h>
 
diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index a8d656d9aec7..1c462381c225 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -20,6 +20,7 @@
 
 #else
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 #include <asm/memory.h>
 #include <asm/pgtable-hwdef.h>
diff --git a/arch/arm64/include/asm/pgtable-types.h b/arch/arm64/include/asm/pgtable-types.h
index 69b2fd41503c..345a072b5856 100644
--- a/arch/arm64/include/asm/pgtable-types.h
+++ b/arch/arm64/include/asm/pgtable-types.h
@@ -55,9 +55,13 @@ typedef struct { pteval_t pgprot; } pgprot_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 #if CONFIG_PGTABLE_LEVELS == 2
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 #elif CONFIG_PGTABLE_LEVELS == 3
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
+#elif CONFIG_PGTABLE_LEVELS == 4
+#include <asm-generic/5level-fixup.h>
 #endif
 
 #endif	/* __ASM_PGTABLE_TYPES_H */
diff --git a/arch/avr32/include/asm/pgtable-2level.h b/arch/avr32/include/asm/pgtable-2level.h
index 425dd567b5b9..d5b1c63993ec 100644
--- a/arch/avr32/include/asm/pgtable-2level.h
+++ b/arch/avr32/include/asm/pgtable-2level.h
@@ -8,6 +8,7 @@
 #ifndef __ASM_AVR32_PGTABLE_2LEVEL_H
 #define __ASM_AVR32_PGTABLE_2LEVEL_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 /*
diff --git a/arch/cris/include/asm/pgtable.h b/arch/cris/include/asm/pgtable.h
index ceefc314d64d..5dcdb7d014e5 100644
--- a/arch/cris/include/asm/pgtable.h
+++ b/arch/cris/include/asm/pgtable.h
@@ -6,6 +6,7 @@
 #define _CRIS_PGTABLE_H
 
 #include <asm/page.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #ifndef __ASSEMBLY__
diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index a0513d463a1f..ab6e7e961b54 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -16,6 +16,7 @@
 #ifndef _ASM_PGTABLE_H
 #define _ASM_PGTABLE_H
 
+#include <asm-generic/5level-fixup.h>
 #include <asm/mem-layout.h>
 #include <asm/setup.h>
 #include <asm/processor.h>
diff --git a/arch/h8300/include/asm/pgtable.h b/arch/h8300/include/asm/pgtable.h
index 8341db67821d..7d265d28ba5e 100644
--- a/arch/h8300/include/asm/pgtable.h
+++ b/arch/h8300/include/asm/pgtable.h
@@ -1,5 +1,6 @@
 #ifndef _H8300_PGTABLE_H
 #define _H8300_PGTABLE_H
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 #include <asm-generic/pgtable.h>
 #define pgtable_cache_init()   do { } while (0)
diff --git a/arch/hexagon/include/asm/pgtable.h b/arch/hexagon/include/asm/pgtable.h
index 49eab8136ec3..24a9177fb897 100644
--- a/arch/hexagon/include/asm/pgtable.h
+++ b/arch/hexagon/include/asm/pgtable.h
@@ -26,6 +26,7 @@
  */
 #include <linux/swap.h>
 #include <asm/page.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 /* A handy thing to have if one has the RAM. Declared in head.S */
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 9f3ed9ee8f13..67568fb8bceb 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -587,8 +587,10 @@ extern struct page *zero_page_memmap_ptr;
 
 
 #if CONFIG_PGTABLE_LEVELS == 3
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 #endif
+#include <asm-generic/5level-fixup.h>
 #include <asm-generic/pgtable.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
diff --git a/arch/metag/include/asm/pgtable.h b/arch/metag/include/asm/pgtable.h
index ffa3a3a2ecad..0c151e5af079 100644
--- a/arch/metag/include/asm/pgtable.h
+++ b/arch/metag/include/asm/pgtable.h
@@ -6,6 +6,7 @@
 #define _METAG_PGTABLE_H
 
 #include <asm/pgtable-bits.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 /* Invalid regions on Meta: 0x00000000-0x001FFFFF and 0xFFFF0000-0xFFFFFFFF */
diff --git a/arch/mips/include/asm/pgtable-32.h b/arch/mips/include/asm/pgtable-32.h
index d21f3da7bdb6..6f94bed571c4 100644
--- a/arch/mips/include/asm/pgtable-32.h
+++ b/arch/mips/include/asm/pgtable-32.h
@@ -16,6 +16,7 @@
 #include <asm/cachectl.h>
 #include <asm/fixmap.h>
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 extern int temp_tlb_entry;
diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index 514cbc0a6a67..130a2a6c1531 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -17,6 +17,7 @@
 #include <asm/cachectl.h>
 #include <asm/fixmap.h>
 
+#define __ARCH_USE_5LEVEL_HACK
 #if defined(CONFIG_PAGE_SIZE_64KB) && !defined(CONFIG_MIPS_VA_BITS_48)
 #include <asm-generic/pgtable-nopmd.h>
 #else
diff --git a/arch/mn10300/include/asm/page.h b/arch/mn10300/include/asm/page.h
index 3810a6f740fd..dfe730a5ede0 100644
--- a/arch/mn10300/include/asm/page.h
+++ b/arch/mn10300/include/asm/page.h
@@ -57,6 +57,7 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) })
 #define __pgprot(x)	((pgprot_t) { (x) })
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/nios2/include/asm/pgtable.h b/arch/nios2/include/asm/pgtable.h
index 298393c3cb42..db4f7d179220 100644
--- a/arch/nios2/include/asm/pgtable.h
+++ b/arch/nios2/include/asm/pgtable.h
@@ -22,6 +22,7 @@
 #include <asm/tlbflush.h>
 
 #include <asm/pgtable-bits.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #define FIRST_USER_ADDRESS	0UL
diff --git a/arch/openrisc/include/asm/pgtable.h b/arch/openrisc/include/asm/pgtable.h
index 3567aa7be555..ff97374ca069 100644
--- a/arch/openrisc/include/asm/pgtable.h
+++ b/arch/openrisc/include/asm/pgtable.h
@@ -25,6 +25,7 @@
 #ifndef __ASM_OPENRISC_PGTABLE_H
 #define __ASM_OPENRISC_PGTABLE_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #ifndef __ASSEMBLY__
diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index 012223638815..26ed228d4dc6 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_POWERPC_BOOK3S_32_PGTABLE_H
 #define _ASM_POWERPC_BOOK3S_32_PGTABLE_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #include <asm/book3s/32/hash.h>
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 5905f0ff57d1..86daf07db423 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_POWERPC_BOOK3S_64_PGTABLE_H_
 #define _ASM_POWERPC_BOOK3S_64_PGTABLE_H_
 
+#include <asm-generic/5level-fixup.h>
+
 /*
  * Common bits between hash and Radix page table
  */
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index ba9921bf202e..5134ade2e850 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_POWERPC_NOHASH_32_PGTABLE_H
 #define _ASM_POWERPC_NOHASH_32_PGTABLE_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #ifndef __ASSEMBLY__
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable-4k.h b/arch/powerpc/include/asm/nohash/64/pgtable-4k.h
index d0db98793dd8..9f4de0a1035e 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable-4k.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable-4k.h
@@ -1,5 +1,8 @@
 #ifndef _ASM_POWERPC_NOHASH_64_PGTABLE_4K_H
 #define _ASM_POWERPC_NOHASH_64_PGTABLE_4K_H
+
+#include <asm-generic/5level-fixup.h>
+
 /*
  * Entries per page directory level.  The PTE level must use a 64b record
  * for each page table entry.  The PMD and PGD level use a 32b record for
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable-64k.h b/arch/powerpc/include/asm/nohash/64/pgtable-64k.h
index 55b28ef3409a..1facb584dd29 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable-64k.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable-64k.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_POWERPC_NOHASH_64_PGTABLE_64K_H
 #define _ASM_POWERPC_NOHASH_64_PGTABLE_64K_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 
 
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 0362cd5fa187..9718066eabcb 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -24,6 +24,7 @@
  * the S390 page table tree.
  */
 #ifndef __ASSEMBLY__
+#include <asm-generic/5level-fixup.h>
 #include <linux/sched.h>
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
diff --git a/arch/score/include/asm/pgtable.h b/arch/score/include/asm/pgtable.h
index 0553e5cd5985..46ff8fd678a7 100644
--- a/arch/score/include/asm/pgtable.h
+++ b/arch/score/include/asm/pgtable.h
@@ -2,6 +2,7 @@
 #define _ASM_SCORE_PGTABLE_H
 
 #include <linux/const.h>
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 #include <asm/fixmap.h>
diff --git a/arch/sh/include/asm/pgtable-2level.h b/arch/sh/include/asm/pgtable-2level.h
index 19bd89db17e7..f75cf4387257 100644
--- a/arch/sh/include/asm/pgtable-2level.h
+++ b/arch/sh/include/asm/pgtable-2level.h
@@ -1,6 +1,7 @@
 #ifndef __ASM_SH_PGTABLE_2LEVEL_H
 #define __ASM_SH_PGTABLE_2LEVEL_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 /*
diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 249a985d9648..9b1e776eca31 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -1,6 +1,7 @@
 #ifndef __ASM_SH_PGTABLE_3LEVEL_H
 #define __ASM_SH_PGTABLE_3LEVEL_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 
 /*
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 314b66851348..f3472eff47bf 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -12,6 +12,7 @@
  * the SpitFire page tables.
  */
 
+#include <asm-generic/5level-fixup.h>
 #include <linux/compiler.h>
 #include <linux/const.h>
 #include <asm/types.h>
diff --git a/arch/tile/include/asm/pgtable_32.h b/arch/tile/include/asm/pgtable_32.h
index d26a42279036..5f8c615cb5e9 100644
--- a/arch/tile/include/asm/pgtable_32.h
+++ b/arch/tile/include/asm/pgtable_32.h
@@ -74,6 +74,7 @@ extern unsigned long VMALLOC_RESERVE /* = CONFIG_VMALLOC_RESERVE */;
 #define MAXMEM		(_VMALLOC_START - PAGE_OFFSET)
 
 /* We have no pmd or pud since we are strictly a two-level page table */
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 static inline int pud_huge_page(pud_t pud)	{ return 0; }
diff --git a/arch/tile/include/asm/pgtable_64.h b/arch/tile/include/asm/pgtable_64.h
index e96cec52f6d8..96fe58b45118 100644
--- a/arch/tile/include/asm/pgtable_64.h
+++ b/arch/tile/include/asm/pgtable_64.h
@@ -59,6 +59,7 @@
 #ifndef __ASSEMBLY__
 
 /* We have no pud since we are a three-level page table. */
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 
 /*
diff --git a/arch/um/include/asm/pgtable-2level.h b/arch/um/include/asm/pgtable-2level.h
index cfbe59752469..179c0ea87a0c 100644
--- a/arch/um/include/asm/pgtable-2level.h
+++ b/arch/um/include/asm/pgtable-2level.h
@@ -8,6 +8,7 @@
 #ifndef __UM_PGTABLE_2LEVEL_H
 #define __UM_PGTABLE_2LEVEL_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 /* PGDIR_SHIFT determines what a third-level page table entry can map */
diff --git a/arch/um/include/asm/pgtable-3level.h b/arch/um/include/asm/pgtable-3level.h
index bae8523a162f..c4d876dfb9ac 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -7,6 +7,7 @@
 #ifndef __UM_PGTABLE_3LEVEL_H
 #define __UM_PGTABLE_3LEVEL_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 
 /* PGDIR_SHIFT determines what a third-level page table entry can map */
diff --git a/arch/unicore32/include/asm/pgtable.h b/arch/unicore32/include/asm/pgtable.h
index 818d0f5598e3..a4f2bef37e70 100644
--- a/arch/unicore32/include/asm/pgtable.h
+++ b/arch/unicore32/include/asm/pgtable.h
@@ -12,6 +12,7 @@
 #ifndef __UNICORE_PGTABLE_H__
 #define __UNICORE_PGTABLE_H__
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 #include <asm/cpu-single.h>
 
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 8b4de22d6429..62484333673d 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -273,6 +273,8 @@ static inline pgdval_t pgd_flags(pgd_t pgd)
 }
 
 #if CONFIG_PGTABLE_LEVELS > 3
+#include <asm-generic/5level-fixup.h>
+
 typedef struct { pudval_t pud; } pud_t;
 
 static inline pud_t native_make_pud(pmdval_t val)
@@ -285,6 +287,7 @@ static inline pudval_t native_pud_val(pud_t pud)
 	return pud.pud;
 }
 #else
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 
 static inline pudval_t native_pud_val(pud_t pud)
@@ -306,6 +309,7 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 	return pmd.pmd;
 }
 #else
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 static inline pmdval_t native_pmd_val(pmd_t pmd)
diff --git a/arch/xtensa/include/asm/pgtable.h b/arch/xtensa/include/asm/pgtable.h
index 8aa0e0d9cbb2..30dd5b2e4ad5 100644
--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -11,6 +11,7 @@
 #ifndef _XTENSA_PGTABLE_H
 #define _XTENSA_PGTABLE_H
 
+#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 #include <asm/page.h>
 #include <asm/kmem_layout.h>
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
