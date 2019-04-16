Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCA0AC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B5CB20857
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B5CB20857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 067526B0007; Tue, 16 Apr 2019 07:25:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 017826B0008; Tue, 16 Apr 2019 07:25:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E22306B000A; Tue, 16 Apr 2019 07:25:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id B202F6B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:25:01 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id c21so9619057oig.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:25:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uq4YXG/fd4i9tMfjG1TF9685MevsjIg/lcHigJ5WLOE=;
        b=sR6UpgpSnLz/tG6HXEGZ2gjL8/zTu3GjdbewvTgpQLZSiOvX/EoBnenFLGwLByc9M8
         1Cu9o83K3J9vNpnURRC6d8G5/zE5RUnXmxDOKiACFU9RQqD8fj5pzDIR2LmesSz7BsrL
         XP/fM1I7+//3Qt1cjCA+44TJVFC70MLPoYAjT064r11x/IKfhbsKdxV11HbyBF6RkHHQ
         YcTA9DQDrxeRyU3mz7BX1c8Xf7DNemuN4gy2FQdhGf4cWrImYjQABHEexb93wAKbdFiV
         pCuWzRJTySyS9/XEBl2K5QLJbO58jrXW1kiPlZcSKtWZIHJJJ/af6vR4knJQadpma1AM
         KXNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVJkBzN7Mg9YlphblLBWQki+OMOuwtWYWuxyaU1TZ/qKODCH3KS
	v5K2aB2sq5wDuzXqDFZ0th/zNooxQRQNNtZM3LpZqB6daR5Azq5moyVCEZhjuYGM7wU2l+RItx9
	5OyZxUsdqDF927WyfTh0dpmuqiXeioln1z4GcUZzahh5BvVeq9ljXhhScfott3CnE/Q==
X-Received: by 2002:aca:d7c6:: with SMTP id o189mr393339oig.2.1555413901375;
        Tue, 16 Apr 2019 04:25:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPFg5a1gokm1/DFANxGfzfKOO4S2Ma4ThcVosK0Dba15xmQt/Yr8O2sRB4nIffIy2lVxdg
X-Received: by 2002:aca:d7c6:: with SMTP id o189mr393307oig.2.1555413900320;
        Tue, 16 Apr 2019 04:25:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555413900; cv=none;
        d=google.com; s=arc-20160816;
        b=bZONwuwJtQSxn5lm5sEu1R9tN+zp9SPqYJ0XPIk8lDfW7jdRO/TWRBP0z69y7bNnzC
         Kj1bWtdS3Y/3FXUHQljizELqV/+VO0wvhqnsmo+zt6Z80foCDkx26sJ+9jNbttPZmN6o
         NG9/AL6RiQmnhFcTNiumzrR4P7WKGR9AVBr//DRmqlPIhRdzBS7ka/vZ8PwpSvrqw5MI
         kD0JwuKtugbksxGOAjx9fJOTAweSJzSeuaiKgP9pwhgjasfHRLvhk8hnu+ZcAah6RQ1L
         zuR0rdZbLBA2+pfe7Nm3J9Zy+wTdwRZxwMt+2DeOPjMZdKRofKetcoJJ2VUMtyPvZUZy
         FpZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uq4YXG/fd4i9tMfjG1TF9685MevsjIg/lcHigJ5WLOE=;
        b=Y2Px/x2w44nJmW+BINq8OZXYtXVVrkQ4qn9I7rclJo5im9ehBXKmss3+JkEsXU34/y
         UQlHiefp1Q2Gm6wPDjUMsvjgYCpQq0saVX6I5FUunqVQh+aOo2391hISWNOktTf7BE4u
         am3w/ST/TQUBknok2kW0RR2OLniQ+LrZL8GWukSKiKmdmhP609cnxOSSGNnj0NZX9KLd
         wVwbyyO09kpgiCUdhS+3Zxbo1eHAlwVjL76tp+wKbG3xlKGerIanHt5ZNJHruSzYrXmz
         SBKNbXekDoQmAzBOhg1fWMqUG2bnSVtDZIxBe/1ThKs6LGL2kOGYFtNeOTeW9nwQF84q
         vVmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id n26si24463296otf.203.2019.04.16.04.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 04:25:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 5239DDBC8B2B31FE47B3;
	Tue, 16 Apr 2019 19:24:54 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS413-HUB.china.huawei.com (10.3.19.213) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 19:24:47 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [RESEND PATCH v5 1/4] x86: kdump: move reserve_crashkernel_low() into kexec_core.c
Date: Tue, 16 Apr 2019 19:35:16 +0800
Message-ID: <20190416113519.90507-2-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190416113519.90507-1-chenzhou10@huawei.com>
References: <20190416113519.90507-1-chenzhou10@huawei.com>
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

In preparation for supporting more than one crash kernel regions
in arm64 as x86_64 does, move reserve_crashkernel_low() into
kexec/kexec_core.c.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/x86/include/asm/kexec.h |  3 ++
 arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
 include/linux/kexec.h        |  5 ++++
 kernel/kexec_core.c          | 56 +++++++++++++++++++++++++++++++++++++
 4 files changed, 71 insertions(+), 59 deletions(-)

diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
index 003f2da..485a514 100644
--- a/arch/x86/include/asm/kexec.h
+++ b/arch/x86/include/asm/kexec.h
@@ -18,6 +18,9 @@
 
 # define KEXEC_CONTROL_CODE_MAX_SIZE	2048
 
+/* 16M alignment for crash kernel regions */
+#define CRASH_ALIGN		(16 << 20)
+
 #ifndef __ASSEMBLY__
 
 #include <linux/string.h>
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 3773905..4182035 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -447,9 +447,6 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 
 #ifdef CONFIG_KEXEC_CORE
 
-/* 16M alignment for crash kernel regions */
-#define CRASH_ALIGN		(16 << 20)
-
 /*
  * Keep the crash kernel below this limit.  On 32 bits earlier kernels
  * would limit the kernel to the low 512 MiB due to mapping restrictions.
@@ -463,59 +460,6 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 # define CRASH_ADDR_HIGH_MAX	MAXMEM
 #endif
 
-static int __init reserve_crashkernel_low(void)
-{
-#ifdef CONFIG_X86_64
-	unsigned long long base, low_base = 0, low_size = 0;
-	unsigned long total_low_mem;
-	int ret;
-
-	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
-
-	/* crashkernel=Y,low */
-	ret = parse_crashkernel_low(boot_command_line, total_low_mem, &low_size, &base);
-	if (ret) {
-		/*
-		 * two parts from lib/swiotlb.c:
-		 * -swiotlb size: user-specified with swiotlb= or default.
-		 *
-		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
-		 * to 8M for other buffers that may need to stay low too. Also
-		 * make sure we allocate enough extra low memory so that we
-		 * don't run out of DMA buffers for 32-bit devices.
-		 */
-		low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);
-	} else {
-		/* passed with crashkernel=0,low ? */
-		if (!low_size)
-			return 0;
-	}
-
-	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, CRASH_ALIGN);
-	if (!low_base) {
-		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
-		       (unsigned long)(low_size >> 20));
-		return -ENOMEM;
-	}
-
-	ret = memblock_reserve(low_base, low_size);
-	if (ret) {
-		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
-		return ret;
-	}
-
-	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System low RAM: %ldMB)\n",
-		(unsigned long)(low_size >> 20),
-		(unsigned long)(low_base >> 20),
-		(unsigned long)(total_low_mem >> 20));
-
-	crashk_low_res.start = low_base;
-	crashk_low_res.end   = low_base + low_size - 1;
-	insert_resource(&iomem_resource, &crashk_low_res);
-#endif
-	return 0;
-}
-
 static void __init reserve_crashkernel(void)
 {
 	unsigned long long crash_size, crash_base, total_mem;
@@ -573,9 +517,13 @@ static void __init reserve_crashkernel(void)
 		return;
 	}
 
-	if (crash_base >= (1ULL << 32) && reserve_crashkernel_low()) {
-		memblock_free(crash_base, crash_size);
-		return;
+	if (crash_base >= (1ULL << 32)) {
+		if (reserve_crashkernel_low()) {
+			memblock_free(crash_base, crash_size);
+			return;
+		}
+
+		insert_resource(&iomem_resource, &crashk_low_res);
 	}
 
 	pr_info("Reserving %ldMB of memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index b9b1bc5..096ad63 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -63,6 +63,10 @@
 
 #define KEXEC_CORE_NOTE_NAME	CRASH_CORE_NOTE_NAME
 
+#ifndef CRASH_ALIGN
+#define CRASH_ALIGN SZ_128M
+#endif
+
 /*
  * This structure is used to hold the arguments that are used when loading
  * kernel binaries.
@@ -281,6 +285,7 @@ extern void __crash_kexec(struct pt_regs *);
 extern void crash_kexec(struct pt_regs *);
 int kexec_should_crash(struct task_struct *);
 int kexec_crash_loaded(void);
+int __init reserve_crashkernel_low(void);
 void crash_save_cpu(struct pt_regs *regs, int cpu);
 extern int kimage_crash_copy_vmcoreinfo(struct kimage *image);
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d714044..3492abd 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -39,6 +39,8 @@
 #include <linux/compiler.h>
 #include <linux/hugetlb.h>
 #include <linux/frame.h>
+#include <linux/memblock.h>
+#include <linux/swiotlb.h>
 
 #include <asm/page.h>
 #include <asm/sections.h>
@@ -96,6 +98,60 @@ int kexec_crash_loaded(void)
 }
 EXPORT_SYMBOL_GPL(kexec_crash_loaded);
 
+int __init reserve_crashkernel_low(void)
+{
+	unsigned long long base, low_base = 0, low_size = 0;
+	unsigned long total_low_mem;
+	int ret;
+
+	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
+
+	/* crashkernel=Y,low */
+	ret = parse_crashkernel_low(boot_command_line, total_low_mem,
+			&low_size, &base);
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
+		low_size = max(swiotlb_size_or_default() + (8UL << 20),
+				256UL << 20);
+	} else {
+		/* passed with crashkernel=0,low ? */
+		if (!low_size)
+			return 0;
+	}
+
+	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, CRASH_ALIGN);
+	if (!low_base) {
+		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
+		       (unsigned long)(low_size >> 20));
+		return -ENOMEM;
+	}
+
+	ret = memblock_reserve(low_base, low_size);
+	if (ret) {
+		pr_err("%s: Error reserving crashkernel low memblock.\n",
+				__func__);
+		return ret;
+	}
+
+	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System low RAM: %ldMB)\n",
+		(unsigned long)(low_size >> 20),
+		(unsigned long)(low_base >> 20),
+		(unsigned long)(total_low_mem >> 20));
+
+	crashk_low_res.start = low_base;
+	crashk_low_res.end   = low_base + low_size - 1;
+
+	return 0;
+}
+
 /*
  * When kexec transitions to the new kernel there is a one-to-one
  * mapping between physical and virtual addresses.  On processors
-- 
2.7.4

