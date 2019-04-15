Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97755C282E0
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5302C2146E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5302C2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAEAF6B0007; Mon, 15 Apr 2019 06:47:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2F326B0008; Mon, 15 Apr 2019 06:47:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF68C6B000A; Mon, 15 Apr 2019 06:47:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A67136B0006
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:47:05 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id i203so7710382oih.16
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:47:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=msW/DfQw6RLXEJV1GdO6xcS+vBgdX+OmDHFBMpqAuDk=;
        b=RR49gJU1UQeXUY7yKkGxmEPR4zS463B5u5zu/3OAXDFuhCF+uq1xizj0Mw23Dbr/F8
         ajXWxUlm8SlgUV4scZowkrQGjhzGQgQIGww+19rn2ijCuufS/tNjJBcktx/L6H4GdA+q
         v99I8eecQA9lEqkdsJ5yDIgoN71pmgvKYVryrGHlenVTvhWjycKifDrjz0GHSpF+smAV
         ml5s8l3/44zTH9zeu/VdUnR8YAJJqr5FV2Zb5c6s5nevPYAZEMxS4vHuBLWUUoImaqhg
         psLWE8pdT+Ks+xxx7C4I8WIFyOnJf4Pnh739hOodu9zkyD70OGV/+QdUVxkNWFFyop/w
         QW0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUtVPSALorH8qLm7Md1MO2BVEHAXyHlg1e56M62gn4DUhoEVfso
	vZLrKSnH2VJAS0ViKxcjCzcKtToVwrGb39/3naOMhUIvRHXGkLFF1i0HWFwoNE19EoPKNwRRx2S
	E1qX3NrDxRahTMj4n/a02AVfPJMqZqmElDa2Blenz1k6LI2EzJpW6PxfR4t3cKcf5ZA==
X-Received: by 2002:aca:d614:: with SMTP id n20mr19178922oig.46.1555325225328;
        Mon, 15 Apr 2019 03:47:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1TR9dtcmRqRHI15xTf/bOnEAzpZOov58dx7UqgwtHovHINB8NXHiY4j5z++IryTmXNg6N
X-Received: by 2002:aca:d614:: with SMTP id n20mr19178879oig.46.1555325224038;
        Mon, 15 Apr 2019 03:47:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555325224; cv=none;
        d=google.com; s=arc-20160816;
        b=tWLeu4ks5SUrX3sKwC2YPBvWmfpHla0Oiv86NMbsMndhkUeY5Sn3yYnw+yLWsYJsbh
         X/v+aV6JXo4TZwQDQODTIHf9EfrcxBD2aWQGZnilCIoSksUKFBRIDioSIP6FVYdGKeAj
         ftKj+dNPCxhtO7SBaO+7v808ehR5/9K6/ed238+J6VCPBvzI3pT8yKX2618g5/prkVC9
         LCwTEN0SX25j63ZxIgTqcNpR4arN3LS6kxZYwB5x8VQiMJoo+NbJB6rm64xsPzneWzx5
         xJPeTKXKPp897kHXxgQc4TNqSETLYlleNDTRjnNVEV61xV0lS4n5TCASDl6Bwe/Wo9t9
         FF7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=msW/DfQw6RLXEJV1GdO6xcS+vBgdX+OmDHFBMpqAuDk=;
        b=NNSk7O+vD5Yhkp62WVrZV64wRqJSJfdLWTHPXHj+CCQMPsOLpA/IaBQRZz598sBoMT
         Jk6RXM/SeXYyiIHgZ3EEn7quLYWk0FvqUtRACiZv3dJLur4fR8uVTxTzFyHVd+ILNHB3
         /chRPkC/55jjP3S/+2Rc9vX/lk0PGFMaQfthFOG+ivWGeHCCFZkTnZkGHYLIjUWqFieO
         GQsL7mLtRMJ5uUcyTEePTnt1aVFQ+CPLgX3W2MLQ9W77Fxn9Qs8FGXs0nRGH2znkHrbC
         mt6nY17tt8cY4A+BgWwJ9jzETyd7l5dqpQspEYgwmey5aKFa6+I1ZIXTuR3IxgVkPwJH
         cCpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id w6si22313972oiw.197.2019.04.15.03.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 03:47:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 727A8A52E617467592BB;
	Mon, 15 Apr 2019 18:46:58 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Mon, 15 Apr 2019 18:46:50 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v4 2/5] arm64: kdump: support reserving crashkernel above 4G
Date: Mon, 15 Apr 2019 18:57:22 +0800
Message-ID: <20190415105725.22088-3-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190415105725.22088-1-chenzhou10@huawei.com>
References: <20190415105725.22088-1-chenzhou10@huawei.com>
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
 arch/arm64/mm/init.c           | 25 ++++++++++++++++++++-----
 3 files changed, 26 insertions(+), 5 deletions(-)

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
index 972bf43..f5dde73 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -74,20 +74,30 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
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
@@ -105,13 +115,18 @@ static void __init reserve_crashkernel(void)
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

