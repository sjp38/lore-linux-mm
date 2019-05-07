Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BA42C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59D9220835
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59D9220835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0482F6B0008; Mon,  6 May 2019 23:42:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3C286B000C; Mon,  6 May 2019 23:42:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E29E56B000D; Mon,  6 May 2019 23:42:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B96F26B0008
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:42:22 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id v16so2141030otp.17
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:42:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1xnre9XHRnQ624eCACSz9ZX+IutElUUCR2dc/8kvf3I=;
        b=karF8aE6PqCI+1QkezAJFPZEdzkxYNq/8CA+leQZD9UpuaOUKF8R+Ot+861kmNU016
         0NvLxhT8myAqK42hGl9vt7bkFoor11YSxbDzAjq6UFyBjBNofLAxHm1rW3s4ZF5Zwadh
         EOohuzSwcFHj7W40fxBjtJ8oMUdONLYRj6QJLvZ+HfP1UVJ8L/+OMD+RO2kaA5cVQMlf
         LUyKWdVADQe/Vki8ysKUsrLhL4okT4JUMPsIaIyZFZdrVRq2PXI+7pzTRRK4ki9bUx+j
         7sd60sIxgv3t3kvMQZQ2+VwyNPKRsDtFXKx5bkQ0VH2bFc4LrJ7Lx8MgVK2p6Dv4vTsE
         Duuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAX1Wc9U8k/us+g6fl7/441lPhWWsa4yfv7h7ZZ0UlsS3lg1nSeZ
	OWFfV6dvRiV4ZbpM2/8Wl3ywFaHgVUGDnGdLph38CjvZKUYdg7Q88l+TDtwQgQjMImahbJRRKyd
	7fxN7kPQdzKU9AJ8lDfHlIMQJGaTjjX99dkaQL4jev8p+ZP582L3Veq+jkOP7lAl9ww==
X-Received: by 2002:a9d:490e:: with SMTP id e14mr19752096otf.197.1557200542363;
        Mon, 06 May 2019 20:42:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfiIz3n5/Pb4CEbS7AeU7dMdl3AhJn4dUVJQNwacBahY1vTB7xSNll5tY2AiCwR780BJkl
X-Received: by 2002:a9d:490e:: with SMTP id e14mr19752046otf.197.1557200541012;
        Mon, 06 May 2019 20:42:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557200541; cv=none;
        d=google.com; s=arc-20160816;
        b=L4sDzTJfni54hKOppe1MuVK9nlyeR1jytK1E7pFC16WaX1ZDEyVtM2Dwa8tvH9z5es
         zuz+dzyFZLYZ5sWoa5GFTtDnlnzNSDgB7+g9ZwfoeJaF/8fOjw7jBTrRE5SKA5brW67P
         fdwGOhDOLIa0q+9EKTEHNGKBqtrk4ub9Eruyac4Re4JUErOlwAeHLAewImysYqdsa3KK
         rWz27TNyXq+jN6qtPVfVwa62TQd53AdCzmx+aslU3Zi6bTIGsAb9d1F5ZCMbUL/utkX4
         IdhwkvprfD10wconvcb6AJhaciWf97UAToJUtASSymt4H7MSUrOeenw0qeq5i0P7Izs/
         84hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1xnre9XHRnQ624eCACSz9ZX+IutElUUCR2dc/8kvf3I=;
        b=wEfBruHqCfJDil0frME7FShZZHi2UHBQFhl5sLCmmh4XphUocbjgg7LeHkx3SvPnyC
         ohdvLRTnqFXqUN5aDs0hLTBJ6IS+09DpIe9eHxOgyIX6WWhJa92k+616/vkJBiEfk9MI
         pTsX8oJDTempspPvYiX7wtTD1AMQLb0xNjUfvS6aAQlM/r7P4Kl/p7UEaJ9bEPuiFXyA
         iCAqwFniVNhrjZDxfUHJ8OJdYGh7t8B8qjem23cnnMzLWRqFFASSyhNK7gmxQLoGSzRK
         gOUWdXgwnD/3578PP2uCsikhPLZcCvcAf+GFWXsvrVx4SOqu8HRv95m4aeomnMPOrJv/
         4NJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id t78si7079764oie.102.2019.05.06.20.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:42:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 6C16DACF82BE33D6EFEE;
	Tue,  7 May 2019 11:42:15 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS403-HUB.china.huawei.com (10.3.19.203) with Microsoft SMTP Server id
 14.3.439.0; Tue, 7 May 2019 11:42:05 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 3/4] memblock: extend memblock_cap_memory_range to multiple ranges
Date: Tue, 7 May 2019 11:50:57 +0800
Message-ID: <20190507035058.63992-4-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507035058.63992-1-chenzhou10@huawei.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
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

From: Mike Rapoport <rppt@linux.ibm.com>

The memblock_cap_memory_range() removes all the memory except the
range passed to it. Extend this function to receive an array of
memblock_regions that should be kept. This allows switching to
simple iteration over memblock arrays with 'for_each_mem_range_rev'
to remove the unneeded memory.

Enable use of this function in arm64 for reservation of multiple
regions for the crash kernel.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/mm/init.c     | 38 ++++++++++++++++++++++++++++----------
 include/linux/memblock.h |  2 +-
 mm/memblock.c            | 44 ++++++++++++++++++++------------------------
 3 files changed, 49 insertions(+), 35 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 3fcd739..2d8f302 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -63,6 +63,13 @@ EXPORT_SYMBOL(memstart_addr);
 
 phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
+/* The main usage of linux,usable-memory-range is for crash dump kernel.
+ * Originally, the number of usable-memory regions is one. Now crash dump
+ * kernel support at most two crash kernel regions, low_region and high
+ * region.
+ */
+#define MAX_USABLE_RANGES	2
+
 #ifdef CONFIG_KEXEC_CORE
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
@@ -302,9 +309,9 @@ early_param("mem", early_mem);
 static int __init early_init_dt_scan_usablemem(unsigned long node,
 		const char *uname, int depth, void *data)
 {
-	struct memblock_region *usablemem = data;
-	const __be32 *reg;
-	int len;
+	struct memblock_type *usablemem = data;
+	const __be32 *reg, *endp;
+	int len, nr = 0;
 
 	if (depth != 1 || strcmp(uname, "chosen") != 0)
 		return 0;
@@ -313,22 +320,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
 		return 1;
 
-	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+	endp = reg + (len / sizeof(__be32));
+	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+		unsigned long base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+		unsigned long size = dt_mem_next_cell(dt_root_size_cells, &reg);
+
+		if (memblock_add_range(usablemem, base, size, NUMA_NO_NODE,
+				       MEMBLOCK_NONE))
+			return 0;
+		if (++nr >= MAX_USABLE_RANGES)
+			break;
+	}
 
 	return 1;
 }
 
 static void __init fdt_enforce_memory_region(void)
 {
-	struct memblock_region reg = {
-		.size = 0,
+	struct memblock_region usable_regions[MAX_USABLE_RANGES];
+	struct memblock_type usablemem = {
+		.max = MAX_USABLE_RANGES,
+		.regions = usable_regions,
 	};
 
-	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
+	of_scan_flat_dt(early_init_dt_scan_usablemem, &usablemem);
 
-	if (reg.size)
-		memblock_cap_memory_range(reg.base, reg.size);
+	if (usablemem.cnt)
+		memblock_cap_memory_ranges(usablemem.regions, usablemem.cnt);
 }
 
 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 676d390..526e279 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -446,7 +446,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
-void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
+void memblock_cap_memory_ranges(struct memblock_region *regions, int count);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
 bool memblock_is_map_memory(phys_addr_t addr);
diff --git a/mm/memblock.c b/mm/memblock.c
index 6bbad46..ecdf8a9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1669,36 +1669,31 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 			      PHYS_ADDR_MAX);
 }
 
-void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
-{
-	int start_rgn, end_rgn;
-	int i, ret;
-
-	if (!size)
-		return;
-
-	ret = memblock_isolate_range(&memblock.memory, base, size,
-						&start_rgn, &end_rgn);
-	if (ret)
-		return;
-
-	/* remove all the MAP regions */
-	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
+void __init memblock_cap_memory_ranges(struct memblock_region *regions,
+				       int count)
+{
+	struct memblock_type regions_to_keep = {
+		.max = count,
+		.cnt = count,
+		.regions = regions,
+	};
+	phys_addr_t start, end;
+	u64 i;
 
-	for (i = start_rgn - 1; i >= 0; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
+	/* truncate memory while skipping NOMAP regions */
+	for_each_mem_range_rev(i, &memblock.memory, &regions_to_keep,
+			       NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL)
+		memblock_remove(start, end - start);
 
 	/* truncate the reserved regions */
-	memblock_remove_range(&memblock.reserved, 0, base);
-	memblock_remove_range(&memblock.reserved,
-			base + size, PHYS_ADDR_MAX);
+	for_each_mem_range_rev(i, &memblock.reserved, &regions_to_keep,
+			       NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL)
+		memblock_remove_range(&memblock.reserved, start, end - start);
 }
 
 void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 {
+	struct memblock_region region = { 0 };
 	phys_addr_t max_addr;
 
 	if (!limit)
@@ -1710,7 +1705,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 	if (max_addr == PHYS_ADDR_MAX)
 		return;
 
-	memblock_cap_memory_range(0, max_addr);
+	region.size = max_addr;
+	memblock_cap_memory_ranges(&region, 1);
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
-- 
2.7.4

