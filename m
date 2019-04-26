Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17468C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C29E1206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="LEqxcCOv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C29E1206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590216B0010; Fri, 26 Apr 2019 12:23:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53F9C6B0266; Fri, 26 Apr 2019 12:23:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 406C36B0269; Fri, 26 Apr 2019 12:23:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA30F6B0010
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:34 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u14so3889792wrr.9
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=sweB+DaW1UN2f9uAvKlA3a8PiyyFy0m5BGhw/StJYM0=;
        b=OwXsc4qAL10yKdUF4jYU6p1boKM7vzPcERv+Mos99e15O8hmv9INU2MzXQ2VcBh5xQ
         jorbXnRLDsIGEVueTGPELXWQ5I++f7BiTFBNHt37EY7Ep5u4dOXW3gjC8N0Res2prapa
         cTlsyVWlcjoFX51iPgBhlM8VgktTZpX3QB2wf3mqs8+GcAjAcOSv6ENMVyolYH534Evf
         ba2eFm0DT6qmF3n69+7JQ49vvy+h60uBd1jRTqRzNyOd2WMNxtQlH9bOfRRPb5nDQJQs
         4TFULmzm1R0QHFj2BSP+S8UIk6S6r0DBbJePb1vFNxwM/HfJDDad9rY/1UYS3SkUmOi5
         IiUw==
X-Gm-Message-State: APjAAAUJpyA4v+cVd8ohtnDZy7W8dbIcYMKwgI/QEFuw44233XmfPLve
	EfEaYR3ISRBqDRUQrxRx94+XjSR3kpq1gagoLsUSL7osNjKRbx3LhSAvdZDIJmj+9535M8d5KIB
	+aAwI4aIeicWFA73oqvzo9nR1pNyvznQouTo89qnbigeF0lb5arKHoalFTdzN/Hjeiw==
X-Received: by 2002:a1c:2e89:: with SMTP id u131mr8675927wmu.82.1556295814447;
        Fri, 26 Apr 2019 09:23:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx65RbAqw1dtdLktBfZmk1H5q6sJaooHes/nsQRDCqkpWkeOL5W4bRrR1+1q795TdUirUBS
X-Received: by 2002:a1c:2e89:: with SMTP id u131mr8675854wmu.82.1556295813404;
        Fri, 26 Apr 2019 09:23:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295813; cv=none;
        d=google.com; s=arc-20160816;
        b=KhP+zsgQK6+6YXdx7KyhgJYT/ubR99NiYs7VmJORaxZKMzUS0WU+siAtfmg8jV7cHM
         AG5A3XaVoLKW+sGPHN8svQLZASQZrD881bhSveuXQJBJ/XGpRACKI57/2rAkJ6f1v/Jq
         kikryLvXDLN7AFMQzZCenQKd1E9FTAHX4t1neBYsQwHLvuhmQnxTNa0p3J/VZJ6Ki0Os
         r5tOh9ZbB1VXhE3/mGkiRmbC3Cl1m16S9mW8jW22XPARnxG687EMmuRPSbe09VfyV1PW
         qEefG1JiT9ZtGw6jYlwaMLmk2/03qAeZ0lBAIpjtG67A3+uZD616UMeipeFiqbZdemzV
         elLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=sweB+DaW1UN2f9uAvKlA3a8PiyyFy0m5BGhw/StJYM0=;
        b=ALRVVyfgunrsMvDj1p3P1bAWlEi6raaoR7n2WU3cdmbg5XYFL32EX98JUCbNdqjM7G
         Bh3cFr3lSoY0Oz1Rt8EuEkUIHKYya1bD7kivGQZsanr4nxBhfk0JtdUzqFMlnjIJWQuQ
         9smdMuQwJZ+a2DqbhQ/UtirqR8huCG6XKIWgkig/+6rhjnXlFql/PJwKKx+eSDcRQem0
         QADuI5ommR6uhxV8Pxris2pIsin1Qdu0ZXV7FI1j7FMx+FKyd7mdzk8RW8q+Fh4CZukO
         2X3fYSpW90069UDtHl6AcppFcSHL7VIL4LqPFeFUyEMNvWdkULgA8iqdVwaaOb4mNUrk
         1ppw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=LEqxcCOv;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id r11si9159400wrv.274.2019.04.26.09.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=LEqxcCOv;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9b1tx3z9v17x;
	Fri, 26 Apr 2019 18:23:31 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=LEqxcCOv; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Qp_p8rvlGYNe; Fri, 26 Apr 2019 18:23:31 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9b0nrSz9v17t;
	Fri, 26 Apr 2019 18:23:31 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295811; bh=sweB+DaW1UN2f9uAvKlA3a8PiyyFy0m5BGhw/StJYM0=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=LEqxcCOvi7fLRg8IRml/IXEJTh6cmPOh/J6m2hZHxzWjCknKGUWYnQmv5BUll4B14
	 kZEhWnqeArZd2dQgbQTTwDZabFhsR/Js+8bOcpv8PH6/XuLc2/OY1uSnoBa4EvtJ2D
	 E33ndypmJU7srzN4cmTAXwh/ou5onPTO+Cfe6PsM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BADDA8B950;
	Fri, 26 Apr 2019 18:23:32 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 0rznyVWAwIZ0; Fri, 26 Apr 2019 18:23:32 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8E8F58B82F;
	Fri, 26 Apr 2019 18:23:32 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 7BBB4666FE; Fri, 26 Apr 2019 16:23:32 +0000 (UTC)
Message-Id: <5aa7b8ed0620546c1f488533213a86c084e42ff2.1556295460.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 08/13] powerpc/32: prepare shadow area for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:32 +0000 (UTC)
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
index e12bec98366f..b91c17ba499b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -310,6 +310,10 @@ void __init mem_init(void)
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
index 63fc56feea15..48135ba6fa74 100644
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
 
@@ -323,6 +327,10 @@ static void populate_markers(void)
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

