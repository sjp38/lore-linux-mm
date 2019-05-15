Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A695C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EC3020843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Hcwi14Q2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EC3020843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7606B000A; Wed, 15 May 2019 09:21:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA9ED6B000C; Wed, 15 May 2019 09:21:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C48E46B000D; Wed, 15 May 2019 09:21:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8D46B000A
	for <linux-mm@kvack.org>; Wed, 15 May 2019 09:21:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 5so1662005pff.11
        for <linux-mm@kvack.org>; Wed, 15 May 2019 06:21:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bwCbazG0uWpeHHq16h61suXp9iNQSDKrijvI5Xb8k5A=;
        b=k8bHuv9MEoEb33mdq2k6js5KPWYQuQDDVEKMQes8ZjwXamK4K1lcZ4BLF2CFpS9KRg
         O9omgnTNLTX74R8T7CMWlzmGuKKsQqCgYWcEP6WWsotMhm3FPGG1Zq1PxUcB7K0BleDm
         wtdFnY+9m7rJNDlo6KiyqUs6FWUN7BfJmwuec+npdbI4wELdFKEhrPU2pfwDvTaGHzRA
         NA6At3e7wH52lIxoT4lOBwFCI9bQ5iSJYV163KhGF+OdMQBON5jq+CDdKXVeujkQIGlS
         85sGYsdWT8q/01hggHwR9Po/LP1orZjG08QjrHpBtnp+2V4VVDsryDPmKLZnmuYFWUy0
         FbWA==
X-Gm-Message-State: APjAAAVCM29WMvbM2dGfHYvAiHnNWkFWmxV1D27gZN4/kZuWxh9qPDZp
	VWis1SzVyWvQOLAY5B9Ry1KNDv4o1h15qdj13J8cVtJE0o9Aki3BIb6ro4FSNewR0OxrpYd4Vp0
	vo3mw3D3Pg7DGfzg7qZo2Tcx0S6WbSb9Ot1vw9a9vKC/LD2uv+u20dsetzba3oz9HZg==
X-Received: by 2002:a65:62d2:: with SMTP id m18mr43988682pgv.122.1557926487233;
        Wed, 15 May 2019 06:21:27 -0700 (PDT)
X-Received: by 2002:a65:62d2:: with SMTP id m18mr43988568pgv.122.1557926485817;
        Wed, 15 May 2019 06:21:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557926485; cv=none;
        d=google.com; s=arc-20160816;
        b=wyVXkeawRJBegrNwAH6ry38yRavgbfD0joWRojlmJUSAlcONXojhlFRue97zvGnUzM
         Gtsp9bi2b51HtNv20chK3aY4vo0NEgB0vIhM91vF8OCqiciIkPYjZtTe4x5UYmh/JPPp
         ogjFE0Z0apPlNeXAEQfFmYQQAMEfONvCv+2T+JjNkJ3dkMlQQBBTfth+bmrggJRkOp3l
         pHspDW7mQBLV4D5aQI8/UcV2zFHUePx1IYeZJOwi5qImuS/RysWsTZ7fEqzHB7LX4OiG
         3fdyVPCXjV6LVMFBFlobOBAeQbPm2FkmhEhB5ou4X0GBa9I8B9mmWGZeTD5zOITJQ8D4
         /afg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bwCbazG0uWpeHHq16h61suXp9iNQSDKrijvI5Xb8k5A=;
        b=SQTWdTMNQec2rU2oPll/fmxG7CP1D4iXMVQLQLwzv6Yu/YpHmOk1/HXEAcw9oYW4AL
         VpHAuVXvwcGqdyKwA/KL1NtzS3spI6+YKW2sdihwGTygtEEqkfJX1PM1wi1GPohxpz6Q
         VexbcKMAOTlUJ18MN/NEqcA3Hyf+HEDQ4US+fK7iDWMIpPjvWJ1yDBgbEqN0GlT8tXCa
         uJhgh0OlT7DJ+ldD9eOyyGBCQslKIJoPpmGqUK7rLm5+yRpPHBi4HrSPOPXj8ZK7pOzx
         nmkGgSv/yDG3TqE0ojMr62dkcJiYqw35LJeFxZ/eFLvKmfkEUN8SZ+cAbLlPIW/7z6pv
         p0Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Hcwi14Q2;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15sor2355175pfd.32.2019.05.15.06.21.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 06:21:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Hcwi14Q2;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bwCbazG0uWpeHHq16h61suXp9iNQSDKrijvI5Xb8k5A=;
        b=Hcwi14Q2tGdVL2zCKha7YAmgbnjBfn0I+F4J0mIrtvPa2xNDi1kWRnxlZmsp29p/u/
         a2vEykX7CJ7AQwG714ATKj2Q7EDExwSFQTK2sVDyrP9mS+gcYt47vK2E08+WUNzMlRCm
         mPZ25kRrfrTrk4WEq6BmcgWePQHHz4h1vgLp2fQoj70GI6IBMWc3GG8ASc3dYSjt5c78
         ivA348YjsJGXM6E254fAy2igbikZxE08ct7OMzNDbYQidTUnJw4fu+/5QwqbAjkMOgCQ
         IEVq3KCOmUEIhcd8WMbAXvCr5OqVLfZRDuWRGp/GukYllQTM4rCy+OP8LJaiNvKDHzX1
         9wdQ==
X-Google-Smtp-Source: APXvYqzrGvRl04leG3wMiKC5XwoMrKTT0j4sN+ztWjxzzL/exH73j2Kp+fjMcn3xSXwRLWO2cGw2BQ==
X-Received: by 2002:a62:7d8e:: with SMTP id y136mr25109171pfc.224.1557926485554;
        Wed, 15 May 2019 06:21:25 -0700 (PDT)
Received: from bobo.local0.net (115-64-240-98.tpgi.com.au. [115.64.240.98])
        by smtp.gmail.com with ESMTPSA id a19sm2784459pgm.46.2019.05.15.06.21.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 06:21:25 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [RFC PATCH 4/5] powerpc/64s/radix: Enable HAVE_ARCH_HUGE_VMAP
Date: Wed, 15 May 2019 23:19:43 +1000
Message-Id: <20190515131944.12489-4-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190515131944.12489-1-npiggin@gmail.com>
References: <20190515131944.12489-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This does not actually enable huge vmap mappings, because powerpc/64
ioremap does not call ioremap_page_range, but it is required before
implementing huge mappings in ioremap, because the generic vunmap code
needs to cope with them.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/Kconfig                     |  1 +
 arch/powerpc/mm/book3s64/radix_pgtable.c | 93 ++++++++++++++++++++++++
 2 files changed, 94 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index d7996cfaceca..ffac84600e0e 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -166,6 +166,7 @@ config PPC
 	select GENERIC_STRNLEN_USER
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ARCH_AUDITSYSCALL
+	select HAVE_ARCH_HUGE_VMAP		if PPC_BOOK3S_64 && PPC_RADIX_MMU
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN			if PPC32
 	select HAVE_ARCH_KGDB
diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/book3s64/radix_pgtable.c
index c9bcf428dd2b..3bc9ade56277 100644
--- a/arch/powerpc/mm/book3s64/radix_pgtable.c
+++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
@@ -1122,3 +1122,96 @@ void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
 
 	set_pte_at(mm, addr, ptep, pte);
 }
+
+int __init arch_ioremap_pud_supported(void)
+{
+	return radix_enabled();
+}
+
+int __init arch_ioremap_pmd_supported(void)
+{
+	return radix_enabled();
+}
+
+int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
+{
+	return 0;
+}
+
+int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
+{
+	pte_t *ptep = (pte_t *)pud;
+	pte_t new_pud = pfn_pte(__phys_to_pfn(addr), prot);
+
+	set_pte_at(&init_mm, 0 /* radix unused */, ptep, new_pud);
+
+	return 1;
+}
+
+int pud_clear_huge(pud_t *pud)
+{
+	if (pud_huge(*pud)) {
+		pud_clear(pud);
+		return 1;
+	}
+
+	return 0;
+}
+
+int pud_free_pmd_page(pud_t *pud, unsigned long addr)
+{
+	pmd_t *pmd;
+	int i;
+
+	pmd = (pmd_t *)pud_page_vaddr(*pud);
+	pud_clear(pud);
+
+	flush_tlb_kernel_range(addr, addr + PUD_SIZE);
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		if (!pmd_none(pmd[i])) {
+			pte_t *pte;
+			pte = (pte_t *)pmd_page_vaddr(pmd[i]);
+
+			pte_free_kernel(&init_mm, pte);
+		}
+	}
+
+	pmd_free(&init_mm, pmd);
+
+	return 1;
+}
+
+int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
+{
+	pte_t *ptep = (pte_t *)pmd;
+	pte_t new_pmd = pfn_pte(__phys_to_pfn(addr), prot);
+
+	set_pte_at(&init_mm, 0 /* radix unused */, ptep, new_pmd);
+
+	return 1;
+}
+
+int pmd_clear_huge(pmd_t *pmd)
+{
+	if (pmd_huge(*pmd)) {
+		pmd_clear(pmd);
+		return 1;
+	}
+
+	return 0;
+}
+
+int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
+{
+	pte_t *pte;
+
+	pte = (pte_t *)pmd_page_vaddr(*pmd);
+	pmd_clear(pmd);
+
+	flush_tlb_kernel_range(addr, addr + PMD_SIZE);
+
+	pte_free_kernel(&init_mm, pte);
+
+	return 1;
+}
-- 
2.20.1

