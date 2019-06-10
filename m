Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 879DDC468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 206CB206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mSwnpaGl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 206CB206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC8FB6B0006; Mon, 10 Jun 2019 00:41:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7AEC6B0007; Mon, 10 Jun 2019 00:41:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 941336B0008; Mon, 10 Jun 2019 00:41:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53C626B0006
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:41:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1so6385017pfb.7
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:41:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=WprUKeEfMWXhdh9Vnjm94ZzvQwSvelV63YsiIiNMw9M=;
        b=i3eeCj7CXIsuhtN1+1qQpPI3nuyZwrX+eQI+LNSdSbUJLRTMQRjBH22u401fgO1vQ8
         1abAYb2fFmk5CNdLMv6WVUF/TwFQvQ8jNlHnXg4+tlun/zJeAYJ8sFIYeCT9sDLyOQZ9
         ley6D/2dvGi4N3lgU8jLdM0UhXzlJkCjvZxOVWqQ2fWC8LCsPPuQLzYQ1z8ODF0eg7Q/
         Q5lkojrW6hk43EmOcdd+aZGNsd9H9N7EFiz2H5yyH270EnbiTvqyJ/BTtrat+YACPUbI
         fSAJktRmjoQasdMIBUVJz/Otzet9F2QhVOOZ5SSbNWOWPPsBfLI4di5pAGoWmEUJRM8d
         lxDg==
X-Gm-Message-State: APjAAAW0pe+Sb/zIhZcQHXUC4Sg3q7XDJLq7zrWnW3E+qGIbU0Pkywmt
	KfJPTTAOSlhrM5ZUmDgjeJzld+KhM9+UxYZVqioQWcExd2TriZpafN+oMVYUeyEaBEM5vy1xzXq
	TvtMS2tzKcSesLfpp71xjm9PQxm8aVgRZ0tg/LuQC3znzQ6Wl6UlV26ICjKteIT6iHA==
X-Received: by 2002:a17:902:a81:: with SMTP id 1mr67977063plp.287.1560141663796;
        Sun, 09 Jun 2019 21:41:03 -0700 (PDT)
X-Received: by 2002:a17:902:a81:: with SMTP id 1mr67977002plp.287.1560141662287;
        Sun, 09 Jun 2019 21:41:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141662; cv=none;
        d=google.com; s=arc-20160816;
        b=H36OcqeqlJ2AaBxnSTuy3E3KJCh1heuskjUkDsdNK9A0PncDoFHgzecmIgh+d443pL
         o4R1MBwadhtn+gqVeBrHhoQIqPZVehng9VesQK+mvEYymhHWNgWI3iDFn5p/+7LFvERe
         YmJaiQa8ZXzuNltwzPTmsla8xgH+MhYAca1kmrp4d3msxCjQDemkpfY0mksIRwgEEtI7
         2YYIUznlY1aGbVrHR3mQkTz3NarjmC1iLE76cX/Sfns4KCtOXbauVp3a3F6+Y96fzeJt
         1eh/rmxVtfiTE2yu7u44EtQE7DcJN/avUhaCxUoWaY08xJmbs6XuFYEnh7vcrQKx2cf8
         MWPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=WprUKeEfMWXhdh9Vnjm94ZzvQwSvelV63YsiIiNMw9M=;
        b=fa19RW/qgrP4dJMg0gcRr62QjQ5qiRLy3zsPkQU6rqk4hexy0cuOt4TNMudip3/0IN
         3rxag2sxA5toOqiR6GmZcuZQuZsoPWTonVJQmK05ZmXlyljTU4sbdnLuJKqqBy4GuTRW
         2d6i/mixwDLlcjLxJLQ+tmJ6C7SySLZ5pf2p7Dt7bQSL5WQ8dgEBhaMnCvotO/lPqhvq
         tvM7gL6Nlayo6cL+RAXfFIpcICJHShfpRQ1cLxnHR9v48msI/xSrrHgOQ+wj33LC2UWH
         6/ZYeNoujzFy2L8glCCR7plbHq3LVfdoaCFzFchioXrKZs5R3gzVrY0tSlrv2WuaFFVT
         3eWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mSwnpaGl;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor8872924pfi.35.2019.06.09.21.41.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 21:41:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mSwnpaGl;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=WprUKeEfMWXhdh9Vnjm94ZzvQwSvelV63YsiIiNMw9M=;
        b=mSwnpaGlhM+pfDIfL6iZW5NFtqF9Aho3gdmDbAZJrBfc1x9FC/2tnaQTSCQi1VMLzx
         V919GC4MQkTlMifVkbR59kCLapV/GlRMlnyFQPeHui4Z8gdqWp8nzijcSifuDqevHR3z
         LZ8pzUf9Ve4gA8WmY8/p1TR7X61DRrBcz0JyY3xhO980DcQDX14BvvlrQGm7hrDV8IW8
         czjcMg1C8Oo89JyDx/h12QFWAMPvdxbha5ufy/z0n4Hp95z6z5MAEaKGtuKt4Mhol9YK
         dOiuyHqbdcQRQ+6ooUlKw1HwZmyQOum+1nBN9+2E1ETu5LC9mjip5KpRvQN5YUM2zrmd
         mzfQ==
X-Google-Smtp-Source: APXvYqxdWalE9oVbqiB4oHvpPSgdxqYkGs5siUIznVBKme8yjGRXTmtT5sfjxzJ2ZNCKnE0Ks4r4RQ==
X-Received: by 2002:a62:ed09:: with SMTP id u9mr72196459pfh.23.1560141661550;
        Sun, 09 Jun 2019 21:41:01 -0700 (PDT)
Received: from bobo.local0.net (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id l1sm9166802pgj.67.2019.06.09.21.40.58
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 21:41:01 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH 1/4] mm: Move ioremap page table mapping function to mm/
Date: Mon, 10 Jun 2019 14:38:35 +1000
Message-Id: <20190610043838.27916-1-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ioremap_page_range is a generic function to create a kernel virtual
mapping, move it to mm/vmalloc.c and rename it vmap_range.

For clarity with this move, also:
- Rename vunmap_page_range (vmap_range's inverse) to vunmap_range.
- Rename vmap_page_range (which takes a page array) to vmap_pages.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---

Fixed up the arm64 compile errors, fixed a few bugs, and tidied
things up a bit more.

Have tested powerpc and x86 but not arm64, would appreciate a review
and test of the arm64 patch if possible.

 include/linux/vmalloc.h |   3 +
 lib/ioremap.c           | 173 +++---------------------------
 mm/vmalloc.c            | 228 ++++++++++++++++++++++++++++++++++++----
 3 files changed, 229 insertions(+), 175 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 51e131245379..812bea5866d6 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -147,6 +147,9 @@ extern struct vm_struct *find_vm_area(const void *addr);
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
 #ifdef CONFIG_MMU
+extern int vmap_range(unsigned long addr,
+		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+		       unsigned int max_page_shift);
 extern int map_kernel_range_noflush(unsigned long start, unsigned long size,
 				    pgprot_t prot, struct page **pages);
 extern void unmap_kernel_range_noflush(unsigned long addr, unsigned long size);
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 063213685563..e13946da8ec3 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -58,165 +58,24 @@ static inline int ioremap_pud_enabled(void) { return 0; }
 static inline int ioremap_pmd_enabled(void) { return 0; }
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
 
-static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
-{
-	pte_t *pte;
-	u64 pfn;
-
-	pfn = phys_addr >> PAGE_SHIFT;
-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
-
-static int ioremap_try_huge_pmd(pmd_t *pmd, unsigned long addr,
-				unsigned long end, phys_addr_t phys_addr,
-				pgprot_t prot)
-{
-	if (!ioremap_pmd_enabled())
-		return 0;
-
-	if ((end - addr) != PMD_SIZE)
-		return 0;
-
-	if (!IS_ALIGNED(phys_addr, PMD_SIZE))
-		return 0;
-
-	if (pmd_present(*pmd) && !pmd_free_pte_page(pmd, addr))
-		return 0;
-
-	return pmd_set_huge(pmd, phys_addr, prot);
-}
-
-static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_alloc(&init_mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-
-		if (ioremap_try_huge_pmd(pmd, addr, next, phys_addr, prot))
-			continue;
-
-		if (ioremap_pte_range(pmd, addr, next, phys_addr, prot))
-			return -ENOMEM;
-	} while (pmd++, phys_addr += (next - addr), addr = next, addr != end);
-	return 0;
-}
-
-static int ioremap_try_huge_pud(pud_t *pud, unsigned long addr,
-				unsigned long end, phys_addr_t phys_addr,
-				pgprot_t prot)
-{
-	if (!ioremap_pud_enabled())
-		return 0;
-
-	if ((end - addr) != PUD_SIZE)
-		return 0;
-
-	if (!IS_ALIGNED(phys_addr, PUD_SIZE))
-		return 0;
-
-	if (pud_present(*pud) && !pud_free_pmd_page(pud, addr))
-		return 0;
-
-	return pud_set_huge(pud, phys_addr, prot);
-}
-
-static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
-		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_alloc(&init_mm, p4d, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-
-		if (ioremap_try_huge_pud(pud, addr, next, phys_addr, prot))
-			continue;
-
-		if (ioremap_pmd_range(pud, addr, next, phys_addr, prot))
-			return -ENOMEM;
-	} while (pud++, phys_addr += (next - addr), addr = next, addr != end);
-	return 0;
-}
-
-static int ioremap_try_huge_p4d(p4d_t *p4d, unsigned long addr,
-				unsigned long end, phys_addr_t phys_addr,
-				pgprot_t prot)
-{
-	if (!ioremap_p4d_enabled())
-		return 0;
-
-	if ((end - addr) != P4D_SIZE)
-		return 0;
-
-	if (!IS_ALIGNED(phys_addr, P4D_SIZE))
-		return 0;
-
-	if (p4d_present(*p4d) && !p4d_free_pud_page(p4d, addr))
-		return 0;
-
-	return p4d_set_huge(p4d, phys_addr, prot);
-}
-
-static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
-{
-	p4d_t *p4d;
-	unsigned long next;
-
-	p4d = p4d_alloc(&init_mm, pgd, addr);
-	if (!p4d)
-		return -ENOMEM;
-	do {
-		next = p4d_addr_end(addr, end);
-
-		if (ioremap_try_huge_p4d(p4d, addr, next, phys_addr, prot))
-			continue;
-
-		if (ioremap_pud_range(p4d, addr, next, phys_addr, prot))
-			return -ENOMEM;
-	} while (p4d++, phys_addr += (next - addr), addr = next, addr != end);
-	return 0;
-}
-
 int ioremap_page_range(unsigned long addr,
 		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {
-	pgd_t *pgd;
-	unsigned long start;
-	unsigned long next;
-	int err;
-
-	might_sleep();
-	BUG_ON(addr >= end);
-
-	start = addr;
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = ioremap_p4d_range(pgd, addr, next, phys_addr, prot);
-		if (err)
-			break;
-	} while (pgd++, phys_addr += (next - addr), addr = next, addr != end);
-
-	flush_cache_vmap(start, end);
+	unsigned int max_page_shift = PAGE_SHIFT;
+
+	/*
+	 * Due to the max_page_shift parameter to vmap_range, platforms must
+	 * enable all smaller sizes to take advantage of a given size,
+	 * otherwise fall back to small pages.
+	 */
+	if (ioremap_pmd_enabled()) {
+		max_page_shift = PMD_SHIFT;
+		if (ioremap_pud_enabled()) {
+			max_page_shift = PUD_SHIFT;
+			if (ioremap_p4d_enabled())
+				max_page_shift = P4D_SHIFT;
+		}
+	}
 
-	return err;
+	return vmap_range(addr, end, phys_addr, prot, max_page_shift);
 }
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 233af6936c93..dd27cfb29b10 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -119,7 +119,7 @@ static void vunmap_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end)
 	} while (p4d++, addr = next, addr != end);
 }
 
-static void vunmap_page_range(unsigned long addr, unsigned long end)
+static void vunmap_range(unsigned long addr, unsigned long end)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -135,6 +135,198 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 }
 
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
+{
+	pte_t *pte;
+	u64 pfn;
+
+	pfn = phys_addr >> PAGE_SHIFT;
+	pte = pte_alloc_kernel(pmd, addr);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		BUG_ON(!pte_none(*pte));
+		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
+		pfn++;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	return 0;
+}
+
+static int vmap_try_huge_pmd(pmd_t *pmd, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	if (!IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP))
+		return 0;
+
+	if (max_page_shift < PMD_SHIFT)
+		return 0;
+
+	if ((end - addr) != PMD_SIZE)
+		return 0;
+
+	if (!IS_ALIGNED(phys_addr, PMD_SIZE))
+		return 0;
+
+	if (pmd_present(*pmd) && !pmd_free_pte_page(pmd, addr))
+		return 0;
+
+	return pmd_set_huge(pmd, phys_addr, prot);
+}
+
+static inline int vmap_pmd_range(pud_t *pud, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(&init_mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+
+		if (vmap_try_huge_pmd(pmd, addr, next, phys_addr, prot,
+					max_page_shift))
+			continue;
+
+		if (vmap_pte_range(pmd, addr, next, phys_addr, prot))
+			return -ENOMEM;
+	} while (pmd++, phys_addr += (next - addr), addr = next, addr != end);
+	return 0;
+}
+
+static int vmap_try_huge_pud(pud_t *pud, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	if (!IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP))
+		return 0;
+
+	if (max_page_shift < PUD_SHIFT)
+		return 0;
+
+	if ((end - addr) != PUD_SIZE)
+		return 0;
+
+	if (!IS_ALIGNED(phys_addr, PUD_SIZE))
+		return 0;
+
+	if (pud_present(*pud) && !pud_free_pmd_page(pud, addr))
+		return 0;
+
+	return pud_set_huge(pud, phys_addr, prot);
+}
+
+static inline int vmap_pud_range(p4d_t *p4d, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(&init_mm, p4d, addr);
+	if (!pud)
+		return -ENOMEM;
+	do {
+		next = pud_addr_end(addr, end);
+
+		if (vmap_try_huge_pud(pud, addr, next, phys_addr, prot,
+					max_page_shift))
+			continue;
+
+		if (vmap_pmd_range(pud, addr, next, phys_addr, prot,
+					max_page_shift))
+			return -ENOMEM;
+	} while (pud++, phys_addr += (next - addr), addr = next, addr != end);
+	return 0;
+}
+
+static int vmap_try_huge_p4d(p4d_t *p4d, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	if (!IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP))
+		return 0;
+
+	if (max_page_shift < P4D_SHIFT)
+		return 0;
+
+	if ((end - addr) != P4D_SIZE)
+		return 0;
+
+	if (!IS_ALIGNED(phys_addr, P4D_SIZE))
+		return 0;
+
+	if (p4d_present(*p4d) && !p4d_free_pud_page(p4d, addr))
+		return 0;
+
+	return p4d_set_huge(p4d, phys_addr, prot);
+}
+
+static inline int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	p4d = p4d_alloc(&init_mm, pgd, addr);
+	if (!p4d)
+		return -ENOMEM;
+	do {
+		next = p4d_addr_end(addr, end);
+
+		if (vmap_try_huge_p4d(p4d, addr, next, phys_addr, prot,
+					max_page_shift))
+			continue;
+
+		if (vmap_pud_range(p4d, addr, next, phys_addr, prot,
+					max_page_shift))
+			return -ENOMEM;
+	} while (p4d++, phys_addr += (next - addr), addr = next, addr != end);
+	return 0;
+}
+
+static int vmap_range_noflush(unsigned long addr,
+			unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+			unsigned int max_page_shift)
+{
+	pgd_t *pgd;
+	unsigned long start;
+	unsigned long next;
+	int err;
+
+	might_sleep();
+	BUG_ON(addr >= end);
+
+	start = addr;
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		err = vmap_p4d_range(pgd, addr, next, phys_addr, prot,
+					max_page_shift);
+		if (err)
+			break;
+	} while (pgd++, phys_addr += (next - addr), addr = next, addr != end);
+
+	return err;
+}
+
+int vmap_range(unsigned long addr,
+		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
+		       unsigned int max_page_shift)
+{
+	int ret;
+
+	ret = vmap_range_noflush(addr, end, phys_addr, prot, max_page_shift);
+	flush_cache_vmap(addr, end);
+
+	return ret;
+}
+
+static int vmap_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pte_t *pte;
@@ -160,7 +352,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
-static int vmap_pmd_range(pud_t *pud, unsigned long addr,
+static int vmap_pages_pmd_range(pud_t *pud, unsigned long addr,
 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pmd_t *pmd;
@@ -171,13 +363,13 @@ static int vmap_pmd_range(pud_t *pud, unsigned long addr,
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
+		if (vmap_pages_pte_range(pmd, addr, next, prot, pages, nr))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static int vmap_pud_range(p4d_t *p4d, unsigned long addr,
+static int vmap_pages_pud_range(p4d_t *p4d, unsigned long addr,
 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pud_t *pud;
@@ -188,13 +380,13 @@ static int vmap_pud_range(p4d_t *p4d, unsigned long addr,
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
+		if (vmap_pages_pmd_range(pud, addr, next, prot, pages, nr))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
+static int vmap_pages_p4d_range(pgd_t *pgd, unsigned long addr,
 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	p4d_t *p4d;
@@ -205,7 +397,7 @@ static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
 		return -ENOMEM;
 	do {
 		next = p4d_addr_end(addr, end);
-		if (vmap_pud_range(p4d, addr, next, prot, pages, nr))
+		if (vmap_pages_pud_range(p4d, addr, next, prot, pages, nr))
 			return -ENOMEM;
 	} while (p4d++, addr = next, addr != end);
 	return 0;
@@ -217,7 +409,7 @@ static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
  *
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
-static int vmap_page_range_noflush(unsigned long start, unsigned long end,
+static int vmap_pages_range_noflush(unsigned long start, unsigned long end,
 				   pgprot_t prot, struct page **pages)
 {
 	pgd_t *pgd;
@@ -230,7 +422,7 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_p4d_range(pgd, addr, next, prot, pages, &nr);
+		err = vmap_pages_p4d_range(pgd, addr, next, prot, pages, &nr);
 		if (err)
 			return err;
 	} while (pgd++, addr = next, addr != end);
@@ -238,12 +430,12 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	return nr;
 }
 
-static int vmap_page_range(unsigned long start, unsigned long end,
+static int vmap_pages_range(unsigned long start, unsigned long end,
 			   pgprot_t prot, struct page **pages)
 {
 	int ret;
 
-	ret = vmap_page_range_noflush(start, end, prot, pages);
+	ret = vmap_pages_range_noflush(start, end, prot, pages);
 	flush_cache_vmap(start, end);
 	return ret;
 }
@@ -1148,7 +1340,7 @@ static void free_vmap_area(struct vmap_area *va)
  */
 static void unmap_vmap_area(struct vmap_area *va)
 {
-	vunmap_page_range(va->va_start, va->va_end);
+	vunmap_range(va->va_start, va->va_end);
 }
 
 /*
@@ -1586,7 +1778,7 @@ static void vb_free(const void *addr, unsigned long size)
 	rcu_read_unlock();
 	BUG_ON(!vb);
 
-	vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
+	vunmap_range((unsigned long)addr, (unsigned long)addr + size);
 
 	if (debug_pagealloc_enabled())
 		flush_tlb_kernel_range((unsigned long)addr,
@@ -1736,7 +1928,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 		addr = va->va_start;
 		mem = (void *)addr;
 	}
-	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
+	if (vmap_pages_range(addr, addr + size, prot, pages) < 0) {
 		vm_unmap_ram(mem, count);
 		return NULL;
 	}
@@ -1903,7 +2095,7 @@ void __init vmalloc_init(void)
 int map_kernel_range_noflush(unsigned long addr, unsigned long size,
 			     pgprot_t prot, struct page **pages)
 {
-	return vmap_page_range_noflush(addr, addr + size, prot, pages);
+	return vmap_pages_range_noflush(addr, addr + size, prot, pages);
 }
 
 /**
@@ -1922,7 +2114,7 @@ int map_kernel_range_noflush(unsigned long addr, unsigned long size,
  */
 void unmap_kernel_range_noflush(unsigned long addr, unsigned long size)
 {
-	vunmap_page_range(addr, addr + size);
+	vunmap_range(addr, addr + size);
 }
 EXPORT_SYMBOL_GPL(unmap_kernel_range_noflush);
 
@@ -1939,7 +2131,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 	unsigned long end = addr + size;
 
 	flush_cache_vunmap(addr, end);
-	vunmap_page_range(addr, end);
+	vunmap_range(addr, end);
 	flush_tlb_kernel_range(addr, end);
 }
 EXPORT_SYMBOL_GPL(unmap_kernel_range);
@@ -1950,7 +2142,7 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page **pages)
 	unsigned long end = addr + get_vm_area_size(area);
 	int err;
 
-	err = vmap_page_range(addr, end, prot, pages);
+	err = vmap_pages_range(addr, end, prot, pages);
 
 	return err > 0 ? 0 : err;
 }
-- 
2.20.1

