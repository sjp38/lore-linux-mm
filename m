Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 910386B0273
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 14:04:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j6-v6so11576052wrr.15
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 11:04:06 -0700 (PDT)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id t10-v6si8886929wrv.272.2018.08.06.11.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Aug 2018 11:04:05 -0700 (PDT)
From: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 06/11] hugetlb: Introduce generic version of huge_pte_none
Date: Mon,  6 Aug 2018 17:57:06 +0000
Message-Id: <20180806175711.24438-7-alex@ghiti.fr>
In-Reply-To: <20180806175711.24438-1-alex@ghiti.fr>
References: <20180806175711.24438-1-alex@ghiti.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Alexandre Ghiti <alex@ghiti.fr>

arm, arm64, ia64, mips, parisc, powerpc, sh, sparc, x86 architectures
use the same version of huge_pte_none, so move this generic
implementation into asm-generic/hugetlb.h.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Tested-by: Helge Deller <deller@gmx.de> # parisc
Acked-by: Catalin Marinas <catalin.marinas@arm.com> # arm64
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/arm/include/asm/hugetlb.h     | 5 -----
 arch/arm64/include/asm/hugetlb.h   | 5 -----
 arch/ia64/include/asm/hugetlb.h    | 5 -----
 arch/mips/include/asm/hugetlb.h    | 1 +
 arch/parisc/include/asm/hugetlb.h  | 5 -----
 arch/powerpc/include/asm/hugetlb.h | 5 -----
 arch/sh/include/asm/hugetlb.h      | 5 -----
 arch/sparc/include/asm/hugetlb.h   | 5 -----
 arch/x86/include/asm/hugetlb.h     | 5 -----
 include/asm-generic/hugetlb.h      | 7 +++++++
 10 files changed, 8 insertions(+), 40 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 537660891f9f..c821b550d6a4 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -44,11 +44,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 4c8dd488554d..49247c6f94db 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -42,11 +42,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index 41b5f6adeee4..bf573500b3c4 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -26,11 +26,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 7df1f116a3cc..1c9c4531376c 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -55,6 +55,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 	flush_tlb_page(vma, addr & huge_page_mask(hstate_vma(vma)));
 }
 
+#define __HAVE_ARCH_HUGE_PTE_NONE
 static inline int huge_pte_none(pte_t pte)
 {
 	unsigned long val = pte_val(pte) & ~_PAGE_GLOBAL;
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index 9afff26747a1..c09d8c74553c 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -38,11 +38,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 0b02856aa85b..3562d46585ba 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -152,11 +152,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 	flush_hugetlb_page(vma, addr);
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index 9abf9c86b769..a9f8266f33cf 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -31,11 +31,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 651a9593fcee..11115bbd712e 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -48,11 +48,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index fd59673e7a0a..42d872054791 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -28,11 +28,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline int huge_pte_none(pte_t pte)
-{
-	return pte_none(pte);
-}
-
 static inline pte_t huge_pte_wrprotect(pte_t pte)
 {
 	return pte_wrprotect(pte);
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index ffa63fd8388d..2fc3d68424e9 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -73,4 +73,11 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 }
 #endif
 
+#ifndef __HAVE_ARCH_HUGE_PTE_NONE
+static inline int huge_pte_none(pte_t pte)
+{
+	return pte_none(pte);
+}
+#endif
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
-- 
2.16.2
