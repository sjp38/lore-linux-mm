Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3EF8C43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 01:19:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6764D20836
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 01:19:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oPNZFD0u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6764D20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1D598E0003; Sat,  9 Mar 2019 20:19:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA5DB8E0002; Sat,  9 Mar 2019 20:19:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A467F8E0003; Sat,  9 Mar 2019 20:19:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 786678E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 20:19:11 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id m15so1281159ioc.16
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 17:19:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=0Yb2ivGv5k2eEZFqDaeb2AMWK/OeRIAqkI0UIANBdSk=;
        b=ojYIcLdmE3uM0Zmj8AF/cbNmPJH8poJWJr8yDpljxLoFBhaPxcKtNB5fZO9nDspOAs
         0t/Bv5PDV4q8b9fyKkPJ+aElqh1Gjwk+0YjjCj5ukL9UzVoAYswYfAkBHx+eEBl0U1Sz
         scH4MBEmpo70VK83yDVkfyP9xWK6AZLPjGLfLbjvbfqFEqaoTVRkxRC+MbOvWWE6tKLZ
         crNJteKzTORSOJekLS6KpLyDi2bogzuxCHABTdRdBHgbSnWYm/wHTCEIFplwk//d8mQC
         orf0pFvKhd9sxCjoObstcGpk+tkFV2yZhUVXcjv+Jlrhbe2/MDpc9gfJTKiCI2DpdpvA
         XpuQ==
X-Gm-Message-State: APjAAAXpeBFhQ9BjBPWqHwzk0MzbU5iPOA8r9Q/JanXhPyMdzd88TdAM
	3KIZoVw/sthWJd+IuevGwljZ3QUHX1g5XMx+6CnLMD7t9qybEZ9KogKeHY6jayL37cgXUqsYACd
	BN3TzO0vKBVwi4pbkH+CfeqMgcEkJYnFszks9ObflwafQz0RX74/g66YYOpNq0hX/FaT2U7IhGK
	L2P9MSS7t2jJfzLUOVVUAAbZoDyhbwQMndEoJg0O/42aw3hMwY8DcDL2ptRCdShnefYQDNtV24D
	3/BMRlNOpgmizLBc/QFeRUT3wmH8ELtI0enhVSqXMi3qhha3aOPLk0uq6gcI64ah0DU0mt/Uh7c
	KzDJeh/cdJe+GQFW6fwVfaiYEGZ2890CHnAqrt0wtaMww3/gjQfwy5pomJiFpsRaNePps/T8VKZ
	t
X-Received: by 2002:a02:8899:: with SMTP id n25mr15126857jaj.7.1552180751189;
        Sat, 09 Mar 2019 17:19:11 -0800 (PST)
X-Received: by 2002:a02:8899:: with SMTP id n25mr15126834jaj.7.1552180750133;
        Sat, 09 Mar 2019 17:19:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552180750; cv=none;
        d=google.com; s=arc-20160816;
        b=TdVR4+jcjqCiOPdThNhPQ/4PLN/aaiZFoX0HEe9sEBc4WK+wFBrYNn4eXBZrF6B+jE
         wj1yVJTcsEZlQK75AXNkNAgRZ9da4qg35c3uC3qCpFJApjnyzGBjLqsVIoaF2fpIxkvj
         KAmcdh6NNU1idt9Crrgli/DNgfhBCL/jvUYZ8SlwiNwzVIePI+h6twDIMlmeJ6mNy3O/
         W2AG8+PEKQGBKZoYV/BiCFBb17JTKAPQIbkycxKA3ntUudOFamTwoydQg5UdjSHA0Dyl
         QsGLS+bCQM9xXQEctxnfEjxGLyoDvXS+t2KsEhasQNLty6/gNb15NaaQ+aMX0U3arBv3
         7onQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=0Yb2ivGv5k2eEZFqDaeb2AMWK/OeRIAqkI0UIANBdSk=;
        b=SR/O2Nvldlo4WUHw+lro0KAuKOqvekvAUV9TJY4RLBnRIjIA/hfvNJ+k1cA6hQU7/K
         3fC/kiF/PnISU51IIwYB5COMLTUCLpDjK4cRFsydYJxcOV+RArG8Uvwj1px7ViOgDAjh
         4qyaaHY3bcuuy5yf6oiRlJIVaeC9STmVWk4WCu80GR9s6Qim2kvsgHyLRwI7gdLKmet2
         81TqUefC/IbdBbJ/ORWt1a6ctHR/GmUMMkYpWyWOjno+6Exe3m8cqAA8dBj1MV+r+uNK
         tJ/Rmhm60+Xn4+d+r0pnhsdpWkh/3oYFMXw5QbisFpNtoKJj9E9A4TYw63DiLqwqXems
         im1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oPNZFD0u;
       spf=pass (google.com: domain of 3dwaexaykcnqokp70e6ee6b4.2ecb8dkn-ccal02a.eh6@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3DWaEXAYKCNQOKP70E6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p67sor21828739itp.32.2019.03.09.17.19.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Mar 2019 17:19:10 -0800 (PST)
Received-SPF: pass (google.com: domain of 3dwaexaykcnqokp70e6ee6b4.2ecb8dkn-ccal02a.eh6@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oPNZFD0u;
       spf=pass (google.com: domain of 3dwaexaykcnqokp70e6ee6b4.2ecb8dkn-ccal02a.eh6@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3DWaEXAYKCNQOKP70E6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=0Yb2ivGv5k2eEZFqDaeb2AMWK/OeRIAqkI0UIANBdSk=;
        b=oPNZFD0u4/uhlNdesjj0nps43el+5vEaWETEUy12QTiHxMV+XS5yFbmZKISRtxFNG5
         dKWWoBBhXtJZPfcIT/oFsQor0CVaWiLlLS87tKNCYTv85G2XZg+Hv9r6tfnPFbIGY6Un
         SNGdRMg05dZskRUyqM2LIB5r6U28IbDBz5PJK/sgVrxMjBJtfSiF4GDger33PFbzQ3/V
         RdWI9nwiV6I7gLmISzKZ3dWTOEkVTwixb/Nob1jM7uiO4IABEGaAA33lL84qG5hGXKGb
         XMyAh6HfjdLukWrrG6lkqNzh+60rHUSwrcfxjOOObGKwXrTy2XupT/tlf5HU2vReBnn3
         ld9w==
X-Google-Smtp-Source: APXvYqzb7py1oPWQlx4fRa9Z+HVEK1bN2fB0qOGJMFr6UeE7WrMjrMYMPcQraL6qYk6xnNQti0o0/6kxf8A=
X-Received: by 2002:a05:660c:484:: with SMTP id a4mr16369624itk.15.1552180749805;
 Sat, 09 Mar 2019 17:19:09 -0800 (PST)
Date: Sat,  9 Mar 2019 18:19:04 -0700
In-Reply-To: <20190218231319.178224-1-yuzhao@google.com>
Message-Id: <20190310011906.254635-1-yuzhao@google.com>
Mime-Version: 1.0
References: <20190218231319.178224-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v3 1/3] arm64: mm: use appropriate ctors for page tables
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, 
	Peter Zijlstra <peterz@infradead.org>, Joel Fernandes <joel@joelfernandes.org>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>, 
	Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pte page, use pgtable_page_ctor(); for pmd page, use
pgtable_pmd_page_ctor(); and for the rest (pud, p4d and pgd),
don't use any.

For now, we don't select ARCH_ENABLE_SPLIT_PMD_PTLOCK and
pgtable_pmd_page_ctor() is a nop. When we do in patch 3, we
make sure pmd is not folded so we won't mistakenly call
pgtable_pmd_page_ctor() on pud or p4d.

Acked-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/mm/mmu.c | 36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index b6f5aa52ac67..f704b291f2c5 100644
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
@@ -370,11 +370,23 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
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
+	 * Call proper page table ctor in case later we need to
+	 * call core mm functions like apply_to_page_range() on
+	 * this pre-allocated page table.
+	 *
+	 * We don't select ARCH_ENABLE_SPLIT_PMD_PTLOCK if pmd is
+	 * folded, and if so pgtable_pmd_page_ctor() becomes nop.
+	 */
+	if (shift == PAGE_SHIFT)
+		BUG_ON(!pgtable_page_ctor(virt_to_page(ptr)));
+	else if (shift == PMD_SHIFT)
+		BUG_ON(!pgtable_pmd_page_ctor(virt_to_page(ptr)));
 
 	/* Ensure the zeroed page is visible to the page table walker */
 	dsb(ishst);
-- 
2.21.0.360.g471c308f928-goog

