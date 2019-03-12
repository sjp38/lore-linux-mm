Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C2ACC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F5C6213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="fQXoenqm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F5C6213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AD638E000C; Tue, 12 Mar 2019 18:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80D6A8E0008; Tue, 12 Mar 2019 18:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6883A8E000C; Tue, 12 Mar 2019 18:16:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCBF8E0008
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:18 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a5so1615260wrq.3
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=mIGQaprlAVCVWpPiH4xPJkXAyE92iR9cx2tnTNWnRqU=;
        b=HMSPZ1xmlljfhDhsGxSVbQjugBIiRDHtjmQTSsBcIbxLN5/hEQSbiUUlupF6ujEsz4
         haeojwyRgwNEfMoWQj6cSTesZ5NCkT85dFMnAuwwLANeFa0VsD0/qbGlyRwXaNIbpWu9
         FBVYwMy7TusiUOXKRf6Zvbgctne/2qwhGgbpGnOdne5aQHPZCwnQ/vRu3anxjbdJOmFX
         OJ8NYDEBRUYRR1fF0Ifi4yNOKaww3n1yMFkYoJDl4b+4RGsf4ZLsWeFaOBV5SL4NBT50
         QxSxGq04Qm06yx6Lrh27QpTsTK6qlEKgFUTEXrOtyIL6aecQiCkBNMhJltwdCA5jAoIv
         R6OQ==
X-Gm-Message-State: APjAAAXTTIw3EvwU0p/VHHEBmVg3LRxX1gLLO2ZyYmP4jw6LyL3orzcp
	AE6YivAD6ULM5OyPoHIhSZDyS8Yh4wV3V8B/lighe7mmV0F7zHmkftJc2PfFkSqRz+y8m6MYnM5
	YxDxkgR5ndbFPx4FgMTqkFUDu4eM132S5o9/0TL+CDWDmEPF15XSb1kmDeLUUyGcuOw==
X-Received: by 2002:a1c:96ce:: with SMTP id y197mr30503wmd.126.1552428977268;
        Tue, 12 Mar 2019 15:16:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhhVEI9HaE4BJWiLTTn016XGRpncBxIwWYOLAqsPDex2cSx0DQ+bewh3VIYspYVmaSDB1s
X-Received: by 2002:a1c:96ce:: with SMTP id y197mr30464wmd.126.1552428976021;
        Tue, 12 Mar 2019 15:16:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428976; cv=none;
        d=google.com; s=arc-20160816;
        b=kQyHwr2SQLr37yYeCrs7gfAzFb07JY0cATBbhd+mTsqM8x6Pl31xRyaUgug8jMMHeq
         Imspfey9em62xWnRBVeFhSS/k4VoxBVxQ4r9fk/i8G/WrCv4N2ZsbjAm9/e+H/G/3rHo
         /OWvT3RgNQJ+eslW/j1WEEVV3oxTc5edxLrNJiNN8JEsj+OWjoY4GG6LsiRI9Tzh8iVg
         ynSv+SL0TgKhUXDqJwo/Y7RlUCIp1L8K1oh6VoeLufjZbl+T5aR8P+0olr+hmOi7GMrJ
         /eiCSkmFbNjjsF9VdaSW6GrnadOPZumxxtGtkJ7B99ou/8WxbGB0Mc3Xl0VKjkARTU2D
         pbmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=mIGQaprlAVCVWpPiH4xPJkXAyE92iR9cx2tnTNWnRqU=;
        b=GQbcqXkZw48D/794xiSSgCJvKYoxBrX3yPAdNsHGv+XAACJufDmG4O3D9GjGz0fkXv
         9JmsEeeGpCFGiPYzyIPS3mLEqkDwqk4tqJaOseHEsrBPYEdreToK7i6HlcE2/rCAtxsr
         F+a/FPJWpBYUNc35CpirxfVRUlB9cH8mVHpuAnNJ4tu2XZvn9pdOnJPON8EVGGxGhuH+
         IHMzJvRJKo6acVx3NT//NgpAtkyt5oYKKuwErNSMW6y/xvlAcCssEeIw3RZhk77n0srj
         g5Cfol7nPx0+kvtJMiwWkX5fzM/d2FxW9Qf1PeWMwp1m/kPeROOhBQ/fGZLkTtgJwFi8
         Gn3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=fQXoenqm;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id p21si7427wmh.194.2019.03.12.15.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=fQXoenqm;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7M26gczB09Zt;
	Tue, 12 Mar 2019 23:16:15 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=fQXoenqm; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id EGUj0-8sqf2W; Tue, 12 Mar 2019 23:16:15 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7M0xDPzB09ZG;
	Tue, 12 Mar 2019 23:16:15 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428975; bh=mIGQaprlAVCVWpPiH4xPJkXAyE92iR9cx2tnTNWnRqU=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=fQXoenqm0P/pOBebO8hAN+jBJviFvKS7NXJNClJzbO3yPlr+BfXpE8olkWTXIqIWQ
	 JN4rPm6po/CtsDbWm5giWD1Hx5PvyEod2zciYPIVeO/nz0+M9vTpVKFX7HC4z29YHC
	 e+lOdfyIVMx63wfeVNhLjHiwFYAKkEecDGoICk24=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 571DD8B8B1;
	Tue, 12 Mar 2019 23:16:15 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id aG88fi4S6WiR; Tue, 12 Mar 2019 23:16:15 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 1A8BC8B8A7;
	Tue, 12 Mar 2019 23:16:15 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id D9B0D6FA15; Tue, 12 Mar 2019 22:16:14 +0000 (UTC)
Message-Id: <9ddd549404655be32ea511fc055f50bc168bb30d.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 09/18] powerpc/32: prepare shadow area for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:14 +0000 (UTC)
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
 arch/powerpc/Kconfig.debug        |  5 +++++
 arch/powerpc/include/asm/fixmap.h |  5 +++++
 arch/powerpc/include/asm/kasan.h  | 16 ++++++++++++++++
 arch/powerpc/mm/mem.c             |  4 ++++
 arch/powerpc/mm/ptdump/ptdump.c   |  8 ++++++++
 5 files changed, 38 insertions(+)

diff --git a/arch/powerpc/Kconfig.debug b/arch/powerpc/Kconfig.debug
index 4e00cb0a5464..61febbbdd02b 100644
--- a/arch/powerpc/Kconfig.debug
+++ b/arch/powerpc/Kconfig.debug
@@ -366,3 +366,8 @@ config PPC_FAST_ENDIAN_SWITCH
         depends on DEBUG_KERNEL && PPC_BOOK3S_64
         help
 	  If you're unsure what this is, say N.
+
+config KASAN_SHADOW_OFFSET
+	hex
+	depends on KASAN
+	default 0xe0000000
diff --git a/arch/powerpc/include/asm/fixmap.h b/arch/powerpc/include/asm/fixmap.h
index b9fbed84ddca..0cfc365d814b 100644
--- a/arch/powerpc/include/asm/fixmap.h
+++ b/arch/powerpc/include/asm/fixmap.h
@@ -22,7 +22,12 @@
 #include <asm/kmap_types.h>
 #endif
 
+#ifdef CONFIG_KASAN
+#include <asm/kasan.h>
+#define FIXADDR_TOP	(KASAN_SHADOW_START - PAGE_SIZE)
+#else
 #define FIXADDR_TOP	((unsigned long)(-PAGE_SIZE))
+#endif
 
 /*
  * Here we define all the compile-time 'special' virtual
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 2c179a39d4ba..05274dea3109 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -12,4 +12,20 @@
 #define EXPORT_SYMBOL_KASAN(fn)
 #endif
 
+#ifndef __ASSEMBLY__
+
+#include <asm/page.h>
+
+#define KASAN_SHADOW_SCALE_SHIFT	3
+
+#define KASAN_SHADOW_START	(KASAN_SHADOW_OFFSET + \
+				 (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT))
+
+#define KASAN_SHADOW_OFFSET	ASM_CONST(CONFIG_KASAN_SHADOW_OFFSET)
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

