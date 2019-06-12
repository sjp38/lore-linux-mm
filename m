Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48AA5C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 019BA21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 019BA21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A63A6B0266; Wed, 12 Jun 2019 11:20:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 756AF6B0269; Wed, 12 Jun 2019 11:20:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A8676B026A; Wed, 12 Jun 2019 11:20:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id E53796B0266
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:20:43 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id a1so2745216lfi.16
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:20:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3Sclql3dvSZFf/V+1y7l8v94/Rp4TDjyKr6qABVkiR4=;
        b=LzuhNj5aaL2gPkkCj0d+Vnc74xWV7uDND5m2nmZbKqt9uQW/bPErsiFMcvWlgRfoLM
         001u88RcVG7RhLO/Pr6t3b//T6NiDUv2rZ85G101p9AV1lc0sVsTGREYWVyyK/sO2OA3
         Y65IYdJBKuMg7BhD/Z9OyjZcq57vQRp/tSumFzSGOgxCws+czbBfOntgmUfXY9i0Zy/g
         b4dM02UaDW4Iy3i/sNCODUeZnLq5taz+SQLoPzXmrAPE6rcT7oaR7cNN8BfDOF0mhkEo
         YxjskTn88qtuzvsShwFtC0nFFmGkO+cvyP9XhBks7Lvs5aGZEb28D0/OIDY1BqfuJgt6
         CSKQ==
X-Gm-Message-State: APjAAAVjqorBamvKSDqsRZC3icaAMmNGpAt6+KxSv1Y+vxnjeVXS04f3
	EWHnM9LqvMHsbDAh/oByrZtTJ8soRT3yRb0LlvXeeASy6IeWH2f7gGbFggCa1lAtRyNG6t/aZOy
	rRrJmTP3h4hL1qceudeS5/gG9mCeU5z0RWcRmuI2wWuwKzsqabDcytSbWMz6wEbjozw==
X-Received: by 2002:ac2:5337:: with SMTP id f23mr1798649lfh.15.1560352843364;
        Wed, 12 Jun 2019 08:20:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMvT+VUyUXCdb4OMW5DNB856no+9AwJJobnHGmUKtHv2JlV8j5tSJ1E6cdU5ElQmbI2bRQ
X-Received: by 2002:ac2:5337:: with SMTP id f23mr1798571lfh.15.1560352841905;
        Wed, 12 Jun 2019 08:20:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560352841; cv=none;
        d=google.com; s=arc-20160816;
        b=HUMVyPPLnO1GYDfQ4niBA8VYMWNJN+oC5I8YGEf/r0tGpbaAEYBmjhOvGOUrD+s7Vw
         Yv+VrTd9u++BWlpZ3DZImOwOjRho0gEBOQME+BPSMYUCF9sBOYWVoy+Wq5zXtFFaT0u5
         JRmXQD3HHg5fL7aPIc8DCaTu73W6GtM6f6JRmOqIUpMr+9rnYP8oaAyY8ZR4KNdrG7ZU
         WUWzB7TVZW+/Sql8ABqxQXVybSCGEXMSYhHIAPvmc7J43UJp+wGjVTa626lnndvgIsiV
         CzdmLtbCOqNuDt89GPBrw5p5HebhfxD7u/Mkj1vFvjHi1mgaj27AY9im/MBAXe1vwg9v
         cj/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3Sclql3dvSZFf/V+1y7l8v94/Rp4TDjyKr6qABVkiR4=;
        b=jN4sEpdeF2o0GItOSIF33YDRtNUWgb1jIH86qCpqQ0FcZe2/WQBevjBFlC+HcRsWVi
         vvEcOOISSjmoeZ5Jd/73hoRCJYdyQ23lgSsoiCyp1LEX3iFjtXP/qquW/E7NRc+bG2mw
         ruDitXdQSaV+d22Iu7gOPjDtu6FJ/BUnPJFpkOAUMPo4C9Qxb9lsDvM45Uogpetsc+BA
         6vVMwcWGtnNJqikpF70kvqTeNH3sqLkYZrWQ+OM9AQmPNZioRZH8iT5J4Uob+90faAl8
         z0r+DwNkoaHDR9XU96egW3NL9yHdcopm3SRjf/GzTQsYauON8vNcW/UjOh2tbILZA1Hs
         8pdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=FSWI6sRm;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id b20si7987472lfi.36.2019.06.12.08.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 08:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) client-ip=213.80.101.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=FSWI6sRm;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 81EC53FFD0;
	Wed, 12 Jun 2019 17:20:25 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=FSWI6sRm;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SjYhfxFOrPSz; Wed, 12 Jun 2019 17:20:11 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id E6A5E3FFCC;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 98822361C0E;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560352809;
	bh=MG0HfLcgqDRwxcPIDolCLkQDrfh6DF2qVfbCiXX/p4A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=FSWI6sRmNc0IzZObCPw4IFUggWR8mSWrzJ2XPrhdCvMWICcEBPcs1odxlfKbIUYov
	 cGsp2nd82qRocjzK7wBkFoIz0j9tTieIUaqJylj9P6oRC0/4yBu24DY33qbnfKqfOr
	 AOln+k7crrJs3zQ8MRqxdrjuIOl9SBtP+6S9dBac=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	hch@infradead.org,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v6 2/9] mm: Add an apply_to_pfn_range interface
Date: Wed, 12 Jun 2019 17:19:43 +0200
Message-Id: <20190612151950.2870-3-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190612151950.2870-1-thellstrom@vmwopensource.org>
References: <20190612151950.2870-1-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

This is basically apply_to_page_range with added functionality:
Allocating missing parts of the page table becomes optional, which
means that the function can be guaranteed not to error if allocation
is disabled. Also passing of the closure struct and callback function
becomes different and more in line with how things are done elsewhere.

Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_range

The reason for not using the page-walk code is that we want to perform
the page-walk on vmas pointing to an address space without requiring the
mmap_sem to be held rather than on vmas belonging to a process with the
mmap_sem held.

Notable changes since RFC:
Don't export apply_to_pfn range.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
---
 include/linux/mm.h |  10 ++++
 mm/memory.c        | 135 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 113 insertions(+), 32 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..3d06ce2a64af 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2675,6 +2675,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
+struct pfn_range_apply;
+typedef int (*pter_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
+			 struct pfn_range_apply *closure);
+struct pfn_range_apply {
+	struct mm_struct *mm;
+	pter_fn_t ptefn;
+	unsigned int alloc;
+};
+extern int apply_to_pfn_range(struct pfn_range_apply *closure,
+			      unsigned long address, unsigned long size);
 
 #ifdef CONFIG_PAGE_POISONING
 extern bool page_poisoning_enabled(void);
diff --git a/mm/memory.c b/mm/memory.c
index 168f546af1ad..462aa47f8878 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2032,18 +2032,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
 }
 EXPORT_SYMBOL(vm_iomap_memory);
 
-static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_pte_range(struct pfn_range_apply *closure, pmd_t *pmd,
+			      unsigned long addr, unsigned long end)
 {
 	pte_t *pte;
 	int err;
 	pgtable_t token;
 	spinlock_t *uninitialized_var(ptl);
 
-	pte = (mm == &init_mm) ?
+	pte = (closure->mm == &init_mm) ?
 		pte_alloc_kernel(pmd, addr) :
-		pte_alloc_map_lock(mm, pmd, addr, &ptl);
+		pte_alloc_map_lock(closure->mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
 
@@ -2054,86 +2053,109 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	token = pmd_pgtable(*pmd);
 
 	do {
-		err = fn(pte++, token, addr, data);
+		err = closure->ptefn(pte++, token, addr, closure);
 		if (err)
 			break;
 	} while (addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
 
-	if (mm != &init_mm)
+	if (closure->mm != &init_mm)
 		pte_unmap_unlock(pte-1, ptl);
 	return err;
 }
 
-static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_pmd_range(struct pfn_range_apply *closure, pud_t *pud,
+			      unsigned long addr, unsigned long end)
 {
 	pmd_t *pmd;
 	unsigned long next;
-	int err;
+	int err = 0;
 
 	BUG_ON(pud_huge(*pud));
 
-	pmd = pmd_alloc(mm, pud, addr);
+	pmd = pmd_alloc(closure->mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
+
 	do {
 		next = pmd_addr_end(addr, end);
-		err = apply_to_pte_range(mm, pmd, addr, next, fn, data);
+		if (!closure->alloc && pmd_none_or_clear_bad(pmd))
+			continue;
+		err = apply_to_pte_range(closure, pmd, addr, next);
 		if (err)
 			break;
 	} while (pmd++, addr = next, addr != end);
 	return err;
 }
 
-static int apply_to_pud_range(struct mm_struct *mm, p4d_t *p4d,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_pud_range(struct pfn_range_apply *closure, p4d_t *p4d,
+			      unsigned long addr, unsigned long end)
 {
 	pud_t *pud;
 	unsigned long next;
-	int err;
+	int err = 0;
 
-	pud = pud_alloc(mm, p4d, addr);
+	pud = pud_alloc(closure->mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
+
 	do {
 		next = pud_addr_end(addr, end);
-		err = apply_to_pmd_range(mm, pud, addr, next, fn, data);
+		if (!closure->alloc && pud_none_or_clear_bad(pud))
+			continue;
+		err = apply_to_pmd_range(closure, pud, addr, next);
 		if (err)
 			break;
 	} while (pud++, addr = next, addr != end);
 	return err;
 }
 
-static int apply_to_p4d_range(struct mm_struct *mm, pgd_t *pgd,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_p4d_range(struct pfn_range_apply *closure, pgd_t *pgd,
+			      unsigned long addr, unsigned long end)
 {
 	p4d_t *p4d;
 	unsigned long next;
-	int err;
+	int err = 0;
 
-	p4d = p4d_alloc(mm, pgd, addr);
+	p4d = p4d_alloc(closure->mm, pgd, addr);
 	if (!p4d)
 		return -ENOMEM;
+
 	do {
 		next = p4d_addr_end(addr, end);
-		err = apply_to_pud_range(mm, p4d, addr, next, fn, data);
+		if (!closure->alloc && p4d_none_or_clear_bad(p4d))
+			continue;
+		err = apply_to_pud_range(closure, p4d, addr, next);
 		if (err)
 			break;
 	} while (p4d++, addr = next, addr != end);
 	return err;
 }
 
-/*
- * Scan a region of virtual memory, filling in page tables as necessary
- * and calling a provided function on each leaf page table.
+/**
+ * apply_to_pfn_range - Scan a region of virtual memory, calling a provided
+ * function on each leaf page table entry
+ * @closure: Details about how to scan and what function to apply
+ * @addr: Start virtual address
+ * @size: Size of the region
+ *
+ * If @closure->alloc is set to 1, the function will fill in the page table
+ * as necessary. Otherwise it will skip non-present parts.
+ * Note: The caller must ensure that the range does not contain huge pages.
+ * The caller must also assure that the proper mmu_notifier functions are
+ * called before and after the call to apply_to_pfn_range.
+ *
+ * WARNING: Do not use this function unless you know exactly what you are
+ * doing. It is lacking support for huge pages and transparent huge pages.
+ *
+ * Return: Zero on success. If the provided function returns a non-zero status,
+ * the page table walk will terminate and that status will be returned.
+ * If @closure->alloc is set to 1, then this function may also return memory
+ * allocation errors arising from allocating page table memory.
  */
-int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
-			unsigned long size, pte_fn_t fn, void *data)
+int apply_to_pfn_range(struct pfn_range_apply *closure,
+		       unsigned long addr, unsigned long size)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -2143,16 +2165,65 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 	if (WARN_ON(addr >= end))
 		return -EINVAL;
 
-	pgd = pgd_offset(mm, addr);
+	pgd = pgd_offset(closure->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = apply_to_p4d_range(mm, pgd, addr, next, fn, data);
+		if (!closure->alloc && pgd_none_or_clear_bad(pgd))
+			continue;
+		err = apply_to_p4d_range(closure, pgd, addr, next);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
 
 	return err;
 }
+
+/**
+ * struct page_range_apply - Closure structure for apply_to_page_range()
+ * @pter: The base closure structure we derive from
+ * @fn: The leaf pte function to call
+ * @data: The leaf pte function closure
+ */
+struct page_range_apply {
+	struct pfn_range_apply pter;
+	pte_fn_t fn;
+	void *data;
+};
+
+/*
+ * Callback wrapper to enable use of apply_to_pfn_range for
+ * the apply_to_page_range interface
+ */
+static int apply_to_page_range_wrapper(pte_t *pte, pgtable_t token,
+				       unsigned long addr,
+				       struct pfn_range_apply *pter)
+{
+	struct page_range_apply *pra =
+		container_of(pter, typeof(*pra), pter);
+
+	return pra->fn(pte, token, addr, pra->data);
+}
+
+/*
+ * Scan a region of virtual memory, filling in page tables as necessary
+ * and calling a provided function on each leaf page table.
+ *
+ * WARNING: Do not use this function unless you know exactly what you are
+ * doing. It is lacking support for huge pages and transparent huge pages.
+ */
+int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
+			unsigned long size, pte_fn_t fn, void *data)
+{
+	struct page_range_apply pra = {
+		.pter = {.mm = mm,
+			 .alloc = 1,
+			 .ptefn = apply_to_page_range_wrapper },
+		.fn = fn,
+		.data = data
+	};
+
+	return apply_to_pfn_range(&pra.pter, addr, size);
+}
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
 /*
-- 
2.20.1

