Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08F2D6B000D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:57:41 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u9so6023225qtg.2
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:57:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n66si441506qkb.418.2018.04.09.06.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 06:57:40 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w39Du3MK003543
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 09:57:38 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h86je0nps-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:57:38 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 14:57:31 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm: remove __HAVE_ARCH_PTE_SPECIAL
Date: Mon,  9 Apr 2018 15:57:09 +0200
In-Reply-To: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523282229-20731-4-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

It is now replaced by Kconfig variable CONFIG_ARCH_HAS_PTE_SPECIAL.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/arc/include/asm/pgtable.h               | 2 --
 arch/arm/include/asm/pgtable-3level.h        | 1 -
 arch/arm64/include/asm/pgtable.h             | 2 --
 arch/powerpc/include/asm/book3s/64/pgtable.h | 3 ---
 arch/powerpc/include/asm/pte-common.h        | 3 ---
 arch/s390/include/asm/pgtable.h              | 1 -
 arch/sh/include/asm/pgtable.h                | 2 --
 arch/sparc/include/asm/pgtable_64.h          | 3 ---
 arch/x86/include/asm/pgtable_types.h         | 1 -
 9 files changed, 18 deletions(-)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 08fe33830d4b..8ec5599a0957 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -320,8 +320,6 @@ PTE_BIT_FUNC(mkexec,	|= (_PAGE_EXECUTE));
 PTE_BIT_FUNC(mkspecial,	|= (_PAGE_SPECIAL));
 PTE_BIT_FUNC(mkhuge,	|= (_PAGE_HW_SZ));
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	return __pte((pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot));
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 2a4836087358..6d50a11d7793 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -219,7 +219,6 @@ static inline pte_t pte_mkspecial(pte_t pte)
 	pte_val(pte) |= L_PTE_SPECIAL;
 	return pte;
 }
-#define	__HAVE_ARCH_PTE_SPECIAL
 
 #define pmd_write(pmd)		(pmd_isclear((pmd), L_PMD_SECT_RDONLY))
 #define pmd_dirty(pmd)		(pmd_isset((pmd), L_PMD_SECT_DIRTY))
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 7e2c27e63cd8..b96c8a186908 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -306,8 +306,6 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte(pgd_val(pgd));
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index a6b9f1d74600..f12d148eccbe 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -338,9 +338,6 @@ extern unsigned long pci_io_base;
 /* Advertise special mapping type for AGP */
 #define HAVE_PAGE_AGP
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #ifndef __ASSEMBLY__
 
 /*
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index c4a72c7a8c83..03dfddb1f49a 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -216,9 +216,6 @@ static inline bool pte_user(pte_t pte)
 #define PAGE_AGP		(PAGE_KERNEL_NC)
 #define HAVE_PAGE_AGP
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #ifndef _PAGE_READ
 /* if not defined, we should not find _PAGE_WRITE too */
 #define _PAGE_READ 0
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 2d24d33bf188..9809694e1389 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -171,7 +171,6 @@ static inline int is_module_addr(void *addr)
 #define _PAGE_WRITE	0x020		/* SW pte write bit */
 #define _PAGE_SPECIAL	0x040		/* SW associated with special page */
 #define _PAGE_UNUSED	0x080		/* SW bit for pgste usage state */
-#define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SOFT_DIRTY 0x002		/* SW pte soft dirty bit */
diff --git a/arch/sh/include/asm/pgtable.h b/arch/sh/include/asm/pgtable.h
index 89c513a982fc..f6abfe2bca93 100644
--- a/arch/sh/include/asm/pgtable.h
+++ b/arch/sh/include/asm/pgtable.h
@@ -156,8 +156,6 @@ extern void page_table_range_init(unsigned long start, unsigned long end,
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #include <asm-generic/pgtable.h>
 
 #endif /* __ASM_SH_PGTABLE_H */
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 44d6ac47e035..1393a8ac596b 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -117,9 +117,6 @@ bool kern_addr_valid(unsigned long addr);
 #define _PAGE_PMD_HUGE    _AC(0x0100000000000000,UL) /* Huge page            */
 #define _PAGE_PUD_HUGE    _PAGE_PMD_HUGE
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 /* SUN4U pte bits... */
 #define _PAGE_SZ4MB_4U	  _AC(0x6000000000000000,UL) /* 4MB Page             */
 #define _PAGE_SZ512K_4U	  _AC(0x4000000000000000,UL) /* 512K Page            */
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index acfe755562a6..3e195728d7d1 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -65,7 +65,6 @@
 #define _PAGE_PKEY_BIT2	(_AT(pteval_t, 0))
 #define _PAGE_PKEY_BIT3	(_AT(pteval_t, 0))
 #endif
-#define __HAVE_ARCH_PTE_SPECIAL
 
 #define _PAGE_PKEY_MASK (_PAGE_PKEY_BIT0 | \
 			 _PAGE_PKEY_BIT1 | \
-- 
2.7.4
