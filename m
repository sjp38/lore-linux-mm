Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58B49C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D34A2238E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:53:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D34A2238E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47EA96B0005; Tue, 23 Jul 2019 01:53:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42E896B0008; Tue, 23 Jul 2019 01:53:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14A8A6B0007; Tue, 23 Jul 2019 01:53:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD8A86B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t19so25258262pgh.6
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=VOQ8jtIQ2Jb8zWxkafyyK7eaN5xYMac86cy5yQNeqzM=;
        b=bCzb4zOZQ6SLhCRRAMDcTpVapr5VyVSMydEa4b3eZz/DxUCznxHDTsVmEfr3J6VsIK
         iASXvjFzEjHv/a2AXbFSbA/Eau+Dru2eUvU+MVlY7vcJ22JQHgQlnCPT0Vyj5kxgQ47i
         Yy3wqxyem68mVB1rnEz9VKBcNftD6PIvdREyKAwAnkLnqYJgLpWR58t7kEVSE39LS8Ft
         ngg2/WL43YjUy7b2FZVDbngw0nGYWSsv60IJp5Vt02Kwpa8WquRGgQAYl/2Od16pYqiB
         IkZ17pEB35iPBWmlK5q3Iku6WWKpduEo9BI/tVpglxBx301CdEPvN3XRKB3MOTAXziqu
         YRQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
X-Gm-Message-State: APjAAAWeGflCSY8rYr9lp9i5zok5yZI4/G7fk10w5gHZmQvPiJraaZ20
	kcpIAyrvuywcILOPaDhhzBsYzht+klkozO1R7oyq+ZenpdXspLE389J6jYYa+KQSDzZxgHKSN0g
	Gj1uJ26iZRsAAqUwId1+UB1eLkpl8z3W18Swyd8SJC/cILXeZ1sMYZt1SO7paYxnuIg==
X-Received: by 2002:aa7:9a92:: with SMTP id w18mr3988206pfi.167.1563861232477;
        Mon, 22 Jul 2019 22:53:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxztqFKW6ixFYPFm4ic5ilSBlIaqoVuaiAuTf744l9EOAouBOENXS0GCq3+5MOcZLfW0kt8
X-Received: by 2002:aa7:9a92:: with SMTP id w18mr3988143pfi.167.1563861231149;
        Mon, 22 Jul 2019 22:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861231; cv=none;
        d=google.com; s=arc-20160816;
        b=tx6Nf8qHWscf94EPW4L1YPy8qE4OoSQ8dRb5WQugTHW8tcFx/b/W5gudkMAqAVCkYs
         B2iSBmYU7vcwUYNysM8sajvf1kl2x0l+CtLz1aCgmTSYIfu2Vww/UULpAkEC55rrzH77
         +DBa+WYdqHcwYj0IzLW/O5B+sKcZgfTzFwZt+8WOqwhh3Noy6OsPZZ/Pin0aUlpVe+mR
         Cy7XgTgrZcNF1VaUQOt9gfDnRyZWcc6RRlgyGS28khWVCxQ9dboaIUZR0M1Oia+vHIx9
         xcC030bNo4N5zJGlEQkp4jFStdcSXIIecGcYpnPtVqcieOV+04TxbhhbqqNb6WDE977q
         c1PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=VOQ8jtIQ2Jb8zWxkafyyK7eaN5xYMac86cy5yQNeqzM=;
        b=ExqADqjvN3HmXPTFGxuvR1mxbNsxmGzKnBcp0DdHGUjJg/jfNZf2DrwL5ZFsL8XiYc
         SaJizvzJXX6h//EDfGIPPEK0gpHJpnHrBuTs4PgZHxw5MDp1a4WtL8fXm1M+MuLGjvHI
         M2EFYBJxfsL7H6AgoEahQnjYG3CfI3KbbzUIdoy/QZCHgxlaUR0n4ZQlMTdqBJIh47w0
         01U9XuVbzog0XA5gtFufouNnAwyBdmobYR9MtGQblsJ1TJOOhHmEcN4UDv46mZoWEdc5
         yGCfYPpNdlIPGfwRMVsNaIVGJ3+eA5uWUURREfvI3fZ050A3UGTkzN6t89ka58qt6Qs7
         3Dxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id t18si10829534pgh.434.2019.07.22.22.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:53:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id E1F76BCD23BD65A58604;
	Tue, 23 Jul 2019 13:53:49 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.439.0; Tue, 23 Jul 2019 13:53:43 +0800
From: Hanjun Guo <guohanjun@huawei.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton
	<akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, "Jia
 He" <hejianet@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Will Deacon
	<will@kernel.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>
Subject: [PATCH v12 1/2] mm: page_alloc: introduce memblock_next_valid_pfn() (again) for arm64
Date: Tue, 23 Jul 2019 13:51:12 +0800
Message-ID: <1563861073-47071-2-git-send-email-guohanjun@huawei.com>
X-Mailer: git-send-email 1.7.12.4
In-Reply-To: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
References: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jia He <hejianet@gmail.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But it causes
possible panic on x86 due to specific memory mapping on x86_64 which will
skip valid pfns as well, so Daniel Vacek reverted it later.

But as suggested by Daniel Vacek, it is fine to using memblock to skip
gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.

Daniel said:
"On arm and arm64, memblock is used by default. But generic version of
pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
not always return the next valid one but skips more resulting in some
valid frames to be skipped (as if they were invalid). And that's why
kernel was eventually crashing on some !arm machines."

Introduce a new config option CONFIG_HAVE_MEMBLOCK_PFN_VALID and only
selected for arm64, using the new config option to guard the
memblock_next_valid_pfn().

This was tested on a HiSilicon Kunpeng920 based ARM64 server, the speedup
is pretty impressive for bootmem_init() at boot:

with 384G memory,
before: 13310ms
after:  1415ms

with 1T memory,
before: 20s
after:  2s

Suggested-by: Daniel Vacek <neelx@redhat.com>
Signed-off-by: Jia He <hejianet@gmail.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 arch/arm64/Kconfig     |  1 +
 include/linux/mmzone.h |  9 +++++++++
 mm/Kconfig             |  3 +++
 mm/memblock.c          | 31 +++++++++++++++++++++++++++++++
 mm/page_alloc.c        |  4 +++-
 5 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 697ea0510729..058eb26579be 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -893,6 +893,7 @@ config ARCH_FLATMEM_ENABLE
 
 config HAVE_ARCH_PFN_VALID
 	def_bool y
+	select HAVE_MEMBLOCK_PFN_VALID
 
 config HW_PERF_EVENTS
 	def_bool y
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..24cb6bdb1759 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1325,6 +1325,10 @@ static inline int pfn_present(unsigned long pfn)
 #endif
 
 #define early_pfn_valid(pfn)	pfn_valid(pfn)
+#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
+extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
+#define next_valid_pfn(pfn)	memblock_next_valid_pfn(pfn)
+#endif
 void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
@@ -1347,6 +1351,11 @@ struct mminit_pfnnid_cache {
 #define early_pfn_valid(pfn)	(1)
 #endif
 
+/* fallback to default definitions */
+#ifndef next_valid_pfn
+#define next_valid_pfn(pfn)	(pfn + 1)
+#endif
+
 void memory_present(int nid, unsigned long start, unsigned long end);
 
 /*
diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..c578374b6413 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -132,6 +132,9 @@ config HAVE_MEMBLOCK_NODE_MAP
 config HAVE_MEMBLOCK_PHYS_MAP
 	bool
 
+config HAVE_MEMBLOCK_PFN_VALID
+	bool
+
 config HAVE_GENERIC_GUP
 	bool
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 7d4f61ae666a..d57ba51bb9cd 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1251,6 +1251,37 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 	return 0;
 }
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
+#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
+unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
+{
+	struct memblock_type *type = &memblock.memory;
+	unsigned int right = type->cnt;
+	unsigned int mid, left = 0;
+	phys_addr_t addr = PFN_PHYS(++pfn);
+
+	do {
+		mid = (right + left) / 2;
+
+		if (addr < type->regions[mid].base)
+			right = mid;
+		else if (addr >= (type->regions[mid].base +
+				  type->regions[mid].size))
+			left = mid + 1;
+		else {
+			/* addr is within the region, so pfn is valid */
+			return pfn;
+		}
+	} while (left < right);
+
+	if (right == type->cnt)
+		return -1UL;
+	else
+		return PHYS_PFN(type->regions[right].base);
+}
+EXPORT_SYMBOL(memblock_next_valid_pfn);
+#endif /* CONFIG_HAVE_MEMBLOCK_PFN_VALID */
+
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 /**
  * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..70933c40380a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5811,8 +5811,10 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * function.  They do not exist on hotplugged memory.
 		 */
 		if (context == MEMMAP_EARLY) {
-			if (!early_pfn_valid(pfn))
+			if (!early_pfn_valid(pfn)) {
+				pfn = next_valid_pfn(pfn) - 1;
 				continue;
+			}
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
 			if (overlap_memmap_init(zone, &pfn))
-- 
2.19.1

