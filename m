Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D3D4C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:32:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E58CE2087C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:32:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E58CE2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8223B6B02F6; Sun, 17 Mar 2019 12:32:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F6EA6B02F8; Sun, 17 Mar 2019 12:32:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70DB96B02F9; Sun, 17 Mar 2019 12:32:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5FD6B02F6
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 12:32:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k21so5973782eds.19
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 09:32:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UXIrtiJ9sbtD68WeT6RDPp8dZNW0OEGDh6qCE1vVu44=;
        b=XlePWYVsZbmO7eYTTSVizFZaXa5TtFG/sXSw456b7kzAXfYIstuP9FyFNAem3pRQO5
         JeEmyu8L/6T1Or2W9G3dXCz8/AqXlD+U3inGzKkKGIMWtJin4I58hRMT+IzJcSTNGGBy
         P7gfsTS38nSBbIRkfXezx8bZsXAUPBE4nb/6mnS7bTYQ7r/CQ0lFzab/qLdKnIpvj4pf
         sg7Xb6211YikicaaGzcxSfItdoL5rVpTqh1Uy/nWaNo4Fi1yalrqtVEDsGO3LnIrAktR
         UEHgnXysAfhwD2Nk1VWgrXEIdYMH4SIrXe+Hai8mmUf53xpOWqJafCIUHBFmFlkLWCND
         3llg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW839r6XXJZgxWlnOTnaOYYY2wK1awjxJ9N2Z1JciGWSJuFagvK
	+kcL+J1PCe+2qHvdrF3BCG/y4q/kLwA55JHcES7oLRZDdfy+ZLIzEgU5MZFSdNvJimSGqyfgEh0
	H9FTo7AbnqisSd+R8JTRZ7hF0o5LO5YU7I0ekvoDLJvoQp9N89bbdKsjhoFQDjFY=
X-Received: by 2002:aa7:d892:: with SMTP id u18mr8647550edq.60.1552840354502;
        Sun, 17 Mar 2019 09:32:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM8cUuKjPyKCMyVdR5MjWLZ41sn0YuFeWBGTC3VLVrl70jXCfEKqAseki8otQ60j2dqBiB
X-Received: by 2002:aa7:d892:: with SMTP id u18mr8647490edq.60.1552840353188;
        Sun, 17 Mar 2019 09:32:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552840353; cv=none;
        d=google.com; s=arc-20160816;
        b=dRP9QCxNEuARtbiYQWTkAiYkT9NhXf8t05o9ajGSyoPEFjbHo3mE39wNaCnTsBXXGQ
         mFtBquunF4NvLp1OviKo/Ey9dysC+F58TSu25sffLViBS4xupsRPhqjgwLtt27CsDa9I
         SraRk7a8yz9ntfUt1pFPl3MC9rcYeughCC0/8ss9o2QNoN/I9sA7G5rutx2bOKLumsL1
         8DX+R6ZfFr1mNemAovwCTnoRq1OmzAewXbFjkikOPN/8q1h3DR2qHT0aLofHV6u9pzpQ
         hjQB7OkuxjDBMR9YZ8Uqr6PxjSBH5WUNxJucXynnY6rFdU/vATTRW26nbgd1KX6/4Xtc
         9y/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UXIrtiJ9sbtD68WeT6RDPp8dZNW0OEGDh6qCE1vVu44=;
        b=lX7FmPbsm642H2Dsoz/X46ljw5/KAqgnmzWG5xVqgxdRnUel9awfe16BVggD0BEnBE
         knoJSXSft5nkGYLjvuz3zLlmlOL7nYiqFKXBIR0pFSpjW/2b5uEHoiWNmlvp9pKWMLZW
         hn7YDIox0u5W79vHXN5SJeHB2erW09EqPn3AlVcp9gzPWomPnwzYlmenLmU/0Ah7KaV1
         WurtoUqYNagee2byYC5lGH+S8y+ZXEKq1K7CzCz4KiWbLbINHBqox7F6AGhZyyrr288F
         CCKL9sQfN3l4F1wM3XLolDn/wSwJWgY7ZbQdy8k42j5D7coU2iLsTFCockensyOkptbw
         l/ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id o45si1327714edc.369.2019.03.17.09.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 09:32:33 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id AE370200006;
	Sun, 17 Mar 2019 16:32:20 +0000 (UTC)
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
Subject: [PATCH v7 3/4] mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA into CONTIG_ALLOC
Date: Sun, 17 Mar 2019 12:28:46 -0400
Message-Id: <20190317162847.14107-4-alex@ghiti.fr>
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

This condition allows to define alloc_contig_range, so simplify
it into a more accurate naming.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/arm64/Kconfig                     | 2 +-
 arch/powerpc/platforms/Kconfig.cputype | 2 +-
 arch/s390/Kconfig                      | 2 +-
 arch/sh/Kconfig                        | 2 +-
 arch/sparc/Kconfig                     | 2 +-
 arch/x86/Kconfig                       | 2 +-
 arch/x86/mm/hugetlbpage.c              | 2 +-
 include/linux/gfp.h                    | 2 +-
 mm/Kconfig                             | 3 +++
 mm/page_alloc.c                        | 3 +--
 10 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..091a513b93e9 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -18,7 +18,7 @@ config ARM64
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PTE_SPECIAL
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 8c7464c3f27f..f677c8974212 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -319,7 +319,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index ed554b09eb3f..1c57b83c76f5 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -69,7 +69,7 @@ config S390
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 299a17bed67c..c7266302691c 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,7 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 0b7f0e0fefa5..ca33c80870e2 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -90,7 +90,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 68261430fe6e..8ba90f3e0038 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -23,7 +23,7 @@ config X86_64
 	def_bool y
 	depends on 64BIT
 	# Options that are inherently 64-bit kernel only:
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	select ARCH_SUPPORTS_INT128
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_SOFT_DIRTY
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 92e4c4b85bba..fab095362c50 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -203,7 +203,7 @@ static __init int setup_hugepagesz(char *opt)
 }
 __setup("hugepagesz=", setup_hugepagesz);
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#ifdef CONFIG_CONTIG_ALLOC
 static __init int gigantic_pages_init(void)
 {
 	/* With compaction or CMA we can allocate gigantic pages at runtime */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5f5e25fd6149..1f1ad9aeebb9 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -585,7 +585,7 @@ static inline bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#ifdef CONFIG_CONTIG_ALLOC
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..137eadc18732 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -258,6 +258,9 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 config ARCH_ENABLE_THP_MIGRATION
 	bool
 
+config CONTIG_ALLOC
+       def_bool (MEMORY_ISOLATION && COMPACTION) || CMA
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..ac9c45ffb344 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8024,8 +8024,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return true;
 }
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
-
+#ifdef CONFIG_CONTIG_ALLOC
 static unsigned long pfn_max_align_down(unsigned long pfn)
 {
 	return pfn & ~(max_t(unsigned long, MAX_ORDER_NR_PAGES,
-- 
2.20.1

