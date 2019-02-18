Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 993C7C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:13:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D442218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:13:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Kim7VCp0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D442218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6917D8E0003; Mon, 18 Feb 2019 18:13:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6199B8E0002; Mon, 18 Feb 2019 18:13:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BAD28E0003; Mon, 18 Feb 2019 18:13:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED458E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:13:26 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id z3so1379144itj.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 15:13:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U/EYw2rlCI4mDqlXBqXNVekL8hDo+V+cu5waHUfY2FU=;
        b=f8lPMHYBR2CH9WjWc2Q6H37mkT7sJAG83rJJorsbiQKaJ3aYuETRo9M4L4DJUB17QF
         xdFgfzCjyl51OoX+KBd5OL1/CrqI0CKG8Yb0ZMp9rpYw/zJNot3/48ybHJzP1QEKkzPn
         u5SYNCG39jPIrXjmKIs+tDAReRljpMG9TmN0Dh5klvCqIx+r+S9jVPBxGicXXJn7PfWI
         DJ6fbUtKL9sphgsT0h4NMd7JnxGjirR+pHABzlK/1BAPZ8u87hkxSdKCnLR4ScnoB51x
         6e9gwl5228xRYZ3nlHKeYuklfLEyg6//xP9XVcSK7H3ZrwV4A6SVdVf6NKETYKvmuvnL
         PeWw==
X-Gm-Message-State: AHQUAubMTr7m9dEY3eayjYkfe48LkzYwYD12BrjebJmxbuOytUmhjGch
	Nko33PjLj8IbwyAJBWX3BrJR4YZeKj9FiN3usqWSA9nVJOA80++OoY1ZI5X1e0bWhr9Dlng2k5R
	X9BNcMFMCtV69EbAgIJxcJ8069LLzpqa/SbMhxhmVje2Y0qDYqmZ03PpsQV2k1Zy4fnu6NzFcNj
	MpAuWrGSeweX+x3Zt0mCsUEG/SA4OcXBuHoH1K5vYAPT7ZbpAedesgEbRlY/+XS2NrXyLJK1zjM
	0DvZCKRh0HZloPSpNdT2bySrD3JTZMSpMhI1z0Sx8GDNzkjNad+i41yQyii0mYQTmRaxhRbETC3
	7grzQUrlmw0vJvf+n98GfA5MGkoSfu5+Q2HFH2D7GCdAa2/kQk6Sml+yB+ZF4ckwNFtMDV1k+g4
	M
X-Received: by 2002:a6b:d81a:: with SMTP id y26mr16607840iob.221.1550531605806;
        Mon, 18 Feb 2019 15:13:25 -0800 (PST)
X-Received: by 2002:a6b:d81a:: with SMTP id y26mr16607812iob.221.1550531605147;
        Mon, 18 Feb 2019 15:13:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550531605; cv=none;
        d=google.com; s=arc-20160816;
        b=s4W33muK4A/wJng/LFS34bevHkCdM5NVh87AinYxi8qGLiW6UP7P6mb0rJk6MBVq6I
         uMnidO9U+7hmwKalx+SPaEq41FSWJVLBqiYXkZN3P6CgXjw0x6S5NEVEwVE48QJpmfgG
         VWEjC02CbMw9LzkQ5ivjet16a/F2xFY67xSGBmil5OgDu8Vtlw55nmO0Z+uV3ixvEfkY
         SY2Ou+WSF3BIpvZNjvswpQaBOeMVUnhDzpkLoKoqeQ3TKVsfomKDhoF1E/3/YEk9LV79
         3D+GeFDTRgYUKxB/TH3Qt2LVOk6MpCxaTVu+YBp+g3HQVh7xm6YiL9v+qzKO7Rn1d/el
         Bq/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=U/EYw2rlCI4mDqlXBqXNVekL8hDo+V+cu5waHUfY2FU=;
        b=BmOQrwCAGKOKETjq2UHsy2fD4SSbnCmsVgYEbQ2yTYQ7/+N8WfKu46wkvh3Rwda+iv
         Sv5UGyWVK0aH1tEaPfO6hrH4twc5vFiwQsnGCCg2bE+jqFvK+ulT0dwNgZSamwhUw4kL
         q4sy3mL9x8ppLlj2J5L5pScs56CCtrubXGzrdbJr2qkATVgnjCocZ/ANrq0wm4XZRfVD
         npum1iDDbOjAxn63p91fJiTTi4GOVeo0KyUiDzU9w/yyPmkC5q0fpOYxuJpXGo03C20l
         oMrOYNxUze9ZTl+xhD+mAbPYgvPO1bGNZ8vPit2fkH1umLWu1Cee4Dba2hgCVJQWEkPG
         so1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Kim7VCp0;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h202sor1227251ith.17.2019.02.18.15.13.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 15:13:25 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Kim7VCp0;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=U/EYw2rlCI4mDqlXBqXNVekL8hDo+V+cu5waHUfY2FU=;
        b=Kim7VCp0StMXRnvvAWqYcMEpvO63kYz5zHERRNvlruuQQyJ/O/6e+78airAc6V3njt
         QPh65tXH7igo5M8n9Y+AY35NXYR4O99incnRtGZjj5tDT4G/3SpUfm/d5+VrXm3QMc14
         75MeWggtjgmG93XKz8SbkdnbNJxnW40gBOu2nYy4fTAaAZalUyFgJHBLbbsFBZcpmf7r
         gIqdQ766/KCsrLwCM+YpAq/CN78i4u/aY+3DZvUca0RcFYIOEnylrKumqeycBQkWaONH
         MUXpvu3EkRdDRMckSlclBjo8KbsFUEzseKNLXMHT/gA5Kd3J8udX+m6D9rsbbBHZIn4Z
         4luA==
X-Google-Smtp-Source: AHgI3IZhDNTkjmRqX5ciPMAt1QHx6yCLXNgtuFuVzvtd4/Fv0kqYiBMJG132E3NRHTpB/NiNuEH4qw==
X-Received: by 2002:a24:918c:: with SMTP id i134mr744158ite.92.1550531604541;
        Mon, 18 Feb 2019 15:13:24 -0800 (PST)
Received: from yuzhao.bld.corp.google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id x23sm6541463ion.38.2019.02.18.15.13.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 15:13:23 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Date: Mon, 18 Feb 2019 16:13:17 -0700
Message-Id: <20190218231319.178224-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <20190214211642.2200-1-yuzhao@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pte page, use pgtable_page_ctor(); for pmd page, use
pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
p4d and pgd), don't use any.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/mm/mmu.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index b6f5aa52ac67..fa7351877af3 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -98,7 +98,7 @@ pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 }
 EXPORT_SYMBOL(phys_mem_access_prot);
 
-static phys_addr_t __init early_pgtable_alloc(void)
+static phys_addr_t __init early_pgtable_alloc(int shift)
 {
 	phys_addr_t phys;
 	void *ptr;
@@ -173,7 +173,7 @@ static void init_pte(pmd_t *pmdp, unsigned long addr, unsigned long end,
 static void alloc_init_cont_pte(pmd_t *pmdp, unsigned long addr,
 				unsigned long end, phys_addr_t phys,
 				pgprot_t prot,
-				phys_addr_t (*pgtable_alloc)(void),
+				phys_addr_t (*pgtable_alloc)(int),
 				int flags)
 {
 	unsigned long next;
@@ -183,7 +183,7 @@ static void alloc_init_cont_pte(pmd_t *pmdp, unsigned long addr,
 	if (pmd_none(pmd)) {
 		phys_addr_t pte_phys;
 		BUG_ON(!pgtable_alloc);
-		pte_phys = pgtable_alloc();
+		pte_phys = pgtable_alloc(PAGE_SHIFT);
 		__pmd_populate(pmdp, pte_phys, PMD_TYPE_TABLE);
 		pmd = READ_ONCE(*pmdp);
 	}
@@ -207,7 +207,7 @@ static void alloc_init_cont_pte(pmd_t *pmdp, unsigned long addr,
 
 static void init_pmd(pud_t *pudp, unsigned long addr, unsigned long end,
 		     phys_addr_t phys, pgprot_t prot,
-		     phys_addr_t (*pgtable_alloc)(void), int flags)
+		     phys_addr_t (*pgtable_alloc)(int), int flags)
 {
 	unsigned long next;
 	pmd_t *pmdp;
@@ -245,7 +245,7 @@ static void init_pmd(pud_t *pudp, unsigned long addr, unsigned long end,
 static void alloc_init_cont_pmd(pud_t *pudp, unsigned long addr,
 				unsigned long end, phys_addr_t phys,
 				pgprot_t prot,
-				phys_addr_t (*pgtable_alloc)(void), int flags)
+				phys_addr_t (*pgtable_alloc)(int), int flags)
 {
 	unsigned long next;
 	pud_t pud = READ_ONCE(*pudp);
@@ -257,7 +257,7 @@ static void alloc_init_cont_pmd(pud_t *pudp, unsigned long addr,
 	if (pud_none(pud)) {
 		phys_addr_t pmd_phys;
 		BUG_ON(!pgtable_alloc);
-		pmd_phys = pgtable_alloc();
+		pmd_phys = pgtable_alloc(PMD_SHIFT);
 		__pud_populate(pudp, pmd_phys, PUD_TYPE_TABLE);
 		pud = READ_ONCE(*pudp);
 	}
@@ -293,7 +293,7 @@ static inline bool use_1G_block(unsigned long addr, unsigned long next,
 
 static void alloc_init_pud(pgd_t *pgdp, unsigned long addr, unsigned long end,
 			   phys_addr_t phys, pgprot_t prot,
-			   phys_addr_t (*pgtable_alloc)(void),
+			   phys_addr_t (*pgtable_alloc)(int),
 			   int flags)
 {
 	unsigned long next;
@@ -303,7 +303,7 @@ static void alloc_init_pud(pgd_t *pgdp, unsigned long addr, unsigned long end,
 	if (pgd_none(pgd)) {
 		phys_addr_t pud_phys;
 		BUG_ON(!pgtable_alloc);
-		pud_phys = pgtable_alloc();
+		pud_phys = pgtable_alloc(PUD_SHIFT);
 		__pgd_populate(pgdp, pud_phys, PUD_TYPE_TABLE);
 		pgd = READ_ONCE(*pgdp);
 	}
@@ -344,7 +344,7 @@ static void alloc_init_pud(pgd_t *pgdp, unsigned long addr, unsigned long end,
 static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
 				 unsigned long virt, phys_addr_t size,
 				 pgprot_t prot,
-				 phys_addr_t (*pgtable_alloc)(void),
+				 phys_addr_t (*pgtable_alloc)(int),
 				 int flags)
 {
 	unsigned long addr, length, end, next;
@@ -370,11 +370,20 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
 	} while (pgdp++, addr = next, addr != end);
 }
 
-static phys_addr_t pgd_pgtable_alloc(void)
+static phys_addr_t pgd_pgtable_alloc(int shift)
 {
 	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
-	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
-		BUG();
+	BUG_ON(!ptr);
+
+	/*
+	 * Initialize page table locks in case later we need to
+	 * call core mm functions like apply_to_page_range() on
+	 * this pre-allocated page table.
+	 */
+	if (shift == PAGE_SHIFT)
+		BUG_ON(!pgtable_page_ctor(virt_to_page(ptr)));
+	else if (shift == PMD_SHIFT && PMD_SHIFT != PUD_SHIFT)
+		BUG_ON(!pgtable_pmd_page_ctor(virt_to_page(ptr)));
 
 	/* Ensure the zeroed page is visible to the page table walker */
 	dsb(ishst);
-- 
2.21.0.rc0.258.g878e2cd30e-goog

