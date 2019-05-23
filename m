Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85D7DC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45CD02177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45CD02177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4557C6B0010; Thu, 23 May 2019 11:03:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E1736B0266; Thu, 23 May 2019 11:03:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 196EC6B0269; Thu, 23 May 2019 11:03:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDD2B6B0010
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:03:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y12so9414043ede.19
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:03:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ui0u17U43eS4rMS8Az194VeWDWEwmyWvLDsXU/OlQLo=;
        b=qKr+IOJ0dgv19NcdtTXlXbypXQRkAP3eVfleHuOSDAU4PUg5p79BQXip2Obg4iA0JQ
         2TQVjM7aBu5rQghyGwU7YmH39FA/ZG+ghbST4CdMXTnkJyj3iePyv1oxxjMLFWiHFz0C
         /uyPNy7mpAYC7gxScDW9RBo0N2sElCk9lT+IyzxdzOaC6X675Hrvt4JnVfYAffNvm7Bx
         HHFR3gFgDWJEGc3ZW2IyD5gJ4fdpgKRjT4jpiHOhsxI2aNXshwz3070qY08e4FfBRx8F
         6Zn7c3nOkBlmEuMO5+H61z6wAOJlKaOHEKtb4qt3RmGMqkWxgzmeUo4RmVhbToipi8bJ
         RTeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAX5tZhD4pkuM+NDpNzSeV+bJ/p5OZwAdOAp1tZkdQ7Z1tCReZRA
	ZioPKcgV+sM0AoZnSnZBf4xKbHbs2uGvxfs1B8onELGo/x9VuvES+u8qvN9tDVvo/do5Ol9ePVb
	Tz38Z5nXP3j7PAWPqK0vR3c4x4B5pq/WfB8Q3+YTnY6ymSo/adNcKTA780SmwiFSKtA==
X-Received: by 2002:a50:f5d9:: with SMTP id x25mr95690286edm.128.1558623816212;
        Thu, 23 May 2019 08:03:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlB50joiOwayYhHchY9EOHxi24JduABxyxunBm1yqxO06QAfsfr9tx1/ZOJDTFqKxx8X31
X-Received: by 2002:a50:f5d9:: with SMTP id x25mr95690122edm.128.1558623814771;
        Thu, 23 May 2019 08:03:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558623814; cv=none;
        d=google.com; s=arc-20160816;
        b=SCWGuKSvvfu3jpcZlT2flQllltU8hkVD/2c8sPB0LGzS3jx0aNNkPh084LkK46pkgQ
         1Wni58pALkABBSMp0D/0i28eQviS8VtktlFBbedFvgQczHh/kB39Ppq+g3CmMwuk0Eoj
         Wq33QqCDSR395PIN2aAzOSlj9bBrL1r3Z28r2t/SJyHuf3fA2GF49qTslkezbJ0769uP
         qbVZnjhYuEpeuockI1w3QjJKcs19UQogtyOwkMapIV4CvJQ/AnbWyWWoh+Q8fooCldiM
         AwYQjeIBriOSqHoFgPLQUNQZEI13Rb47lBVfvKA7ZvrP2bxMWvRfIONK6I3fnSe9RIz4
         /IYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Ui0u17U43eS4rMS8Az194VeWDWEwmyWvLDsXU/OlQLo=;
        b=AwZgXCXcVGRCLJDw4+Yz3z8HHQzdigsbD00PUl9EQ7Fp7XpwRMiK4XlAzXPNlUEp7u
         4/EQX3Jij2EzEtGj7aLkhv7BavJTqhIkkt4TRH5An/fEm7Xe0wFtPWnHGvdP1d7MFYMP
         dqc2zLBeABTunevwua8Kw1a7jn19/WTlYQ6awzKlKLu2yVJJRiD8qKgrmoqIJu/A6IET
         +HkD9PjF+jiLM1I/iaCeBlEBWge0vgNSOXaGQmFo18XQGUtxDUjUm4tfajWjlu4ePuGY
         E3q4vroMv9Qa4Gen2GD8p/jyKMrhrzrn6asfqwJjmRWBkMO4mbv0a7yB+ZR/ZZr9d9Ec
         cTkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g4si8019294ejw.305.2019.05.23.08.03.34
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:03:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6DE8115BF;
	Thu, 23 May 2019 08:03:33 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 0BDDB3F690;
	Thu, 23 May 2019 08:03:31 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 4/4] arm64: mm: Implement pte_devmap support
Date: Thu, 23 May 2019 16:03:16 +0100
Message-Id: <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1558547956.git.robin.murphy@arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order for things like get_user_pages() to work on ZONE_DEVICE memory,
we need a software PTE bit to identify device-backed PFNs. Hook this up
along with the relevant helpers to join in with ARCH_HAS_PTE_DEVMAP.

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 arch/arm64/Kconfig                    |  1 +
 arch/arm64/include/asm/pgtable-prot.h |  1 +
 arch/arm64/include/asm/pgtable.h      | 19 +++++++++++++++++++
 3 files changed, 21 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4780eb7af842..b5a4611fa4c6 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -23,6 +23,7 @@ config ARM64
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_KEEPINITRD
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
+	select ARCH_HAS_PTE_DEVMAP
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SETUP_DMA_OPS
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
index 986e41c4c32b..af0b372d15e5 100644
--- a/arch/arm64/include/asm/pgtable-prot.h
+++ b/arch/arm64/include/asm/pgtable-prot.h
@@ -28,6 +28,7 @@
 #define PTE_WRITE		(PTE_DBM)		 /* same as DBM (51) */
 #define PTE_DIRTY		(_AT(pteval_t, 1) << 55)
 #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
+#define PTE_DEVMAP		(_AT(pteval_t, 1) << 57)
 #define PTE_PROT_NONE		(_AT(pteval_t, 1) << 58) /* only when !PTE_VALID */
 
 #ifndef __ASSEMBLY__
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 2c41b04708fe..a6378625d47c 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -90,6 +90,7 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
 #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
 #define pte_user_exec(pte)	(!(pte_val(pte) & PTE_UXN))
 #define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
+#define pte_devmap(pte)		(!!(pte_val(pte) & PTE_DEVMAP))
 
 #define pte_cont_addr_end(addr, end)						\
 ({	unsigned long __boundary = ((addr) + CONT_PTE_SIZE) & CONT_PTE_MASK;	\
@@ -217,6 +218,11 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
 	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
 }
 
+static inline pte_t pte_mkdevmap(pte_t pte)
+{
+	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
+}
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	WRITE_ONCE(*ptep, pte);
@@ -381,6 +387,9 @@ static inline int pmd_protnone(pmd_t pmd)
 
 #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
 
+#define pmd_devmap(pmd)		pte_devmap(pmd_pte(pmd))
+#define pmd_mkdevmap(pmd)	pte_pmd(pte_mkdevmap(pmd_pte(pmd)))
+
 #define __pmd_to_phys(pmd)	__pte_to_phys(pmd_pte(pmd))
 #define __phys_to_pmd_val(phys)	__phys_to_pte_val(phys)
 #define pmd_pfn(pmd)		((__pmd_to_phys(pmd) & PMD_MASK) >> PAGE_SHIFT)
@@ -537,6 +546,11 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
 	return __pud_to_phys(pud);
 }
 
+static inline int pud_devmap(pud_t pud)
+{
+	return 0;
+}
+
 /* Find an entry in the second-level page table. */
 #define pmd_index(addr)		(((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1))
 
@@ -624,6 +638,11 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
 
 #define pgd_ERROR(pgd)		__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
 
+static inline int pgd_devmap(pgd_t pgd)
+{
+	return 0;
+}
+
 /* to find an entry in a page-table-directory */
 #define pgd_index(addr)		(((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))
 
-- 
2.21.0.dirty

