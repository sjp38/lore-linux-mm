Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22754C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:30:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D18A7217F4
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:30:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D18A7217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 846146B0266; Tue,  9 Apr 2019 06:30:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81BF66B0269; Tue,  9 Apr 2019 06:30:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E5B66B026A; Tue,  9 Apr 2019 06:30:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 459F46B0266
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:30:30 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id w139so7200105oiw.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:30:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e3rr6aKDQW1gxAlq+d83ilx9o3h4aAQlcXfr3180xvg=;
        b=Wlt15mkEBZwBKWGvDM09ZqxBZGpMCiuItSBfo6pCeiLNCYyy1LhajqypJtwmECvoWA
         XsUIZhrgdCpdgy6LN54oJO0t7jxvD47uAvA6FIoc77hn/AHJkP9M4pLPb0mSGnIfG9aD
         kXY/2Ahux9CoDYpl+C+K/LRG0MOnnomCB+M9huLr2aQTWzL+cWbgAX4J31QyHDaGpm5Y
         FPtG4d19WQQy9FtaUpDnraWmufJnzb2C4uMu1Ww2wI1DKtIAyH8D80XZdyYRv44XlbyX
         BxO3Ze8YjN21gTTv01eNk3llPBtPJb5Ws62YGadNSWr61AWXQOys0G7zaSIN2yhESYXR
         EcCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUxxw+KAkOOO3khgkzdkbwog6WVfoaeMMMgQWsKokSmk3O5z9oa
	ALDh6MtNDRQTdr9ikp0bzt0GbfDkIBv2io0yBN3zSPnjfzpvUc2dtLprJ2uCJOzPghTvBtC4IMy
	KjuYbcuXOU/DlW46v0WchN5gwqlj03JFD0uMJy9DEAg2mHJGJiYUgjW/29pk9F0Lcrw==
X-Received: by 2002:a05:6830:1446:: with SMTP id w6mr22914364otp.157.1554805830004;
        Tue, 09 Apr 2019 03:30:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztffXisW5oKyNn7qBzeuop3widkad/IXKMcc+i1Kuk3BulcuVvQvMRHr3CFTnGSri0W1gJ
X-Received: by 2002:a05:6830:1446:: with SMTP id w6mr22914319otp.157.1554805829106;
        Tue, 09 Apr 2019 03:30:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554805829; cv=none;
        d=google.com; s=arc-20160816;
        b=b8tRRMZAoAL/C+bu1nH38Us4pZc68357aEHTRck2lW4E01DtonvY12BXoaiHZ2Psdy
         1PtsqV26As5EqbgOU5XEg3edCFA/itLt+/iITvI6yrYZlK1qDhYfM+UT53MemqWKyFAz
         6wgMaynBVApX+pyMmax0PoefDHdra3Lzri53obameh8B3Uz+Km8SvjyI5RBOH+27mpmI
         onCLFHzK8T/sbG9ZK6J4RHXtF3JpSo0jwkYTdJgq9q6o+cknCfkEKIeifF3YuPOttMdH
         J9CBHrFGEUddnAb9el99QTdKv23V9i1w5UYPsoWrxSjNswqEPWplbj5RleWaF0z37QJv
         2pmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=e3rr6aKDQW1gxAlq+d83ilx9o3h4aAQlcXfr3180xvg=;
        b=cYrZtdrOG2PR0QmmIYsWv1c2IbdMgquQ66EOcR7O8iVnt4+d+I6Y8wzR2a/Ir5VT1M
         IwcuLA3wUSne307iNY5Owk0fq8ZXYIW1kZCCvj/VruDZBUnZn7a86J4MckAEPpvlFzyG
         3mDA5veGLbcpvOQBK9AVS2zjXaUQrx45ai/42gGM4U7DHP0NGVeqWDcHwqMSfg76eoJZ
         jvVKTNMLWttYo0qIJ4IwzA/DSk5y55OpNNrV751fAlsEQWkw/aAa/w632z9fDCqWRnN1
         X8pR8XngRfhV1SugYxlkvzTErnalho5XhHvUCZv6DDH3FsKnxfsFuuNIkYGpli1GV4aM
         mFPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id w80si14747526oif.103.2019.04.09.03.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:30:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 62437EB4795704B3854F;
	Tue,  9 Apr 2019 18:17:36 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 18:17:26 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel regions
Date: Tue, 9 Apr 2019 18:28:18 +0800
Message-ID: <20190409102819.121335-4-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409102819.121335-1-chenzhou10@huawei.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
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

