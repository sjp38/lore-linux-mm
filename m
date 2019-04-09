Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BEAAC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCD1E21473
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:17:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCD1E21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8015C6B000D; Tue,  9 Apr 2019 06:17:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B14F6B0010; Tue,  9 Apr 2019 06:17:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69FDE6B0266; Tue,  9 Apr 2019 06:17:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 427E76B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:17:38 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id h23so2766788vsp.14
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BbYjAm+yXyOq6O85Gve2jDCfjYogITxlH3pTVha67WQ=;
        b=PF+7oPEo6+N4nng8DbjcEPkXlzys6F51xT/UpWnKX7LGmln3UVr6DyLlzC0KE1loZj
         LhnHuNYma18YAAQacPvwicqq5r1xE5kP0tGTr+ZytfNPM+Zy5ecsvMCzrVZq0h7/nKsT
         /qEyrnAhmZLRMGhx80VsQp/bpT4LW1W0h4qNxkUp7Y/P8fN9PVu1Sp/gkh8E8W9WowIy
         d58go78co/dO+/sbgXT10+PPG9Y/eAv7N9b48GHPzU0NpCunY525lx4wm9hcyVexnkpg
         aHJ00JrHcMccEhRLeyeYcW6/LIOwlAY9MOYFT2EhU+iPR1kSPJnzwqFtatNKihDcN769
         eObg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVbprHIZyfYsI2+Pt2kLUKy3EJ+1q6J9dyR+sbIcqGL2icKD8pY
	MyiNjNO4KTtJijaPofov4Qz/KhpfdSnrt+5zDT9a3yASnPmmWVAVZA5R3CmIvh43qkaqzOPx88Y
	AqQ8vAo8gIn7r4wr7vu+e7zIkiEt9k8lxLMJekp0V0CR9OwWQNKihWgQ3OacIBMk3zw==
X-Received: by 2002:a67:e20c:: with SMTP id g12mr20769845vsa.188.1554805057983;
        Tue, 09 Apr 2019 03:17:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwX84mCGR2gdRwwcn8tNyw0D88modxXemVmfvMvB2blGdMCKweQyShCZxxH9PWpL9yvGqsF
X-Received: by 2002:a67:e20c:: with SMTP id g12mr20769810vsa.188.1554805057032;
        Tue, 09 Apr 2019 03:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554805057; cv=none;
        d=google.com; s=arc-20160816;
        b=N6jGCkSI/Y6Rfctcndubp9PYOe0qgjZ7ALcelxOfq4CU3v4wbPLUhdDRaVKCmte61X
         BPyHwBU3qFmzXW9BcADq8f+qHqSEfytMz1E04It7uIBHOIHw+OJghOv8diRYUHe7ohvt
         biVyLpXOe5+JGI+Ke86VnIYS8efbCjTjR1ikYULeQvmDEr7M/s/1vuPWj/uYsVY5m8MV
         7CXESrh1eii63ub8kA39DhpqC0rapfefGJWdaS1YNJgXVsXq9gKAmXThKYxhmoHINkzw
         k9twBjSFa4toKUvMe5yhd2Ga426v9y5zom+oLBCle+DvqLODxFXm+OdUIc+TKCw4Bq7r
         1Plg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BbYjAm+yXyOq6O85Gve2jDCfjYogITxlH3pTVha67WQ=;
        b=HKJC5init35TqFaWi4gPOZ672bRRre9Efz3aXJf6VmO/LtK1gR3nOf4/DJUNGyQpIU
         6erWKhN6j7yPDGSqp8+nKfLXol3BTcPbLr/JjgCPuP6OBk2RDZJkLAjDuuXT0ujSVhUt
         izV8LkrbRgnfVe+UzBy1fksnGs9h1/CzmScsHFeNfUZ6IJTXITGLXkR1EbvqcM3jbDUo
         zUY03IKvpnEqXRJEOStsw5q9XDFdon4qbpeDjMQ66IYnAChzTostBQZE3Za9AQ90xr5x
         2q88XBXJ88OQUqgbT+AE2Hp+C0AFzi+8sytoIHKNxpPIgoqI8TFNSdlEoDSZ4H7Nmyu5
         c0hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id q19si6187412vsn.70.2019.04.09.03.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:17:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 5F1B8B18EC5747D21AA4;
	Tue,  9 Apr 2019 18:17:31 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 18:17:24 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v3 2/4] arm64: kdump: support reserving crashkernel above 4G
Date: Tue, 9 Apr 2019 18:28:17 +0800
Message-ID: <20190409102819.121335-3-chenzhou10@huawei.com>
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

When crashkernel is reserved above 4G in memory, kernel should
reserve some amount of low memory for swiotlb and some DMA buffers.

Kernel would try to allocate at least 256M below 4G automatically
as x86_64 if crashkernel is above 4G. Meanwhile, support
crashkernel=X,[high,low] in arm64.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/include/asm/kexec.h |  3 +++
 arch/arm64/kernel/setup.c      |  3 +++
 arch/arm64/mm/init.c           | 26 +++++++++++++++++++++-----
 3 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexec.h
index 67e4cb7..32949bf 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -28,6 +28,9 @@
 
 #define KEXEC_ARCH KEXEC_ARCH_AARCH64
 
+/* 2M alignment for crash kernel regions */
+#define CRASH_ALIGN	SZ_2M
+
 #ifndef __ASSEMBLY__
 
 /**
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
index 972bf43..3bebddf 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -64,6 +64,7 @@ EXPORT_SYMBOL(memstart_addr);
 phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
+
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
  *
@@ -74,20 +75,30 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
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
+		ret = parse_crashkernel_high(boot_command_line,
+				memblock_phys_mem_size(),
+				&crash_size, &crash_base);
+		if (ret || !crash_size)
+			return;
+		high = true;
+	}
 
 	crash_size = PAGE_ALIGN(crash_size);
 
 	if (crash_base == 0) {
 		/* Current arm64 boot protocol requires 2MB alignment */
-		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
-				crash_size, SZ_2M);
+		crash_base = memblock_find_in_range(0,
+				high ? memblock_end_of_DRAM()
+				: ARCH_LOW_ADDRESS_LIMIT,
+				crash_size, CRASH_ALIGN);
 		if (crash_base == 0) {
 			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
 				crash_size);
@@ -105,13 +116,18 @@ static void __init reserve_crashkernel(void)
 			return;
 		}
 
-		if (!IS_ALIGNED(crash_base, SZ_2M)) {
+		if (!IS_ALIGNED(crash_base, CRASH_ALIGN)) {
 			pr_warn("cannot reserve crashkernel: base address is not 2MB aligned\n");
 			return;
 		}
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

