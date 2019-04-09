Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F6CBC282E0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:21:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C9F62133D
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C9F62133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15FC66B000C; Tue,  9 Apr 2019 03:21:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01F156B000D; Tue,  9 Apr 2019 03:21:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE2F86B0010; Tue,  9 Apr 2019 03:21:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id A262B6B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 03:21:07 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id i203so7016677oih.16
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:21:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e3rr6aKDQW1gxAlq+d83ilx9o3h4aAQlcXfr3180xvg=;
        b=n5QimYwwr40telgJYob/3/R8VwWRosD/DkIK05eWyKMoGDUi9LTnjl1GN+gAAHvhUC
         AhfF8muUl+VnVifGcPT0zbWyIubqLVFvc7OIEFTIA9yCy5l3518fcEE2nf8URPn9Qsam
         IDZIimH2N8WLC5dJF0pXE2Ky4fzc1ZN3cwFMNeqXTD393CGSwYgDAfRJrb+k+YayqdJb
         HoLeAl7iu2rxO1Dh+nyGYejwaLYzkrBUlm/3itbn5klqdLXGK8Gn5LLKKqIS7w4gYsvf
         YcDz0j4k/7omNOLJQibFp1k2FxDZhzIA7TL0OJudxtrhgJzh1aS+P8QEjgEDh4zZ33WC
         9oPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXyeM5VSj3L5b6h+wbd0fJ2vDrWWVz70xr+6M/61PLPxX2f3SIi
	iYbadaF0wMpkkBeQjBX5B1aZr0IIESqi6D3LgMFVwbvGbDV/9Sdya9JxvuVQdU6ftOsmLWDadYx
	6NGm56OsB698iqIAetRs+Zwr06nANClGJ82CjAKb9xJx3d1ET6NO6zzVFcb2rF4lBYQ==
X-Received: by 2002:aca:6c41:: with SMTP id h62mr19142164oic.34.1554794467351;
        Tue, 09 Apr 2019 00:21:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6itZ0t6uRejGyX1diY9IWJwovrjkh278CIv6unFniJvOAy1rE0/n12wkfzM+py9fUpCdM
X-Received: by 2002:aca:6c41:: with SMTP id h62mr19142113oic.34.1554794465802;
        Tue, 09 Apr 2019 00:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554794465; cv=none;
        d=google.com; s=arc-20160816;
        b=Gewcb3Q042Wv/Dex9wTsv7x0KBGjbKL4VF2ZU2RSgbRv1Mx4DQAGAtCw7vX4+ygv2N
         MPwCDOIz1Ngl46TJmK2d8I16YPbm+L8RLb5zyyLrEHp7XsEdgnn9taSEBtViYzR8rEok
         GsAulePfSv4WSoqRzXxGACdDltpRvKYwc9tsM8VsvZMevULxyMo/y9eVPa8KiVlDM7l9
         yIobXJIk7azfCb01iNr0p0ZNWE9AEaNCbPg3fmG9Z7klPHSwe7sKVe/4gjzfQ32jKoQk
         Oq7DmtJYoWTWYDGTr9V8DaZ4Zoh/dnd7Bn0fMOUqF+63r7Blp71Spi8ECcrfAu3CZtTm
         uP7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=e3rr6aKDQW1gxAlq+d83ilx9o3h4aAQlcXfr3180xvg=;
        b=tDoZFhGgaup74PdweJi1S3ipunsqcVHb9WNt2al7iJhfvikvq2eCtqZlShzPtDl8y+
         rTHY8cQhnxksvl5eOqYkbalj/HX76GLkmrkezcUQt3fdXesLlIQb8HM2nJmGnE7eckQA
         uVzigrOpc3GYeypJJmJLz8rxvuDG/dqrHLmSCMRqlSYDM+CBk1ONng397qR/oRxddAmB
         x6IElZEzCU2jQ+2r5z90DdX7UXCG+evt2k7Sm4iT/TFJfAqUBs6PywQEMWSIyPLBoSMR
         poQF67adgXyzx+bqJUJPaYbB8HAXrKfD2rgHWvlq/w16Xlj+iUL2m3iiSStzic7gAtYg
         fJWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id h3si15032262otj.201.2019.04.09.00.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 00:21:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 93BD059EB87F8BBCF1A4;
	Tue,  9 Apr 2019 15:21:00 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 15:20:52 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <rppt@linux.ibm.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v2 2/3] arm64: kdump: support more than one crash kernel regions
Date: Tue, 9 Apr 2019 15:31:42 +0800
Message-ID: <20190409073143.75808-3-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409073143.75808-1-chenzhou10@huawei.com>
References: <20190409073143.75808-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After commit (arm64: kdump: support reserving crashkernel above 4G),
there may be two crash kernel regions, one is below 4G, the other is
above 4G.

Crash dump kernel reads more than one crash kernel regions via a dtb
property under node /chosen,
linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
 include/linux/memblock.h |  6 +++++
 mm/memblock.c            |  7 ++---
 3 files changed, 66 insertions(+), 13 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 3bebddf..0f18665 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
 
+/* at most two crash kernel regions, low_region and high_region */
+#define CRASH_MAX_USABLE_RANGES	2
+#define LOW_REGION_IDX			0
+#define HIGH_REGION_IDX			1
+
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
  *
@@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 		const char *uname, int depth, void *data)
 {
 	struct memblock_region *usablemem = data;
-	const __be32 *reg;
-	int len;
+	const __be32 *reg, *endp;
+	int len, nr = 0;
 
 	if (depth != 1 || strcmp(uname, "chosen") != 0)
 		return 0;
@@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
 		return 1;
 
-	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+	endp = reg + (len / sizeof(__be32));
+	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
+
+		if (++nr >= CRASH_MAX_USABLE_RANGES)
+			break;
+	}
 
 	return 1;
 }
 
 static void __init fdt_enforce_memory_region(void)
 {
-	struct memblock_region reg = {
-		.size = 0,
-	};
+	int i, cnt = 0;
+	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
+
+	memset(regs, 0, sizeof(regs));
+	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
+
+	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
+		if (regs[i].size)
+			cnt++;
+		else
+			break;
+
+	if (cnt - 1 == LOW_REGION_IDX)
+		memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
+				regs[LOW_REGION_IDX].size);
+	else if (cnt - 1 == HIGH_REGION_IDX) {
+		/*
+		 * Two crash kernel regions, cap the memory range
+		 * [regs[LOW_REGION_IDX].base, regs[HIGH_REGION_IDX].end]
+		 * and then remove the memory range in the middle.
+		 */
+		int start_rgn, end_rgn, i, ret;
+		phys_addr_t mid_base, mid_size;
+
+		mid_base = regs[LOW_REGION_IDX].base + regs[LOW_REGION_IDX].size;
+		mid_size = regs[HIGH_REGION_IDX].base - mid_base;
+		ret = memblock_isolate_range(&memblock.memory, mid_base,
+				mid_size, &start_rgn, &end_rgn);
 
-	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
+		if (ret)
+			return;
 
-	if (reg.size)
-		memblock_cap_memory_range(reg.base, reg.size);
+		memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
+				regs[HIGH_REGION_IDX].base -
+				regs[LOW_REGION_IDX].base +
+				regs[HIGH_REGION_IDX].size);
+		for (i = end_rgn - 1; i >= start_rgn; i--) {
+			if (!memblock_is_nomap(&memblock.memory.regions[i]))
+				memblock_remove_region(&memblock.memory, i);
+		}
+		memblock_remove_range(&memblock.reserved, mid_base,
+				mid_base + mid_size);
+	}
 }
 
 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 294d5d8..787d252 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -110,9 +110,15 @@ void memblock_discard(void);
 
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
+void memblock_remove_region(struct memblock_type *type, unsigned long r);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
+int memblock_isolate_range(struct memblock_type *type,
+					phys_addr_t base, phys_addr_t size,
+					int *start_rgn, int *end_rgn);
+int memblock_remove_range(struct memblock_type *type,
+					phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf..1846e2d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -357,7 +357,8 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
 	return ret;
 }
 
-static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
+void __init_memblock memblock_remove_region(struct memblock_type *type,
+					unsigned long r)
 {
 	type->total_size -= type->regions[r].size;
 	memmove(&type->regions[r], &type->regions[r + 1],
@@ -724,7 +725,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
  * Return:
  * 0 on success, -errno on failure.
  */
-static int __init_memblock memblock_isolate_range(struct memblock_type *type,
+int __init_memblock memblock_isolate_range(struct memblock_type *type,
 					phys_addr_t base, phys_addr_t size,
 					int *start_rgn, int *end_rgn)
 {
@@ -784,7 +785,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 	return 0;
 }
 
-static int __init_memblock memblock_remove_range(struct memblock_type *type,
+int __init_memblock memblock_remove_range(struct memblock_type *type,
 					  phys_addr_t base, phys_addr_t size)
 {
 	int start_rgn, end_rgn;
-- 
2.7.4

