Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E75C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4105D2087F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:33:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4105D2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E13C66B02F8; Sun, 17 Mar 2019 12:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC2556B02FA; Sun, 17 Mar 2019 12:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C64D76B02FB; Sun, 17 Mar 2019 12:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65AC06B02F8
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 12:33:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k21so5974342eds.19
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 09:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G1y6QFYkkPvajdMwD94q+O4CeZhkRTCXvnC9LVH9ftw=;
        b=V9O76JpG7ykqcnfMNyCwJ8ARw/tlCRNfCtoc/r3MMIzcr9K8skB/y9jhW5ixX7DVRC
         ljqYkPcbynUee1JiVEAuX5pkjeyny3XL4emTStkqHvSancH/bOaAIqE9BCNwd2mB6Nnj
         I0JiYWSz8LFNd8ivieWhQfxqb4pJYdCj6PJQFPeuvV5xY9NC4TcgjeEta4MqdtCmw/9G
         PEgUsIYWs0ajj6sEYJhFHbzDM/QND2ou5JtHAiiAqYm7k8y3cfSjYgG6jjOZUPHlbGpo
         hoBNsZEekLK+sjBUIT9zeIF4yrVrOKq/sIIEtL9u/JjVKVkQ35SUIJHke4gioDB7Nawd
         YxCw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXFIXfZ8A0SDULie59lwvZLPzluexTnEs/P3mKB47+R0dpfzHaB
	poE0RJmLv0ZZEaOzhM7thz3AInRx84jpGLhJag97t0eg7cqZG6lGEI/0hvRYBj/MSm8jn8WOTpk
	2HHUzoO5O+6ViReg73HpkfTXz8yfz0i8aQiU8offY2A112V4dlEbkuaQDxh+WqGc=
X-Received: by 2002:a50:d889:: with SMTP id p9mr789369edj.96.1552840423845;
        Sun, 17 Mar 2019 09:33:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwByKFwC8v/63dVXsCXFzaQAn2LuVFZ+CL7airtsqiNF3ChdRTPjT7YwbXnFb1fPD2Vx/K2
X-Received: by 2002:a50:d889:: with SMTP id p9mr789305edj.96.1552840422287;
        Sun, 17 Mar 2019 09:33:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552840422; cv=none;
        d=google.com; s=arc-20160816;
        b=LmdUNknRC4k0TRvPhXrVkpBSqsFDQc70A/9+ihw5kGgOqyGJx1aiX3ewCcfAFKvzud
         7rgF9Qv8kaPbRxT76avIzg/gs9QgW3FPqKZ8zpEgkottqcshI4/DL6fIoP9flvNSlfwI
         YpGrNe7IE2l7fdLYdwzr+WIVucuGBNWyBmkZUSknjj2ERwGUoIeMWFJcsaqK/ptq4lK7
         olAzCHSY4LGPVdxlnC9YoXx7ZTiZ3oGXE+xC/Bm5kAsH10WTDpL6D44I/G5g6KuBumoG
         tXisw/LdO7tKORTCxvSTAarJRvz4d56MkCVRWgrfJJDtL9taY9IgjsBo0ogQpXVQBAmC
         9lOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=G1y6QFYkkPvajdMwD94q+O4CeZhkRTCXvnC9LVH9ftw=;
        b=EYg9CnvuBFD30hUV3OykllOBqpGDnu57Zn6bV4nwjgnvbM2VDSdBYRquJzj5wJQp8C
         +aLC5jY+rv6cDxd1mkh8VV9+0bn4WJdvuz4lXcE15TZgLlcrPI5XvzWKOinRuRDrpTyQ
         PPBP4tW2OTfN4P7Jgdj0tqhWDII3MEXmQMiy/t+Wx9JdTPs7UZXER0UyEMuO/QgxNdSw
         4MHiA5mHri84r5Bmn/OI1DmpEvd6hCdMIfbOGeu21mn1FN+wTXeHPhVkzxXt/dgV3YzZ
         v7UItAPoa0+6d9BQ+FbLx5KV3eLzq2sgABozmZ6gy3i+SORIYtsMednNTbHJcdLjurZW
         jt8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id b17si3044893edw.309.2019.03.17.09.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 09:33:42 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 52E2A200003;
	Sun, 17 Mar 2019 16:33:33 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v7 4/4] hugetlb: allow to free gigantic pages regardless of the configuration
Date: Sun, 17 Mar 2019 12:28:47 -0400
Message-Id: <20190317162847.14107-5-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317162847.14107-1-alex@ghiti.fr>
References: <20190317162847.14107-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On systems without CONTIG_ALLOC activated but that support gigantic pages,
boottime reserved gigantic pages can not be freed at all. This patch
simply enables the possibility to hand back those pages to memory
allocator.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: David S. Miller <davem@davemloft.net> [sparc]
---
 arch/arm64/Kconfig                           |  2 +-
 arch/arm64/include/asm/hugetlb.h             |  4 --
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
 arch/powerpc/platforms/Kconfig.cputype       |  2 +-
 arch/s390/Kconfig                            |  2 +-
 arch/s390/include/asm/hugetlb.h              |  3 --
 arch/sh/Kconfig                              |  2 +-
 arch/sparc/Kconfig                           |  2 +-
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/hugetlb.h               |  4 --
 include/asm-generic/hugetlb.h                | 14 +++++
 include/linux/gfp.h                          |  2 +-
 mm/hugetlb.c                                 | 54 ++++++++++++++------
 mm/page_alloc.c                              |  4 +-
 14 files changed, 61 insertions(+), 43 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 091a513b93e9..af687eff884a 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -18,7 +18,7 @@ config ARM64
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PTE_SPECIAL
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index fb6609875455..59893e766824 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -65,8 +65,4 @@ extern void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
 
 #include <asm-generic/hugetlb.h>
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
-
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 5b0177733994..d04a0bcc2f1c 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -32,13 +32,6 @@ static inline int hstate_get_psize(struct hstate *hstate)
 	}
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void)
-{
-	return true;
-}
-#endif
-
 /* hugepd entry valid bit */
 #define HUGEPD_VAL_BITS		(0x8000000000000000UL)
 
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index f677c8974212..dc0328de20cd 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -319,7 +319,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 1c57b83c76f5..d84e536796b1 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -69,7 +69,7 @@ config S390
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 2d1afa58a4b6..bd191560efcf 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -116,7 +116,4 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
 #endif /* _ASM_S390_HUGETLB_H */
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index c7266302691c..404b12a0d871 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,7 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index ca33c80870e2..234a6bd46e89 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -90,7 +90,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8ba90f3e0038..ff24eaeef211 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -23,7 +23,7 @@ config X86_64
 	def_bool y
 	depends on 64BIT
 	# Options that are inherently 64-bit kernel only:
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_SUPPORTS_INT128
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_SOFT_DIRTY
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 7469d321f072..f65cfb48cfdd 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -17,8 +17,4 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
-
 #endif /* _ASM_X86_HUGETLB_H */
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 71d7b77eea50..aaf14974ee5f 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -126,4 +126,18 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 }
 #endif
 
+#ifndef __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
+static inline bool gigantic_page_runtime_supported(void)
+{
+	return true;
+}
+#else
+static inline bool gigantic_page_runtime_supported(void)
+{
+	return false;
+}
+#endif /* CONFIG_ARCH_HAS_GIGANTIC_PAGE */
+#endif /* __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED */
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1f1ad9aeebb9..58ea44bf75de 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -589,8 +589,8 @@ static inline bool pm_suspended_storage(void)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
-extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 #endif
+extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);
 
 #ifdef CONFIG_CMA
 /* CMA stuff */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef61656c1e..4e55aa38704f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1058,6 +1058,7 @@ static void free_gigantic_page(struct page *page, unsigned int order)
 	free_contig_range(page_to_pfn(page), 1 << order);
 }
 
+#ifdef CONFIG_CONTIG_ALLOC
 static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages, gfp_t gfp_mask)
 {
@@ -1142,11 +1143,20 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
+#else /* !CONFIG_CONTIG_ALLOC */
+static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
+					int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
+#endif /* CONFIG_CONTIG_ALLOC */
 
 #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
-static inline bool gigantic_page_supported(void) { return false; }
 static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
-		int nid, nodemask_t *nodemask) { return NULL; }
+					int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
@@ -1156,7 +1166,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
+	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
 		return;
 
 	h->nr_huge_pages--;
@@ -2276,13 +2286,27 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
-						nodemask_t *nodes_allowed)
+static int set_max_huge_pages(struct hstate *h, unsigned long count,
+			      nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
-		return h->max_huge_pages;
+	spin_lock(&hugetlb_lock);
+
+	/*
+	 * Gigantic pages runtime allocation depend on the capability for large
+	 * page range allocation.
+	 * If the system does not provide this feature, return an error when
+	 * the user tries to allocate gigantic pages but let the user free the
+	 * boottime allocated gigantic pages.
+	 */
+	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
+		if (count > persistent_huge_pages(h)) {
+			spin_unlock(&hugetlb_lock);
+			return -EINVAL;
+		}
+		/* Fall through to decrease pool */
+	}
 
 	/*
 	 * Increase the pool size
@@ -2295,7 +2319,6 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * pool might be one hugepage larger than it needs to be, but
 	 * within all the constraints specified by the sysctls.
 	 */
-	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
@@ -2350,9 +2373,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 			break;
 	}
 out:
-	ret = persistent_huge_pages(h);
+	h->max_huge_pages = persistent_huge_pages(h);
 	spin_unlock(&hugetlb_lock);
-	return ret;
+
+	return 0;
 }
 
 #define HSTATE_ATTR_RO(_name) \
@@ -2404,7 +2428,7 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	int err;
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
+	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported()) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -2428,15 +2452,13 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	} else
 		nodes_allowed = &node_states[N_MEMORY];
 
-	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nodes_allowed);
 
+out:
 	if (nodes_allowed != &node_states[N_MEMORY])
 		NODEMASK_FREE(nodes_allowed);
 
-	return len;
-out:
-	NODEMASK_FREE(nodes_allowed);
-	return err;
+	return err ? err : len;
 }
 
 static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ac9c45ffb344..a4547d90fa7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8234,8 +8234,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 				pfn_max_align_up(end), migratetype);
 	return ret;
 }
+#endif /* CONFIG_CONTIG_ALLOC */
 
-void free_contig_range(unsigned long pfn, unsigned nr_pages)
+void free_contig_range(unsigned long pfn, unsigned int nr_pages)
 {
 	unsigned int count = 0;
 
@@ -8247,7 +8248,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 	}
 	WARN(count != 0, "%d pages are still in use!\n", count);
 }
-#endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
-- 
2.20.1

