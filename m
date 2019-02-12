Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F467C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:36:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D15A92184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:36:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="sIAd7nbD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D15A92184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5811C8E0014; Tue, 12 Feb 2019 08:36:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E0468E0011; Tue, 12 Feb 2019 08:36:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 383678E0014; Tue, 12 Feb 2019 08:36:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id D3A488E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:36:56 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o6so697813wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:36:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
        b=gILlJiiVa3Y4e0B4oROQaLsPjMLpASUcQ0ifUYtldY36TMbthoIYUVy75M++F2gMdW
         hcNmAU7oRz3CE539weU48TAwQsho0CqNJuOGVfaZSoH38ceVUU/8hB9AHkRTWvsbbCjs
         clTbanIUqFuxlGH4FL2fIQi27DnC1w5OwuP8hBTAw33pA+SF/nKH6edblam0CEtiUwVv
         7Cn/3WmExCjW5vQyLXIO49+qNUcZ1dNjz3Fl+t5/y7RgIJbFDbmxTJAMTafgacwm8cNj
         A5vKgLbK9I/bmdRxoU2vutf6pKIfmgiTbJICyEau5okypYZZfNgefB160aVly/byMp4A
         FhrA==
X-Gm-Message-State: AHQUAuYPq1mjDQoNnwRV082gf2vMBI5WloG5VRUiF2rLrwzO7+o5hGmo
	Ciip6b/nlut53n+/msLacepAA4fGuyGELfq0Stha/CTmlA1N29ly5B+3y3E1M1KOEqYTVTbgsGg
	icZU16kFrNuJK7k6MqwrqwMaODwrt7iwjYfn+uzB7zCE6oNrzN4jNDvdkcKH5HIC7yw==
X-Received: by 2002:a5d:42c3:: with SMTP id t3mr2852240wrr.232.1549978616350;
        Tue, 12 Feb 2019 05:36:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdLo+vbUO/dRTfOcn0aNNgFRuJ2A5/Lw/PXQrqA12m9jLxJJeZ4mrmXQzzx512iciQNx4P
X-Received: by 2002:a5d:42c3:: with SMTP id t3mr2852193wrr.232.1549978615389;
        Tue, 12 Feb 2019 05:36:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549978615; cv=none;
        d=google.com; s=arc-20160816;
        b=RwoIQDgSrEl83+dlGcd2aOCfQnX9QaSIHkuzVAQSTNUJRXNBeYAvYnwYucPCNbe4Ka
         1P0m2j3Gk+ywaCz1wwSOEMzt6th548eHUFHFjllsKVMovWOa0lFLT7+p4Zq7GSY7bf0b
         Sd8VWNHSnRdcAOziHjl1fAcAsZRXSE7Gffg95z2TKVxwiBI2Lnk3binUlbtsD9izuZzv
         gLGDaQrMR2sWvgp7tMOt4MCvhL8slWiTWsUMMwkeshpWCdFFS6LndmdJEnKdkofYPD6H
         7T5r3F+KVik/hbaFcZf23dW9npDQR0Qt5FDk3OKFSNBziz7eURuXxSbWLlZFz5BmApFd
         VJAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
        b=hBMwYQGvBzWtxwoCNZt3ItedygPtBgWP/QvZ2mP5lu7UDZisfmDqB1qtzXfOFyRuoQ
         f3h5PpI3K+PmajK//4hCQ8l8rMVS1k5UUarZ7Vrz7l2KiQjZ6AchFjDWaLUmcIkQS6v1
         WKn/1Im8AT68cgsvDuDYahVZTN6KRywdByiRekhKlrLM8E6fSQE90FvRYT6GC6+TV3Ey
         ZLxbDZ4a2eEa207iYSrQVdf36WKQE/bshuTWi2JPtt62n754S3zA5nYa5PAG7B1Du3Qk
         UOccLhkwKHbE4/g/0FznX1H6HH0oJO3N8VGtPa2O3XqvIXExMWp6o6vnd2h/a0T+0nTW
         qbRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=sIAd7nbD;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id r3si1764507wmr.56.2019.02.12.05.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:36:55 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=sIAd7nbD;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43zNx13cvVz9v1GD;
	Tue, 12 Feb 2019 14:36:53 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=sIAd7nbD; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id xsKuGGxoC2yM; Tue, 12 Feb 2019 14:36:53 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43zNx12TGMz9v1G9;
	Tue, 12 Feb 2019 14:36:53 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1549978613; bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=sIAd7nbDC1VwV8Afr/wcZD2SIm0bW0o6k4DeF750glbRjbKdWWDQjtrVXsxm53tY0
	 /nvRCZumHdmgxhz6UJMWote+UYjcpzqApo44uL4+pfPRZTmlPxENu+aCA+88B5eoHK
	 55KiluMdmLA+iugFaQJS/if1lUh5hWevpepxNVSI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id ABA068B7FA;
	Tue, 12 Feb 2019 14:36:54 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Ccb7slrn6q5v; Tue, 12 Feb 2019 14:36:54 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 66EE98B7EB;
	Tue, 12 Feb 2019 14:36:54 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 50C4B6899C; Tue, 12 Feb 2019 13:36:54 +0000 (UTC)
Message-Id: <3d737385a3c51f247073578e247f2bbee41433de.1549935251.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1549935247.git.christophe.leroy@c-s.fr>
References: <cover.1549935247.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v5 2/3] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Feb 2019 13:36:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation of KASAN, move early_init() into a separate
file in order to allow deactivation of KASAN for that function.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile   |  2 +-
 arch/powerpc/kernel/early_32.c | 35 +++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_32.c | 26 --------------------------
 3 files changed, 36 insertions(+), 27 deletions(-)
 create mode 100644 arch/powerpc/kernel/early_32.c

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index cb7f0bb9ee71..879b36602748 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -93,7 +93,7 @@ extra-y				+= vmlinux.lds
 
 obj-$(CONFIG_RELOCATABLE)	+= reloc_$(BITS).o
 
-obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o
+obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o early_32.o
 obj-$(CONFIG_PPC64)		+= dma-iommu.o iommu.o
 obj-$(CONFIG_KGDB)		+= kgdb.o
 obj-$(CONFIG_BOOTX_TEXT)	+= btext.o
diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
new file mode 100644
index 000000000000..b3e40d6d651c
--- /dev/null
+++ b/arch/powerpc/kernel/early_32.c
@@ -0,0 +1,35 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Early init before relocation
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <asm/setup.h>
+#include <asm/sections.h>
+
+/*
+ * We're called here very early in the boot.
+ *
+ * Note that the kernel may be running at an address which is different
+ * from the address that it was linked at, so we must use RELOC/PTRRELOC
+ * to access static data (including strings).  -- paulus
+ */
+notrace unsigned long __init early_init(unsigned long dt_ptr)
+{
+	unsigned long offset = reloc_offset();
+
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
+
+	/*
+	 * Identify the CPU type and fix up code sections
+	 * that depend on which cpu we have.
+	 */
+	identify_cpu(offset, mfspr(SPRN_PVR));
+
+	apply_feature_fixups();
+
+	return KERNELBASE + offset;
+}
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 5e761eb16a6d..b46a9a33225b 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -63,32 +63,6 @@ EXPORT_SYMBOL(DMA_MODE_READ);
 EXPORT_SYMBOL(DMA_MODE_WRITE);
 
 /*
- * We're called here very early in the boot.
- *
- * Note that the kernel may be running at an address which is different
- * from the address that it was linked at, so we must use RELOC/PTRRELOC
- * to access static data (including strings).  -- paulus
- */
-notrace unsigned long __init early_init(unsigned long dt_ptr)
-{
-	unsigned long offset = reloc_offset();
-
-	/* First zero the BSS */
-	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
-
-	/*
-	 * Identify the CPU type and fix up code sections
-	 * that depend on which cpu we have.
-	 */
-	identify_cpu(offset, mfspr(SPRN_PVR));
-
-	apply_feature_fixups();
-
-	return KERNELBASE + offset;
-}
-
-
-/*
  * This is run before start_kernel(), the kernel has been relocated
  * and we are running with enough of the MMU enabled to have our
  * proper kernel virtual addresses
-- 
2.13.3

