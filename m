Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC8546B0274
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:10 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 34so11229374otj.2
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:00:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 123-v6si13075280oii.193.2018.10.31.06.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:00:09 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9VCxAdH005548
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:09 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nfctx8643-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:08 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Oct 2018 13:00:06 -0000
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/4] mm: make the __PAGETABLE_PxD_FOLDED defines non-empty
Date: Wed, 31 Oct 2018 13:59:58 +0100
In-Reply-To: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
References: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
Message-Id: <1540990801-4261-2-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Change the currently empty defines for __PAGETABLE_PMD_FOLDED,
__PAGETABLE_PUD_FOLDED and __PAGETABLE_P4D_FOLDED to return 1.
This makes it possible to use __is_defined() to test if the
preprocessor define exists.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/arm/include/asm/pgtable-2level.h    | 2 +-
 arch/m68k/include/asm/pgtable_mm.h       | 4 ++--
 arch/microblaze/include/asm/pgtable.h    | 2 +-
 arch/nds32/include/asm/pgtable.h         | 2 +-
 arch/parisc/include/asm/pgtable.h        | 2 +-
 include/asm-generic/4level-fixup.h       | 2 +-
 include/asm-generic/5level-fixup.h       | 2 +-
 include/asm-generic/pgtable-nop4d-hack.h | 2 +-
 include/asm-generic/pgtable-nop4d.h      | 2 +-
 include/asm-generic/pgtable-nopmd.h      | 2 +-
 include/asm-generic/pgtable-nopud.h      | 2 +-
 11 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index 92fd2c8..12659ce 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -10,7 +10,7 @@
 #ifndef _ASM_PGTABLE_2LEVEL_H
 #define _ASM_PGTABLE_2LEVEL_H
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 
 /*
  * Hardware-wise, we have a two level page table structure, where the first
diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index 6181e41..fe3ddd7 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -55,12 +55,12 @@
  */
 #ifdef CONFIG_SUN3
 #define PTRS_PER_PTE   16
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 #define PTRS_PER_PMD   1
 #define PTRS_PER_PGD   2048
 #elif defined(CONFIG_COLDFIRE)
 #define PTRS_PER_PTE	512
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 #define PTRS_PER_PMD	1
 #define PTRS_PER_PGD	1024
 #else
diff --git a/arch/microblaze/include/asm/pgtable.h b/arch/microblaze/include/asm/pgtable.h
index f64ebb9..e14b662 100644
--- a/arch/microblaze/include/asm/pgtable.h
+++ b/arch/microblaze/include/asm/pgtable.h
@@ -63,7 +63,7 @@ extern int mem_init_done;
 
 #include <asm-generic/4level-fixup.h>
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
diff --git a/arch/nds32/include/asm/pgtable.h b/arch/nds32/include/asm/pgtable.h
index d3e19a5..9f52db9 100644
--- a/arch/nds32/include/asm/pgtable.h
+++ b/arch/nds32/include/asm/pgtable.h
@@ -4,7 +4,7 @@
 #ifndef _ASMNDS32_PGTABLE_H
 #define _ASMNDS32_PGTABLE_H
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 #include <asm-generic/4level-fixup.h>
 #include <asm-generic/sizes.h>
 
diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index b941ac7..c7bb74e 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -111,7 +111,7 @@ static inline void purge_tlb_entries(struct mm_struct *mm, unsigned long addr)
 #if CONFIG_PGTABLE_LEVELS == 3
 #define BITS_PER_PMD	(PAGE_SHIFT + PMD_ORDER - BITS_PER_PMD_ENTRY)
 #else
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 #define BITS_PER_PMD	0
 #endif
 #define PTRS_PER_PMD    (1UL << BITS_PER_PMD)
diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index 89f3b03..e3667c9 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -3,7 +3,7 @@
 #define _4LEVEL_FIXUP_H
 
 #define __ARCH_HAS_4LEVEL_HACK
-#define __PAGETABLE_PUD_FOLDED
+#define __PAGETABLE_PUD_FOLDED 1
 
 #define PUD_SHIFT			PGDIR_SHIFT
 #define PUD_SIZE			PGDIR_SIZE
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index 9c2e070..73474bb 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -3,7 +3,7 @@
 #define _5LEVEL_FIXUP_H
 
 #define __ARCH_HAS_5LEVEL_HACK
-#define __PAGETABLE_P4D_FOLDED
+#define __PAGETABLE_P4D_FOLDED 1
 
 #define P4D_SHIFT			PGDIR_SHIFT
 #define P4D_SIZE			PGDIR_SIZE
diff --git a/include/asm-generic/pgtable-nop4d-hack.h b/include/asm-generic/pgtable-nop4d-hack.h
index 0c34215..1d6dd38 100644
--- a/include/asm-generic/pgtable-nop4d-hack.h
+++ b/include/asm-generic/pgtable-nop4d-hack.h
@@ -5,7 +5,7 @@
 #ifndef __ASSEMBLY__
 #include <asm-generic/5level-fixup.h>
 
-#define __PAGETABLE_PUD_FOLDED
+#define __PAGETABLE_PUD_FOLDED 1
 
 /*
  * Having the pud type consist of a pgd gets the size right, and allows
diff --git a/include/asm-generic/pgtable-nop4d.h b/include/asm-generic/pgtable-nop4d.h
index 1a29b2a..04cb913 100644
--- a/include/asm-generic/pgtable-nop4d.h
+++ b/include/asm-generic/pgtable-nop4d.h
@@ -4,7 +4,7 @@
 
 #ifndef __ASSEMBLY__
 
-#define __PAGETABLE_P4D_FOLDED
+#define __PAGETABLE_P4D_FOLDED 1
 
 typedef struct { pgd_t pgd; } p4d_t;
 
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index f35f6e8..b85b827 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -8,7 +8,7 @@
 
 struct mm_struct;
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 
 /*
  * Having the pmd type consist of a pud gets the size right, and allows
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index e950b9c..9bef475 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -9,7 +9,7 @@
 #else
 #include <asm-generic/pgtable-nop4d.h>
 
-#define __PAGETABLE_PUD_FOLDED
+#define __PAGETABLE_PUD_FOLDED 1
 
 /*
  * Having the pud type consist of a p4d gets the size right, and allows
-- 
2.7.4
