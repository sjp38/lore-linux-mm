Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70255C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E10C2184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Nwupw03o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E10C2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E74118E000C; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D60C98E0003; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3CC08E000B; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57E948E000A
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e18so6555501wrw.10
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=9WWLsnNzNQXN6uyA4WXOLTkM/MttJFdvvbgAI1QArIs=;
        b=DVuQaQULDVjS1O5nU8jNWXXCNBqLVGZb1xNXxHMFCRd5zzlEMFXIIFensTLa01AFnL
         Ra7cNfd7nXS8ZU52JxwnxuiA1HpF8PP/+CFjWoShIIKOJvzIJMzHYT/tqL++sks4TG48
         Az4oK9XjW1afTt0IMnRY6yFltm8pGUrVLv8R/gE07GTFLll61S8uyse/hEZB8ou5Mt4V
         Fdck/6SlIW2JBnBHWv2Sm2monqtm1cNJpgPsxj6f2GtnK1MBtP6iN6b5+RvPkmbMy0Ww
         c15+Eo+cSZ4VLfuhdy/EYWs46iwehz7LuyztoqnNROD7mHgzqKsiOJs3x5vkv/iD9SI/
         W0Qw==
X-Gm-Message-State: AHQUAuYwlBBpl6ZbUeZNnXXaTAChkG2Nde5RmgwKh3Sr5+hR5hyQHe5Y
	bKX/YQNDsCQViuBOjJbBOu1umll0GlKoNA8RzHQbaApe9VH9njxmDXTTyZnNv1MHKii78CquBQV
	RUslXnou+t4zYnrL0/MIOoMK1uf/NplArMdeTfeuXVL0hrxjNgom0/BCINvWnN4Ddpg==
X-Received: by 2002:adf:f80e:: with SMTP id s14mr17715908wrp.327.1551201771872;
        Tue, 26 Feb 2019 09:22:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY3N+iMGwAX5FE3UluoFejmaPRnceCAYf3RRhUNf/k76NUb/smp7AJvRMkYm4wuAlP2OHGE
X-Received: by 2002:adf:f80e:: with SMTP id s14mr17715859wrp.327.1551201771004;
        Tue, 26 Feb 2019 09:22:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201771; cv=none;
        d=google.com; s=arc-20160816;
        b=OQawb5dY15xygLC4BdwEPTWD3TMKODs6c94EKZ1W+OefUz9yVmcqvz7mN7h4dj/ZXg
         N/vYtxsSc/AwCF423C53hs8rmCzinHxDWPZPexW8nE+07n1g59xTj5P0KRw0PRwypg/0
         Ny+3AHtELZIZnie3dKwoS18t9eGt53sfI41OIxQBCUQ+OujnxP1tKWIEX1TQ1wkh68gC
         GfrIp+BU8C8WNLSHH8NhN12TqWLUy8oO5NcnGpJ7n4whvIt8FUDDLMfySaeEJE64E7dP
         gq1kFRe1rqdd9NnUtftEJcWxogmhrRtLk0z9aMjpW0p8n//YowBTIon+xd3FufJS1URO
         m+5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=9WWLsnNzNQXN6uyA4WXOLTkM/MttJFdvvbgAI1QArIs=;
        b=uuiHinhtxQvF8B0BSy5Bc5ShD5Z6+g/kaPBvqnl5vOi2sj5U4MDkHO+mGcXrutuq6E
         SGtrRuLXBv0XBO1BCYrRvy+9Y8c3WCV03r12arjS3I2H1hUSbSUh2VAcTGvKD0JZk0/v
         GVjT++3XmA+Okz06GcayGWukE4/iaaxuRRXVXpmjryfLFGpAK3DhHy1uI99NxjnvSfN/
         Uvz/pQ/XwPPfYXEWLnR3/+OTQIyAgpvQzgC5Gp2WvyRfXLizXj6QjTHH9u4nMB9w4yfv
         ObPKfvS50GIAuGsxfkA/yeVu+FUVl5sTJhtm4ktMtQLo24hG+Goht5pLjy2V8JswWdfG
         y+1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Nwupw03o;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id c22si8369419wre.159.2019.02.26.09.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:50 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Nwupw03o;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485HC2fnwz9vJLj;
	Tue, 26 Feb 2019 18:22:47 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Nwupw03o; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id E1hUwubnfJlW; Tue, 26 Feb 2019 18:22:47 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485HC1WXpz9vJLY;
	Tue, 26 Feb 2019 18:22:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201767; bh=9WWLsnNzNQXN6uyA4WXOLTkM/MttJFdvvbgAI1QArIs=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Nwupw03oUS/8fLp0zsWXuErryzFh5FbVDw5GdLgHv1vV9rwEo/acx2wNvSCyoDA/t
	 2gBq4GVi86PculPVL/CT5wwmP08X9pHzrSn180cIkGTBffmHWDbTPoytXRRy24YEU5
	 jvw5Hp1CYh9gblwKamKQSCa5LkVYUOtfIiBIedbg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CFF6C8B97A;
	Tue, 26 Feb 2019 18:22:48 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id o3Hu4eQBWEVD; Tue, 26 Feb 2019 18:22:48 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8512A8B96A;
	Tue, 26 Feb 2019 18:22:48 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5F07B6F7A6; Tue, 26 Feb 2019 17:22:48 +0000 (UTC)
Message-Id: <afd4577920ccf25425297ab12268d34c887eb453.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 07/11] powerpc/32: prepare shadow area for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:48 +0000 (UTC)
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
index c3161b8fc017..8dc1e3819171 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -12,4 +12,20 @@
 #define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
 #endif
 
+#ifndef __ASSEMBLY__
+
+#include <asm/page.h>
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

