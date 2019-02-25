Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BA26C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0F3220842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="wCmnPKwz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0F3220842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D7358E017D; Mon, 25 Feb 2019 08:48:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73B6B8E011F; Mon, 25 Feb 2019 08:48:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64E708E017D; Mon, 25 Feb 2019 08:48:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03FE38E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:45 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id m2so2158156wrs.23
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=fF6LjTP5Ef3hsquG7Y6XBTU3dO56YlYJpsVAo831ABM=;
        b=JDwsNbj2UWjLtUQN/FafPd5RfNG6n16NIXLzb+x0jfw3wi3hSwLdztvGBInEm7J4IA
         bsHw2moxjMj7SV0Lx5PuMwTVsL79nHbFD7fJbODU4x/LO82pS/NNVasrEKezKvF86urg
         8abMj1I7LsEeh2f1zbYExZszs7ZdKpY3PUGhsKTP/PSFCe28d8R6VGU0EwZQ9iPFFhp4
         ldq1N/nwODB8xtQxNloCIO/YjFiUKDjRZbPvl1FfDIV/MSzV/qy9pvayKHt/ooTqGdT+
         CQo6L4WREgu9xz7ixfJVsIH69HJZomXCrsG8MKnadkcxwRzPfYFdK8EjwuOBWhqRSSwz
         rvvQ==
X-Gm-Message-State: AHQUAubX/3xMcq+O4uPWAnBDcyM8oSIrOm4Ka0EUpXG/r3MflB/FLAlB
	5ORCJnEw4241m3ZXbrZALRnai/xFwyyZbgahVpb98ZnTR2kAu7oV0zDVpVDpuMgmjjyaDkJsKc0
	P93vK7QTiQgrRaPu/OEQeon7o/BpVIkSrIYHHhT9xPcc5ElUNU7ytIhMiNNKSf5MUIA==
X-Received: by 2002:a1c:e0d7:: with SMTP id x206mr10923350wmg.152.1551102524510;
        Mon, 25 Feb 2019 05:48:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IabBD0zvfLK/bzhobElvZzkIBqwYXpa3s6cv3i5k5h/dk4rdlO+ox+qjLmw0VNTZuRB6YmX
X-Received: by 2002:a1c:e0d7:: with SMTP id x206mr10923291wmg.152.1551102523428;
        Mon, 25 Feb 2019 05:48:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102523; cv=none;
        d=google.com; s=arc-20160816;
        b=Pzqi2FG/7x8XdZ1T0Xx9gXBecT7/EZsocF1SG5bgtFQqzV7bDMyHj5aZtAAQplEb1V
         ZOTGOT0N98FgOeny34d+7cDQGyDDHwLRxNOPXXl8K6Stmp+/LNx14FOlkfdqR7MA/SuY
         T5wTKtJnY+s7e/REB0UnMUkntjpJTva5/KHL3vc4K2eGRotLsohLARHyFFBsVG5ph/Ja
         f0JL6HImNexc1vXW8PF2Sa5rssQZk+3qcaRH5GTPNl8cMr1s3IrrE+yUVjIfEuBxCsAT
         ygc8o8t9FQPXtFlXpzKGfGrg6beo7V7/GVRbDxAzr+iQKhU7AS4kCpezVdp+n0InubrX
         h5pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=fF6LjTP5Ef3hsquG7Y6XBTU3dO56YlYJpsVAo831ABM=;
        b=QhxDsrOeFYNJWlfM6wxKBMADdXpF3Z5ZCYu3ilSCD+JJs7Eddt9P0eDK8Hm1CSUU/9
         I+2e1kesCEyDXUaTHa+ccBKA18ynm8EFS6AlLtjeZlSsL1eh2p5ctXdU8Dpof8itRITD
         ZeLF8lwb8eznzVzDB/MmgQgBTMixcxYgvE2LG4/7zFxQ8QiNsWvD9Le07YDK6iTKVDyl
         pop4e6i7FcEE031B2FRLiu6jC1TLhU71XxYPpZjR8Nnz9Ar7KK5RQPDvv6XgQ+kazTHH
         3Hj4BbnDNnwjQrsbZT8ji0n0MYw2ZeIii6PcSxxAjXCsivwfAxtluo9Uaut/PCPpMG/M
         scIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=wCmnPKwz;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id b1si5656353wmg.88.2019.02.25.05.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:43 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=wCmnPKwz;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZY6k4GzB09Zy;
	Mon, 25 Feb 2019 14:48:37 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=wCmnPKwz; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id ADRVeE-l3elj; Mon, 25 Feb 2019 14:48:37 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZY5b2tzB09Zn;
	Mon, 25 Feb 2019 14:48:37 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102517; bh=fF6LjTP5Ef3hsquG7Y6XBTU3dO56YlYJpsVAo831ABM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=wCmnPKwzCLDNOLCiscA/KESLJ4fbF2vwYcH6QM5d/0uVh9xt8mU8NyQeswDgNOahv
	 sHtP8AWt9i/xJDumilkf4Lsf+w3XBrGYsvjbAXI+Wo0p7xcX01rXP0ciuDUMvn69m/
	 hC31j4yPbRMuhtZXCBxxQpZS2HbM+1mvlxtWNMUg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 1B6E28B845;
	Mon, 25 Feb 2019 14:48:42 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id cHyaQZ8BiJa5; Mon, 25 Feb 2019 14:48:42 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DFC7C8B81D;
	Mon, 25 Feb 2019 14:48:41 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 731256F20E; Mon, 25 Feb 2019 13:48:42 +0000 (UTC)
Message-Id: <bada5c0051f749565d27da9527ce933aa205bf86.1551098214.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 07/11] powerpc/32: prepare shadow area for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch prepares a shadow area for KASAN.

The shadow area will be at the top of the kernel virtual
memory space above the fixmap area and will occupy one
eighth of the total kernel virtual memory space.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig              |  5 +++++
 arch/powerpc/include/asm/fixmap.h |  5 +++++
 arch/powerpc/include/asm/kasan.h  | 17 +++++++++++++++++
 arch/powerpc/mm/mem.c             |  4 ++++
 arch/powerpc/mm/ptdump/ptdump.c   |  8 ++++++++
 5 files changed, 39 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 652c25260838..f446e016f4a1 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -382,6 +382,11 @@ config PGTABLE_LEVELS
 	default 3 if PPC_64K_PAGES && !PPC_BOOK3S_64
 	default 4
 
+config KASAN_SHADOW_OFFSET
+	hex
+	depends on KASAN
+	default 0xe0000000
+
 source "arch/powerpc/sysdev/Kconfig"
 source "arch/powerpc/platforms/Kconfig"
 
diff --git a/arch/powerpc/include/asm/fixmap.h b/arch/powerpc/include/asm/fixmap.h
index b9fbed84ddca..51a1a309c919 100644
--- a/arch/powerpc/include/asm/fixmap.h
+++ b/arch/powerpc/include/asm/fixmap.h
@@ -22,7 +22,12 @@
 #include <asm/kmap_types.h>
 #endif
 
+#ifdef CONFIG_KASAN
+#include <asm/kasan.h>
+#define FIXADDR_TOP	KASAN_SHADOW_START
+#else
 #define FIXADDR_TOP	((unsigned long)(-PAGE_SIZE))
+#endif
 
 /*
  * Here we define all the compile-time 'special' virtual
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 2efd0e42cfc9..b554d3bd3e2c 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -12,4 +12,21 @@
 #define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
 #endif
 
+#ifndef __ASSEMBLY__
+
+#include <asm/page.h>
+#include <asm/pgtable-types.h>
+
+#define KASAN_SHADOW_SCALE_SHIFT	3
+
+#define KASAN_SHADOW_OFFSET	ASM_CONST(CONFIG_KASAN_SHADOW_OFFSET)
+
+#define KASAN_SHADOW_START	(KASAN_SHADOW_OFFSET + \
+				 (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT))
+
+#define KASAN_SHADOW_END	0UL
+
+#define KASAN_SHADOW_SIZE	(KASAN_SHADOW_END - KASAN_SHADOW_START)
+
+#endif /* __ASSEMBLY */
 #endif
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index f6787f90e158..4e7fa4eb2dd3 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -309,6 +309,10 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 #ifdef CONFIG_PPC32
 	pr_info("Kernel virtual memory layout:\n");
+#ifdef CONFIG_KASAN
+	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
+		KASAN_SHADOW_START, KASAN_SHADOW_END);
+#endif
 	pr_info("  * 0x%08lx..0x%08lx  : fixmap\n", FIXADDR_START, FIXADDR_TOP);
 #ifdef CONFIG_HIGHMEM
 	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
diff --git a/arch/powerpc/mm/ptdump/ptdump.c b/arch/powerpc/mm/ptdump/ptdump.c
index 37138428ab55..812ed680024f 100644
--- a/arch/powerpc/mm/ptdump/ptdump.c
+++ b/arch/powerpc/mm/ptdump/ptdump.c
@@ -101,6 +101,10 @@ static struct addr_marker address_markers[] = {
 	{ 0,	"Fixmap start" },
 	{ 0,	"Fixmap end" },
 #endif
+#ifdef CONFIG_KASAN
+	{ 0,	"kasan shadow mem start" },
+	{ 0,	"kasan shadow mem end" },
+#endif
 	{ -1,	NULL },
 };
 
@@ -322,6 +326,10 @@ static void populate_markers(void)
 #endif
 	address_markers[i++].start_address = FIXADDR_START;
 	address_markers[i++].start_address = FIXADDR_TOP;
+#ifdef CONFIG_KASAN
+	address_markers[i++].start_address = KASAN_SHADOW_START;
+	address_markers[i++].start_address = KASAN_SHADOW_END;
+#endif
 #endif /* CONFIG_PPC64 */
 }
 
-- 
2.13.3

