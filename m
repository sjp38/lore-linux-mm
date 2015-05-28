Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 978A16B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 07:52:59 -0400 (EDT)
Received: by wgez8 with SMTP id z8so34122309wge.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 04:52:59 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id dj8si4211958wib.80.2015.05.28.04.52.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 28 May 2015 04:52:53 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 28 May 2015 12:52:51 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id EC0F817D807A
	for <linux-mm@kvack.org>; Thu, 28 May 2015 12:53:44 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4SBqno220578534
	for <linux-mm@kvack.org>; Thu, 28 May 2015 11:52:49 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4SBqkMh020356
	for <linux-mm@kvack.org>; Thu, 28 May 2015 05:52:49 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 3/5] mm/hugetlb: remove arch_prepare/release_hugepage from arch headers
Date: Thu, 28 May 2015 13:52:35 +0200
Message-Id: <1432813957-46874-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nathan Lynch <nathan_lynch@mentor.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andy Lutomirski <luto@amacapital.net>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

Nobody used these hooks so they were removed from common code,
and can now be removed from the architectures.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/arm/include/asm/hugetlb.h     | 9 ---------
 arch/arm64/include/asm/hugetlb.h   | 9 ---------
 arch/ia64/include/asm/hugetlb.h    | 9 ---------
 arch/metag/include/asm/hugetlb.h   | 9 ---------
 arch/mips/include/asm/hugetlb.h    | 9 ---------
 arch/powerpc/include/asm/hugetlb.h | 9 ---------
 arch/sh/include/asm/hugetlb.h      | 9 ---------
 arch/sparc/include/asm/hugetlb.h   | 9 ---------
 arch/tile/include/asm/hugetlb.h    | 9 ---------
 arch/x86/include/asm/hugetlb.h     | 9 ---------
 10 files changed, 90 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 31bb7dc..7d26f6c 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -63,15 +63,6 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 734c17e..2fd9b14 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -96,15 +96,6 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index ff1377b..ef65f02 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -65,15 +65,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/metag/include/asm/hugetlb.h b/arch/metag/include/asm/hugetlb.h
index f730b39..905ed42 100644
--- a/arch/metag/include/asm/hugetlb.h
+++ b/arch/metag/include/asm/hugetlb.h
@@ -67,15 +67,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 4a5bb54..982bc06 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -110,15 +110,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 4bbd3c8..7eac89b 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -168,15 +168,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index b788a9b..ef489a5 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -79,15 +79,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 3130d76..139e711 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -78,15 +78,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
index 1abd00c..2fac5be 100644
--- a/arch/tile/include/asm/hugetlb.h
+++ b/arch/tile/include/asm/hugetlb.h
@@ -94,15 +94,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index dab7a3a..f8a29d2 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -80,15 +80,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
-- 
2.3.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
