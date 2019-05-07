Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52586C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1197B20835
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1197B20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B45056B0006; Mon,  6 May 2019 23:42:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF62D6B0007; Mon,  6 May 2019 23:42:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0BC06B0008; Mon,  6 May 2019 23:42:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79BC66B0006
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:42:17 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r78so1360776oie.8
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:42:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cbtj+TMP+/lIzIc/5TZ2OkHDkxCb2+xgbljpaF/2A7w=;
        b=dnIapa51EZCUG/6r1rijKz5lsdUzCs0uuCZlfnqrRrr8G5SK7tZ0BLWkprGoqPuxuR
         6gEfhGia+g7V0NTUBjRl6Yiz42hjtY5GtNTc0Yc3sDFY9+XmwSzG313LGcbzjGXjtQfW
         Y1hul1/V+y4VXtRnmnh7ESfTu4/5JnnSv3hdKB1GyOiDwRkVOcc3E0OepwlFHX45mtGS
         DWIff6NUx67NLnEzg5teq5LckiU+M0gUB7d4PWaHQW5rklCDYQ3eqFBpnJ+f/S8rO07B
         gUksBiog+wX4SbhdeWmx4OA3Wj/l/gtIMkCi6F2NbkcJ4hYhcZ3UMFP00PKLpR56JMbW
         iH6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAV+1n1m/GGH+KO+/TklHWP5824EgQsYH0KXDsxINR9Yq+V4Q+3G
	5X/8jUC2GB1M/iKAnl6hxLlV8LFiqdBZGB/yVC7wsq4674xR+iFfVdRlb/kFL2SA65KFLSFP2oZ
	LdXeQ/VfpYcjp6lxAn9Vkaa3A/So4lMH+ZLvRkEa3cA7uUePSsCyUh+47zcTmihwMpw==
X-Received: by 2002:a05:6830:15cc:: with SMTP id j12mr20486102otr.2.1557200537078;
        Mon, 06 May 2019 20:42:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1L+YMWqyLmHbDSD9JcZlywTRNECkT6NRokXOtkElrybWnGrms9sRHNbnkJHLf+2xjqosK
X-Received: by 2002:a05:6830:15cc:: with SMTP id j12mr20486051otr.2.1557200535789;
        Mon, 06 May 2019 20:42:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557200535; cv=none;
        d=google.com; s=arc-20160816;
        b=ANS5fRCrqCy+0QWHUTxF3aEN2eyVF26y001MJ9yKBhPpuOD4+TDkxRNI4inpTdwUGO
         nXaU06kS8b23pdsdMQgJtq1LDJud6Jy0WSD3m9GxuY3qu46zxJg8pgVenUj5YOAHo/vc
         pFQXGpomsstov2ChOk1beE7YNj+N7denkKV0ThbERbhlntdFlcOw1njLHZ3ltgTGm1vj
         NiFORxTfnfP7LtPSLo1d4vMUUjgc6Avy43oRDtBrohHRuOHsYH9tFqC5yn5MlRkqyzd3
         72gWDe5afMqGc7i+O6SAlR0lPDLX+39m78UO5aR4xr7c5xiJhPqgvhPEYXKlevOKO3uE
         BlqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cbtj+TMP+/lIzIc/5TZ2OkHDkxCb2+xgbljpaF/2A7w=;
        b=uIFRctcK2NjXzJ6H1U8bSCy89JGUfd5PdOA5xnI4Qq3/D3Ef0zIvDGDOckkOwpofHg
         YaYuEr7P9WpRkeMuS2x2i2fDH1jeUcMLjzsBPi88//44WjU2bBPkIA28Zy/Ek5BXL3qa
         QgQyK00i2j+Ee0h2nRauo9+nU6q3MGGib5wT/hccWln7DQyu8cRUbZk05pBkTJ2v9mj/
         Gez7ma3nrb7SXdHv8ONO9InATF8IRI6fr7szCKOCnpLb0t7APUxkKfaeryKmDzxSZA+N
         WvbyGJ0UVYrt1lghMhVkhf6WYOGnS7dM3cNoJCgJ3/UZIza5DTafn6aMG0dDKhBs4Wfp
         O4bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 91si8200469otj.27.2019.05.06.20.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:42:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 5923ECCBB0A73C5F1D49;
	Tue,  7 May 2019 11:42:10 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS403-HUB.china.huawei.com (10.3.19.203) with Microsoft SMTP Server id
 14.3.439.0; Tue, 7 May 2019 11:42:02 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 2/4] arm64: kdump: support reserving crashkernel above 4G
Date: Tue, 7 May 2019 11:50:56 +0800
Message-ID: <20190507035058.63992-3-chenzhou10@huawei.com>
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

When crashkernel is reserved above 4G in memory, kernel should
reserve some amount of low memory for swiotlb and some DMA buffers.

Meanwhile, support crashkernel=X,[high,low] in arm64. When use
crashkernel=X parameter, try low memory first and fall back to high
memory unless "crashkernel=X,high" is specified.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/include/asm/kexec.h |  3 +++
 arch/arm64/kernel/setup.c      |  3 +++
 arch/arm64/mm/init.c           | 34 ++++++++++++++++++++++++++++------
 3 files changed, 34 insertions(+), 6 deletions(-)

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
index d2adffb..3fcd739 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -74,20 +74,37 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
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
-		/* Current arm64 boot protocol requires 2MB alignment */
-		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
-				crash_size, SZ_2M);
+		/*
+		 * Try low memory first and fall back to high memory
+		 * unless "crashkernel=size[KMG],high" is specified.
+		 */
+		if (!high)
+			crash_base = memblock_find_in_range(0,
+					ARCH_LOW_ADDRESS_LIMIT,
+					crash_size, CRASH_ALIGN);
+		if (!crash_base)
+			crash_base = memblock_find_in_range(0,
+					memblock_end_of_DRAM(),
+					crash_size, CRASH_ALIGN);
 		if (crash_base == 0) {
 			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
 				crash_size);
@@ -105,13 +122,18 @@ static void __init reserve_crashkernel(void)
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

