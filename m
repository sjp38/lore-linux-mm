Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA1C4C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72A3F2054F
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="G8LOT4PF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72A3F2054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E217D6B0271; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5B6F6B0272; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEA886B0274; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50BE46B0271
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:42:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id y187so9262660pgd.1
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:42:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BBXXT9xa9mrRhIGkEBsSxPqH41gwjewyswp0iGthWuw=;
        b=crPbPK6NJ4noRdoPS8rMPbx4zHRCIpuZroWubSQsefYbp70fXnLn4i0zFEYlS5Wqi5
         UHhwRX4BEJRiqMlkwaEY337nYIcC2yv+O1oo6JFiM5wc5/PH2gnZQ95txJ9tSP7K+puf
         qt+zmG8f9nImKuhJ30jYQHTvrcZ+uzcvqrj9JG1PjoWRL98GkVasULlRCYdifDf6VvOk
         VEpDEQIOFIqfXAgcCdfKSCWLZf9VuRpVa52YEvKnKNXRQAwHR1HIrwsJV0Z/84vs/DWh
         bedMHBtX3Z8A2bxLxlgqvJ3Bl1UIQoIZReWhOz7XXuzQYEDwDNOEVMqkbpBEd7UxCmtt
         pIPA==
X-Gm-Message-State: APjAAAU3ilZwqJNdOarQsB2PHEpAw02lXKejkqEWGzrRN2qMdKfX4KS0
	3EkceSaBk62sQ+31t6+T5xeO/1XESBeHJ+IM8xd/t823XUzoWTnoW8H2IBDkM45zj7RrYmwniq1
	J9spoiYxay4QuhPxgkBXHYP0p4CC7K0TetpuhZl+Vv1iGk+iahLyBLSys2M492Pk=
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr75500521plb.334.1560264124886;
        Tue, 11 Jun 2019 07:42:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy45OfGWvTb9AxSExJTK3klNKsU49lZSm9XnLnCxYXRfkW6EGPDbrNIfrGpV71lYO3TLpS1
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr75500436plb.334.1560264123900;
        Tue, 11 Jun 2019 07:42:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264123; cv=none;
        d=google.com; s=arc-20160816;
        b=sKOfh5DbVl9ojuycs5den9RUHUKEJ4ED2KF6a+9e264WwhI1nmdx+7+zeRM587RYb3
         vW4jWo4/zc5v2rjF0R/sdRNOjx52IbxvFSnKFMq6MYV+kFy/o+6uYLKx1UCoa6yOMhnb
         LtR2rod8WUYhZC5FEf97+mKnQkJhVvSujInz9a5m72eFSMyIukDq2IR/FSschTYl6+mT
         8ab7e6VlHynezzuknVvzSnv0q9TGBeSoWq+1Vhu+bW8EXJtUSgfB4AVvKxUI1Rv7vQaN
         w2QNbFAkE72MuAQe1/Qlgz0dqszaaery4ZPxhwEotDCsJ+PeZ5BQjV7h4lZJIa2M3Q4K
         vz4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BBXXT9xa9mrRhIGkEBsSxPqH41gwjewyswp0iGthWuw=;
        b=QoOMhK0kXTwjxK9jHHmFx+7fVxtD7H1QjNWZ+orvN2Ah8sDHlgjFWHTkj2ttGYzt7x
         XFeaA3JmcETRxL5cBoxOy3CoKDJnT0lcuLwN1p1tzvgV3pqKYxcBro5F67mEQ012u3RJ
         IOHpGFBvJ7lrHXY/Y7fOkqitVaIb2jc+pXEG+Qg1Q4G+Jn3uvS4zjHau5owx7VCNU1o+
         bxRFMitIGzixGbOn7ix8U/nl3QpjLgZHSwqnpjCxeld+8t10MDgfQK4Gf5OpMkQSgIv2
         ZtRWBMKSi4XDpSGTrBn6HFTxic/kg2vOR1c4uHSe5oVvXlSoMMb5GsHMDXB1TrFd2bQC
         TwFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G8LOT4PF;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z10si3686721pgh.30.2019.06.11.07.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:42:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G8LOT4PF;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=BBXXT9xa9mrRhIGkEBsSxPqH41gwjewyswp0iGthWuw=; b=G8LOT4PF2yvCs1mHkYytZqaKeQ
	xEujP5jOt56yiaI+d8fgDk4Xmq480Lul6ae1hHIRTkyZ4l7d6Fsri/dNIUK9LffjZeavJwiShIBZe
	Q44n5eKUC+iTdz7NZezLbHWpMZoll7MPwJGN4b+uFUK/T3Wp6fklHarEf9lPLlQsbnIV2Ppjy6PC2
	aEKuoSGKW0MabJ7AF8PN1lRrSYS8/EUd9PN10WcpUVfYQl5IsiolX/4XUXYwV+6XNGn1jowk49CzR
	O7mStspTewveegDCsMZIAXSzkHajsbpdPgODgDrKkW1Ef97kDEoc2nmsBeNk3X+3EarOGJxgFUb9c
	vjWvJ/5A==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahy5-0005dm-5p; Tue, 11 Jun 2019 14:41:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/16] mm: move the powerpc hugepd code to mm/gup.c
Date: Tue, 11 Jun 2019 16:40:59 +0200
Message-Id: <20190611144102.8848-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
References: <20190611144102.8848-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

While only powerpc supports the hugepd case, the code is pretty
generic and I'd like to keep all GUP internals in one place.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig          |  1 +
 arch/powerpc/mm/hugetlbpage.c | 72 ------------------------------
 include/linux/hugetlb.h       | 18 --------
 mm/Kconfig                    | 10 +++++
 mm/gup.c                      | 82 +++++++++++++++++++++++++++++++++++
 5 files changed, 93 insertions(+), 90 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 992a04796e56..4f1b00979cde 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -125,6 +125,7 @@ config PPC
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_KCOV
+	select ARCH_HAS_HUGEPD			if HUGETLB_PAGE
 	select ARCH_HAS_MMIOWB			if PPC64
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index b5d92dc32844..51716c11d0fb 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -511,13 +511,6 @@ struct page *follow_huge_pd(struct vm_area_struct *vma,
 	return page;
 }
 
-static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
-				      unsigned long sz)
-{
-	unsigned long __boundary = (addr + sz) & ~(sz-1);
-	return (__boundary - 1 < end - 1) ? __boundary : end;
-}
-
 #ifdef CONFIG_PPC_MM_SLICES
 unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 					unsigned long len, unsigned long pgoff,
@@ -665,68 +658,3 @@ void flush_dcache_icache_hugepage(struct page *page)
 		}
 	}
 }
-
-static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
-		       unsigned long end, int write, struct page **pages, int *nr)
-{
-	unsigned long pte_end;
-	struct page *head, *page;
-	pte_t pte;
-	int refs;
-
-	pte_end = (addr + sz) & ~(sz-1);
-	if (pte_end < end)
-		end = pte_end;
-
-	pte = READ_ONCE(*ptep);
-
-	if (!pte_access_permitted(pte, write))
-		return 0;
-
-	/* hugepages are never "special" */
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-	refs = 0;
-	head = pte_page(pte);
-
-	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
-	do {
-		VM_BUG_ON(compound_head(page) != head);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-
-	if (!page_cache_add_speculative(head, refs)) {
-		*nr -= refs;
-		return 0;
-	}
-
-	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-		/* Could be optimized better */
-		*nr -= refs;
-		while (refs--)
-			put_page(head);
-		return 0;
-	}
-
-	return 1;
-}
-
-int gup_huge_pd(hugepd_t hugepd, unsigned long addr, unsigned int pdshift,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	pte_t *ptep;
-	unsigned long sz = 1UL << hugepd_shift(hugepd);
-	unsigned long next;
-
-	ptep = hugepte_offset(hugepd, addr, pdshift);
-	do {
-		next = hugepte_addr_end(addr, end, sz);
-		if (!gup_hugepte(ptep, sz, addr, end, write, pages, nr))
-			return 0;
-	} while (ptep++, addr = next, addr != end);
-
-	return 1;
-}
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edf476c8cfb9..0f91761e2c53 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -16,29 +16,11 @@ struct user_struct;
 struct mmu_gather;
 
 #ifndef is_hugepd
-/*
- * Some architectures requires a hugepage directory format that is
- * required to support multiple hugepage sizes. For example
- * a4fe3ce76 "powerpc/mm: Allow more flexible layouts for hugepage pagetables"
- * introduced the same on powerpc. This allows for a more flexible hugepage
- * pagetable layout.
- */
 typedef struct { unsigned long pd; } hugepd_t;
 #define is_hugepd(hugepd) (0)
 #define __hugepd(x) ((hugepd_t) { (x) })
-static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
-			      unsigned pdshift, unsigned long end,
-			      int write, struct page **pages, int *nr)
-{
-	return 0;
-}
-#else
-extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
-		       unsigned pdshift, unsigned long end,
-		       int write, struct page **pages, int *nr);
 #endif
 
-
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
diff --git a/mm/Kconfig b/mm/Kconfig
index 5c41409557da..44be3f01a2b2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -769,4 +769,14 @@ config GUP_GET_PTE_LOW_HIGH
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
+#
+# Some architectures require a special hugepage directory format that is
+# required to support multiple hugepage sizes. For example a4fe3ce76
+# "powerpc/mm: Allow more flexible layouts for hugepage pagetables"
+# introduced it on powerpc.  This allows for a more flexible hugepage
+# pagetable layouts.
+#
+config ARCH_HAS_HUGEPD
+	bool
+
 endmenu
diff --git a/mm/gup.c b/mm/gup.c
index 78dc1871b3d4..494aa4c3a55e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1967,6 +1967,88 @@ static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
 }
 #endif
 
+#ifdef CONFIG_ARCH_HAS_HUGEPD
+static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
+				      unsigned long sz)
+{
+	unsigned long __boundary = (addr + sz) & ~(sz-1);
+	return (__boundary - 1 < end - 1) ? __boundary : end;
+}
+
+static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
+		       unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long pte_end;
+	struct page *head, *page;
+	pte_t pte;
+	int refs;
+
+	pte_end = (addr + sz) & ~(sz-1);
+	if (pte_end < end)
+		end = pte_end;
+
+	pte = READ_ONCE(*ptep);
+
+	if (!pte_access_permitted(pte, write))
+		return 0;
+
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	refs = 0;
+	head = pte_page(pte);
+
+	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+		/* Could be optimized better */
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+		unsigned int pdshift, unsigned long end, int write,
+		struct page **pages, int *nr)
+{
+	pte_t *ptep;
+	unsigned long sz = 1UL << hugepd_shift(hugepd);
+	unsigned long next;
+
+	ptep = hugepte_offset(hugepd, addr, pdshift);
+	do {
+		next = hugepte_addr_end(addr, end, sz);
+		if (!gup_hugepte(ptep, sz, addr, end, write, pages, nr))
+			return 0;
+	} while (ptep++, addr = next, addr != end);
+
+	return 1;
+}
+#else
+static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+		unsigned pdshift, unsigned long end, int write,
+		struct page **pages, int *nr)
+{
+	return 0;
+}
+#endif /* CONFIG_ARCH_HAS_HUGEPD */
+
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, unsigned int flags, struct page **pages, int *nr)
 {
-- 
2.20.1

