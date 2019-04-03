Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E35C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F93620830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F93620830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DE9E6B0272; Tue,  2 Apr 2019 22:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28F716B0274; Tue,  2 Apr 2019 22:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10DC36B0276; Tue,  2 Apr 2019 22:54:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB3256B0274
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 22:54:47 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id w11so9495073otq.7
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 19:54:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9vsSbmVCazVXk2p16cdSj8FEZujNbQEaLSgHoumtHQQ=;
        b=r0OD6G7yFNABeHAfPIn93DknO2Nsskia59scdejRd8t3Rxa0XZ+4iDt/fUwl+4n+8i
         8iDGjb5iR0ImURrij5p+2tcigj5Ys6HgSkSOMZMOMvFFemRlgRefwEnfhTZAj/l37Wmv
         //jNA4HE77w+SDCiCKMHSnNqaw7bJqHL/HkaRcFa4baZLsp5JYKMTwPig4SSce2jOTPp
         ePUjaO9M7v9N0NgFLwzdV8xvnbYD4olFYo8RgEZqMjrA9Y/ybQrOsYAKLcL571yhqvP1
         m2PIiNjKPlDzIzJo1NAwC4w1dMQK+MnNH9rLcQ5KOb7HTyUkEL3CRC9oGCcQ9TzR/tya
         xbcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAU3aDLH+A3+UM1OfdwOcxTrQqQfAmY9pKP5LiDTzgOEpoRLfU1Y
	zJ8w+lywSbRfjLqbc1LuZWDOAGaurIR+AOXkai+f97QYYGVgJouTK+Q/zeIfaDf70LCxG9P8NMg
	Q2QEYlT58lsf9DYElg4WNxISPF7sCiOxWaDbxOCPpXdPlzD7jzegw4/Ilk/UfO9zsfA==
X-Received: by 2002:aca:7215:: with SMTP id p21mr181564oic.81.1554260087516;
        Tue, 02 Apr 2019 19:54:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKgVQlLvxB4KTHVJnK4qvuIqMAsyUu7M60mSpzG9tTOw6J371kkx6A2V2H7Ni8hjc/hQal
X-Received: by 2002:aca:7215:: with SMTP id p21mr181510oic.81.1554260086179;
        Tue, 02 Apr 2019 19:54:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554260086; cv=none;
        d=google.com; s=arc-20160816;
        b=EE8hdVGAJwiB0qNJ+OJx5XyIG26312LEAXLlHVPG+DlKKJrznTjiwCAP/oeI61btfP
         /ocw7w40c0bAmOpNF2CGM8ZNcCEltpPvmgqWgf86KNfmKTChheLig03AElRY7ZDGDzeR
         CYzRmaxmDkU3P8Mwqis4Fshc28BBzecgZfmp0xszIRXvuOwlUmEK/lEt8rZY/s7WVZnn
         lgo7LFlpnw0zCBcTpplC0gh/KSoBhTyxYTIVBaf4bluM68SuPw6QtQ36EESV6bg5ctSQ
         om2F21dLIVeqZYNUTkzRzuyfEqhOIUhsBYX2eeR6XDn3pu/Z4gXWG7xblAENsp5Kx3B6
         gLMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9vsSbmVCazVXk2p16cdSj8FEZujNbQEaLSgHoumtHQQ=;
        b=LTN0kKCA5KbPiOuK7TYyTZUdFIXVnuIzohrKueKLAn+m4D/ghdKCexJbthnK7aWEOM
         IIeIIkmd0wYvVcOkRZR4X+qZUMYCpRdbb1eujekZiVoUSu9dPtN/LCRLLTtOdTfQdr5W
         uJmrwgbmi9f17Oss5z38308rGHMlgA9qeWCqHspikXx53fazVgod1a7btteiQ4EQ0c9D
         BAvcOdSQP4ZoOvdmrbIdU9B0z6hFDu/aDhfr2sy7DDnU0+6W57BmAu0bdGCoc9mWCQvU
         7/1DdGAVCL20l8hz4OUdrc81tCM/LAgg2Qt6eQMS8GHZMMOHwv9SA/bRnwRVxRjMcPdG
         q9KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id f62si6256086otb.305.2019.04.02.19.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 19:54:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [10.3.19.208])
	by Forcepoint Email with ESMTP id 0B3E5907F4EA0FB37403;
	Wed,  3 Apr 2019 10:54:42 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Wed, 3 Apr 2019 10:54:32 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<ard.biesheuvel@linaro.org>, <takahiro.akashi@linaro.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 1/3] arm64: kdump: support reserving crashkernel above 4G
Date: Wed, 3 Apr 2019 11:05:44 +0800
Message-ID: <20190403030546.23718-2-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403030546.23718-1-chenzhou10@huawei.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When crashkernel is reserved above 4G in memory, kernel should
reserve some amount of low memory for swiotlb and some DMA buffers.

Kernel would try to allocate at least 256M below 4G automatically
as x86_64 if crashkernel is above 4G. Meanwhile, support
crashkernel=X,[high,low] in arm64.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/kernel/setup.c |  3 ++
 arch/arm64/mm/init.c      | 71 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 71 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 413d566..82cd9a0 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -243,6 +243,9 @@ static void __init request_standard_resources(void)
 			request_resource(res, &kernel_data);
 #ifdef CONFIG_KEXEC_CORE
 		/* Userspace will find "Crash kernel" region in /proc/iomem. */
+		if (crashk_low_res.end && crashk_low_res.start >= res->start &&
+		    crashk_low_res.end <= res->end)
+			request_resource(res, &crashk_low_res);
 		if (crashk_res.end && crashk_res.start >= res->start &&
 		    crashk_res.end <= res->end)
 			request_resource(res, &crashk_res);
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 6bc1350..ceb2a25 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -64,6 +64,57 @@ EXPORT_SYMBOL(memstart_addr);
 phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
+static int __init reserve_crashkernel_low(void)
+{
+	unsigned long long base, low_base = 0, low_size = 0;
+	unsigned long total_low_mem;
+	int ret;
+
+	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
+
+	/* crashkernel=Y,low */
+	ret = parse_crashkernel_low(boot_command_line, total_low_mem, &low_size, &base);
+	if (ret) {
+		/*
+		 * two parts from lib/swiotlb.c:
+		 * -swiotlb size: user-specified with swiotlb= or default.
+		 *
+		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
+		 * to 8M for other buffers that may need to stay low too. Also
+		 * make sure we allocate enough extra low memory so that we
+		 * don't run out of DMA buffers for 32-bit devices.
+		 */
+		low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);
+	} else {
+		/* passed with crashkernel=0,low ? */
+		if (!low_size)
+			return 0;
+	}
+
+	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, SZ_2M);
+	if (!low_base) {
+		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
+				(unsigned long)(low_size >> 20));
+		return -ENOMEM;
+	}
+
+	ret = memblock_reserve(low_base, low_size);
+	if (ret) {
+		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
+		return ret;
+	}
+
+	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
+			(unsigned long)(low_size >> 20),
+			(unsigned long)(low_base >> 20),
+			(unsigned long)(total_low_mem >> 20));
+
+	crashk_low_res.start = low_base;
+	crashk_low_res.end   = low_base + low_size - 1;
+
+	return 0;
+}
+
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
  *
@@ -74,19 +125,28 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
 static void __init reserve_crashkernel(void)
 {
 	unsigned long long crash_base, crash_size;
+	bool high = false;
 	int ret;
 
 	ret = parse_crashkernel(boot_command_line, memblock_phys_mem_size(),
 				&crash_size, &crash_base);
 	/* no crashkernel= or invalid value specified */
-	if (ret || !crash_size)
-		return;
+	if (ret || !crash_size) {
+		/* crashkernel=X,high */
+		ret = parse_crashkernel_high(boot_command_line, memblock_phys_mem_size(),
+				&crash_size, &crash_base);
+		if (ret || !crash_size)
+			return;
+		high = true;
+	}
 
 	crash_size = PAGE_ALIGN(crash_size);
 
 	if (crash_base == 0) {
 		/* Current arm64 boot protocol requires 2MB alignment */
-		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
+		crash_base = memblock_find_in_range(0,
+				high ? memblock_end_of_DRAM()
+				: ARCH_LOW_ADDRESS_LIMIT,
 				crash_size, SZ_2M);
 		if (crash_base == 0) {
 			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
@@ -112,6 +172,11 @@ static void __init reserve_crashkernel(void)
 	}
 	memblock_reserve(crash_base, crash_size);
 
+	if (crash_base >= SZ_4G && reserve_crashkernel_low()) {
+		memblock_free(crash_base, crash_size);
+		return;
+	}
+
 	pr_info("crashkernel reserved: 0x%016llx - 0x%016llx (%lld MB)\n",
 		crash_base, crash_base + crash_size, crash_size >> 20);
 
-- 
2.7.4

