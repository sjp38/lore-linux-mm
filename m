Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D490FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8382C214D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YtoTCa1F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8382C214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05B0D8E0003; Mon, 11 Mar 2019 20:58:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B838E0002; Mon, 11 Mar 2019 20:58:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E14A98E0003; Mon, 11 Mar 2019 20:58:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8D1A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:58:05 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id c188so1277506ywf.14
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:58:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=0Yb2ivGv5k2eEZFqDaeb2AMWK/OeRIAqkI0UIANBdSk=;
        b=XNrxg+hrDS4Z5FM4W9EZ46pNxnP/P6/ubW0Mh/zAz9W6H300E7BjosMIQ1QzSvHyVn
         jmgrlK/KZN0R+CCx2wxuydP0zak0bOumTAaVBlt4D0J2W0HhVFXS1Azuib3c1Vswt/ZJ
         PnWvNShZkFU9GX+6UzL52PajY6EDVicAreYdfJn+1kpnUZ6Us1D33tV28vn0+o3/P/pO
         nJu3xoh/8xsfg5ZWIkARMtU9ICkdAQbOomCbOXBYYkm2uYlduJoDPKKtWayek4p0o546
         WslQyEe/UlhGpyYVtTymkSGSqsDUbBdvh1r1hmVGSx70InWE6mW9sW/Sj/YSCOiMg4xU
         oMQQ==
X-Gm-Message-State: APjAAAVmvhpzQvnd55Yv4dK23fViRk2qKGpWyHG15HGrjSJCcjw9VZQi
	aVYF3WJW35HIjlCTAJP3QCMoE2kEz5wYJ6U0/UKkzz3xLUZ9JktWGhz6ekbGGTeS5c7kNetXMeL
	fY1dMrNVg7QU7Pi2lkao06aFvnxgQxSLnO+j6FIAIGzJcoRgZCX7WMMsbnIHsSrUieGSSd68f9p
	ujgCkyPy2xmWvzyLwSmZDXGlKkj49jcXAN4DcYNnxMkLZ59m+587++J2roCWgnaGoCQVAGrLfYW
	QlhxXnyJblyaIQJMRyEZVRahBMW/AFPX1iB5j3QTGKiRdCbkpIj7ZxVW07044d0MylNsq/7j+Wy
	23Wl7wLjQG5M+K/iXqiQ7JBElcOxC3ZxN+kwIxK9bt0tQnRqR6g7ik9QO0SRC00uFkqrEy5Mg3K
	2
X-Received: by 2002:a25:d882:: with SMTP id p124mr29644311ybg.72.1552352285439;
        Mon, 11 Mar 2019 17:58:05 -0700 (PDT)
X-Received: by 2002:a25:d882:: with SMTP id p124mr29644279ybg.72.1552352284553;
        Mon, 11 Mar 2019 17:58:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352284; cv=none;
        d=google.com; s=arc-20160816;
        b=hKAjlQgTeoH3bOOSYlnOKB9Gaz6CAPPIqWB9n5IDv/MgalvYwLqfGn0ShWWD/0i1my
         iO+KysIwjCz/Z+1If9GwayqknQ/sbniP36QsBkv6zAEuZ3ZMxzMxu/bGlTykW2nNOeF5
         MMIMwp0hY4/PAry3kujCIEFbiru0HMLT25C/kGw9QUDPVv5CTa3aUSyfqfu/YPSFOVGY
         MEO/nCW2kUjOjcFNg1SqnsuxHyhXyHueCAcjd2SE1IEjc94b5TMg4OI13eNGyZIS1p+m
         ohgerVIsi7SzMtlmLlvX8Igf1b4/DYaZ1xPcS1QGN59/BoZvmDwYK0yErwuxu+2HcxD6
         DnMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=0Yb2ivGv5k2eEZFqDaeb2AMWK/OeRIAqkI0UIANBdSk=;
        b=ZKXAbxoKInqsnSdRkjOjSjzn1Bfv6JaFdlOccAbNSfSn+2R/t7s1w3eJqqDB2kbqY2
         7IUxpbPQJWV81nOVJ61lZ2PqHDs1o+HSwCD1pzd1yEvnhJrWzumHhNVdnluwUXAGukpJ
         gnRaQxuUGpCmbKGa732uJdUw8HkNnDTEyUFoSAvt4/FWmfFj6UHSLjPTwDNuQJHshlNS
         GVrSa9CrcVfrNjM9YZZ7nJ+YhjLwMspPQBZgFZjIkpDw2e95TX/nl6HNihYalkmeWTzm
         +9bfTbBxBKVq/WdFQEHq4T2ZhMIiy1tuLEJ7CSquOVMYiDLTERi+u6QE8oVS2EyZnzq9
         VYug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YtoTCa1F;
       spf=pass (google.com: domain of 3hashxaykccsfbgohvnvvnsl.jvtspube-ttrchjr.vyn@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HASHXAYKCCsfbgOHVNVVNSL.JVTSPUbe-TTRcHJR.VYN@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 184sor3409124ybm.143.2019.03.11.17.58.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 17:58:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hashxaykccsfbgohvnvvnsl.jvtspube-ttrchjr.vyn@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YtoTCa1F;
       spf=pass (google.com: domain of 3hashxaykccsfbgohvnvvnsl.jvtspube-ttrchjr.vyn@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HASHXAYKCCsfbgOHVNVVNSL.JVTSPUbe-TTRcHJR.VYN@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=0Yb2ivGv5k2eEZFqDaeb2AMWK/OeRIAqkI0UIANBdSk=;
        b=YtoTCa1FsAa4SxSSy2t1RCEeLGZsCq3F9MmC82/HiNbwzc/7heOZhhMADajPy01n9b
         agSe/kw18UTudBiU7ksU8/SHwvlZlPyV9LhN6fTTgC8Pm6CxdX5WamzES1EemO0KXy/j
         decP+RthgSoxH0b7lDx3YgrKtEniFzHFTV9YD3AosSfoHuoGpJSZcij+2TA2ZsJbnnyd
         To+zhj0MEY+b7krt7yyKqMyeZJG/PoA+A8X8hCbGrS2l76904BOZGQ2g93sMN7LaVVvu
         yc2xlRSPhv8JbiOW+JO7nL/y8uBBxIr5HeyVp0+8N+nq2xCyLduG0F8nOgQDZH2I33Hs
         22eQ==
X-Google-Smtp-Source: APXvYqw+ll+HDtKzYX+8qYICIA45HG4qpRTQvEyf0AUjyPzgDXuQrmIOJztXx4aVqQDr6yzeNnT78JHSF9Y=
X-Received: by 2002:a25:949:: with SMTP id u9mr15976942ybm.8.1552352284196;
 Mon, 11 Mar 2019 17:58:04 -0700 (PDT)
Date: Mon, 11 Mar 2019 18:57:46 -0600
In-Reply-To: <20190310011906.254635-1-yuzhao@google.com>
Message-Id: <20190312005749.30166-1-yuzhao@google.com>
Mime-Version: 1.0
References: <20190310011906.254635-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v4 1/4] arm64: mm: use appropriate ctors for page tables
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

