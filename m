From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073253.10631.12029.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 04/07] i386: numa warning fix
Date: Fri, 30 Sep 2005 16:33:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Isaku Yamahata <yamahata@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch contains a warning fix for the NUMA patch written by Dave Hansen 
which was posted to lkml and linux-mm at September 13:th 2005.

[snip]
  CC      arch/i386/mm/numa.o
arch/i386/mm/numa.c: In function `remap_numa_kva':
arch/i386/mm/numa.c:85: warning: implicit declaration of function `set_pmd_pfn'
  LD      arch/i386/mm/built-in.o
[snip]

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 pgtable-3level.h |    1 -
 pgtable.h        |    2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

--- from-0006/include/asm-i386/pgtable-3level.h
+++ to-work/include/asm-i386/pgtable-3level.h	2005-09-28 16:30:09.000000000 +0900
@@ -65,7 +65,6 @@ static inline void set_pte(pte_t *ptep, 
 		set_64bit((unsigned long long *)(pmdptr),pmd_val(pmdval))
 #define set_pud(pudptr,pudval) \
 		(*(pudptr) = (pudval))
-extern void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
 
 /*
  * Pentium-II erratum A13: in PAE mode we explicitly have to flush
--- from-0002/include/asm-i386/pgtable.h
+++ to-work/include/asm-i386/pgtable.h	2005-09-28 16:30:09.000000000 +0900
@@ -327,6 +327,8 @@ static inline pte_t pte_modify(pte_t pte
 #define pmd_large(pmd) \
 ((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
 
+extern void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
+
 /*
  * the pgd page can be thought of an array like this: pgd_t[PTRS_PER_PGD]
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
