Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C42DC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBD9D206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ZAXbdIYv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBD9D206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A94E08E0008; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CBB18E0006; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 844788E0008; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12F798E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f202so4729569wme.2
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=wOp+cCgsVh5E5KqJ2LQ86dr6R33x9NHGT6pzPUXZ9UA=;
        b=Z7+VuwHjXh7l6SkfO/aydCQ2WsxS3qBD2hDmLG/dT/F3mMDvm97OnnfvdV6MWEmFa/
         +Z55mPtEDeGX06Y+y7SFqoxdJC9OTTm5I+3cTVFrSCfDLMFdBOwhNTzw/OK66jAaioV7
         65YgGVc+f9DSjFhoaigtn4UsYBwDcylfsj2/Ywsj7i4tSv5Zc+VrhgLsy355iNyVhvx2
         UwWQgkV0vCvCOZb9ldaEvpy2gJh+I6LC/jMwmdj8OUrVdr4EGmHEFGT+i9zMVygJZMwx
         Rl6liDNt7XUmNcZpIhfhj2/t5wBEunYl+FblMu/fNkR00eJXj61D+R8vm+D4THJ6Jmnp
         6Nlg==
X-Gm-Message-State: AHQUAua+Y6Yz+D7tJCIx6K0iz2fcpt8o993DGdppz7CiaSjoUTdvIg0J
	PC2YYornBdhCMpLW2BPA7mN57PomaoD9rPAYnctGnZjW8DfBU5zHugbTK6IelLwp5plxe9nzoBj
	gbdLWE5ucQYQGjFSZUU9jSE3GogX0Q3qXru6znp+/twdmxt2tWTMPN0YjVO2o9249XA==
X-Received: by 2002:a1c:a98b:: with SMTP id s133mr2885287wme.129.1551443627554;
        Fri, 01 Mar 2019 04:33:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqyQd+s++xhnlD2kmDY67ZR26aVdIEMSqMSU5a/giJQQdt5w23T+BDM5zI3rAm2Hff6gCI+r
X-Received: by 2002:a1c:a98b:: with SMTP id s133mr2885232wme.129.1551443626414;
        Fri, 01 Mar 2019 04:33:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443626; cv=none;
        d=google.com; s=arc-20160816;
        b=Hy4cSlwimu90mME6vbixH6457ZHvNfAHc03GDRQ5Z9VYJxegP0v+wnBI5av+e09yvf
         +ZcrbWsjici4hJ6FvcGWLwnSAbZSHf8abJ7fYWeD7ITRM5DT9f5fYEfqo+ODJvOMX4O4
         hJNrfLrweEVxPpRjMg9IfPor1zy9uIhdxR+DhPD4HVIZ5w/+Uj/ZPNCxu+NO5ZVOBuW0
         tWr9A2pbIbCCeim/4+dVhjb6f9V2cAcNPSfFBoPOC/STmDBZUcnTkwardjE7OQmCvvbO
         qA0Mlo7h4o3bI5F7w7zH7ykGy3zVpgJOYJPrMqbQt7NXgUU5VfY0yM9Mcse/DITNPSCr
         HPhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=wOp+cCgsVh5E5KqJ2LQ86dr6R33x9NHGT6pzPUXZ9UA=;
        b=dBUMWhmUxyG3hQ/u5HJmiNJZm7CvpuNeSLo0H9fmQUJTriYWzUdYtOkJwxa9+lgL+5
         TE6nDMIYFrJ+DK7AvO//5lHfJ7sMu6xWqfUxqQ661mvxIseGgzHcMPfm33TdAE0bB5wC
         ooWi6NLUAz2ISAM3qJOw6uE174zRwC3AL2p77KEVCR6bWQACWXUz+U5K6fg3U3XHKIw8
         4IUsgjPzEzqV3WvDgUaQM+P0c74/tnZwLFSXSUFF5kiTP3x/GXxJzjRTVvtXzgdQHQPa
         C+sLY3WcjnGPGPzNjeOen4Uss7maw4cYZHX8vmOrLrgE9kwKdhN6Yoalf4i7OyXbKXqK
         MzEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ZAXbdIYv;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id c5si6742497wre.391.2019.03.01.04.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:46 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ZAXbdIYv;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkJ4tB4z9txrs;
	Fri,  1 Mar 2019 13:33:44 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ZAXbdIYv; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id kqsEEKBkVul6; Fri,  1 Mar 2019 13:33:44 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkJ2yDPz9txrh;
	Fri,  1 Mar 2019 13:33:44 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443624; bh=wOp+cCgsVh5E5KqJ2LQ86dr6R33x9NHGT6pzPUXZ9UA=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ZAXbdIYvIWx53i88f+qr0+QLez8MDSlT6ouKuxWCmXEsPJR8dGE6iPiw4TjDwn/57
	 uxQtDwYrG9AIAXh08QgcyKTB5rute96CvvW801O/LegcXXZBiGS+DYhGdTQ4mvZW9S
	 oJTxm6bwBRh+tMVTBinRFOwHffyXBfCYYsFL/1po=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id ACB678BB8B;
	Fri,  1 Mar 2019 13:33:45 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Hx9uE9wxRzRx; Fri,  1 Mar 2019 13:33:45 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6A0DE8BB73;
	Fri,  1 Mar 2019 13:33:45 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 49A066F89E; Fri,  1 Mar 2019 12:33:45 +0000 (UTC)
Message-Id: <f7944c8327709905fc3d30b7f5ee674cd63a0fc2.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 07/11] powerpc/32: prepare shadow area for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:45 +0000 (UTC)
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

