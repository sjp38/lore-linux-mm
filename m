Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 219A8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBCEC2083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="lZqqumOq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBCEC2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEB6B8E0007; Tue, 19 Feb 2019 12:23:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D76168E0002; Tue, 19 Feb 2019 12:23:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB37D8E0007; Tue, 19 Feb 2019 12:23:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 387C08E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:18 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id f193so969917wme.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=Yw2ZtQrJ1HYjYkdCLzo3FNLSK6gpGmVkHVd7ituMUWY=;
        b=it1O/pTCryZ5V371uTFND0WrmyFg8tNsggzS/lE/QvV8LDidw/szEBjIx1ZUF7RJ8h
         Lyi9jNxc/Kzo+daNVSAWBUfwI/rQaIt1WqApjwglgTwNxwZhRvV9qGqIaCdwZvaz51QV
         exNF2qrHOcgXEY8esWu6YByp7sLY8hJ+E9AziVVQQjJ17AHPrCXT6l4BLwQoa5/ZCy8V
         zgukvJal2rHBKgn9dG9zHLyoowoIcgTmNX9yPvAo+Kr+PfcfhtmKsAkqMQ1Y0ol8Flh3
         WvDEJGxe7UrIea5AIJ5tDsHUm3EeLrkDiqQjbuy8C/3yILlG9t9zaqyJcxgnaNMOxFNW
         isqg==
X-Gm-Message-State: AHQUAuYCbhXDpKmaOK98CcHdN0tRvnTF12XBj5wHfGC3uqeUjN6iuezZ
	YYDyGPKSS8ej12qLUUBcMpgGnDAr+kEMMQXyFIGQuCMeQ697jUWiBNOXbczeMVTIS9CLxBq+b5l
	a6qMazx4WbqXtiN2nfimAWXkKbg15wbVYDTM187o+ccyD8bytVOeJ61/WhA/TYvq9Cw==
X-Received: by 2002:a1c:f901:: with SMTP id x1mr3643122wmh.84.1550596997677;
        Tue, 19 Feb 2019 09:23:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZx/8XAoIgcjCBDjSCKkkmikg0+JbsrJMqxF/m/68joIfLS4WjQvXDeW1eAcbizAnDq5XKI
X-Received: by 2002:a1c:f901:: with SMTP id x1mr3643041wmh.84.1550596995674;
        Tue, 19 Feb 2019 09:23:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596995; cv=none;
        d=google.com; s=arc-20160816;
        b=GL0WpvN3PyYcFagtx9u7q2mAOvGuTO4i3NjyGy0bDrZqlodnpJk3gFLrQ5GCCkDRQ3
         iy0WF+ziLnWCoPiBOqyUKrEV/eLz2Hm4ieDAwE9dPThukhDbbNL3cjrXUrjf3EkX8zAw
         jhBykGjsx/dIzrGbdiT+kto3sdQ+gB/qDHJ2H+mIoXCWoEgExeEmzh7eC9BhEMXqffjz
         7fomaeV6D9rEe47JIqehsAOWekjuJ6w4YcZUabKnEqRCRy0O+Yae0pf29vh8llTYs9sv
         8aisqA3fOoloB8pC3edxpZKehJmselTjYUWD8F+z/VC3ZjHgZusHu0pRecJWgyLoqcZn
         auHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=Yw2ZtQrJ1HYjYkdCLzo3FNLSK6gpGmVkHVd7ituMUWY=;
        b=iKMbT4/ulH3zCjMgeNEggBGTlwyBE/sTux6yH8FvFdOmqB56m5mK9B7CHdeex+kA3K
         Wnvy58xLUgZqTMKUbxkP1y6ccpYIue7Z6HUHAlNgNOgs3iVdzE62IimyIHeJ2nqgNnPr
         uW3gf02CXOfbSVNBfxVXnYs/8XfHjt3OmN/rORkF+cdkpG1xHTuiHm/4O7HxyjYwd0KG
         whF4L1EO9sekS9sAYCS8DxBTCEm3vngUj5jbKuBbDebuuqkQM6wv8WpKw87zZyl/im9P
         hGQdetcMBmnEXIIunQqfSoOh75OM1KeuFTvLGh59TzsGFQh89AdhQ2+ktvShJyzepLp7
         8txQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=lZqqumOq;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id t26si1827319wmj.126.2019.02.19.09.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:15 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=lZqqumOq;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443ncx3gmdz9v4wn;
	Tue, 19 Feb 2019 18:23:13 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=lZqqumOq; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id mlDnaT9CFsDG; Tue, 19 Feb 2019 18:23:13 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443ncx2XC1z9v4wf;
	Tue, 19 Feb 2019 18:23:13 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596993; bh=Yw2ZtQrJ1HYjYkdCLzo3FNLSK6gpGmVkHVd7ituMUWY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=lZqqumOq6PMrhqsmWZo01352DCKv7o5Ra/5njZJvl+TReTFxEfRv7vRepDoLd5+5f
	 FO3VLtB4GpYOOuVd9OH6UTbDktQYGXdhvkuJtiMafH7E7EYCbNEOtrJQ231P0iqTUG
	 oY7kCB5htNYWVGl7VnHmM9o/96cwdUcO+LWThJp0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id F3B8E8B7FE;
	Tue, 19 Feb 2019 18:23:14 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id a-4ips5300rl; Tue, 19 Feb 2019 18:23:14 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8F3358B7F9;
	Tue, 19 Feb 2019 18:23:14 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 683996E81D; Tue, 19 Feb 2019 17:23:14 +0000 (UTC)
Message-Id: <e51647fdac60d523892cd3eab3217c3a4d8d356b.1550596242.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1550596242.git.christophe.leroy@c-s.fr>
References: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 4/6] powerpc/32: Add KASAN support
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds KASAN support for PPC32.

The KASAN shadow area is located between the vmalloc area and the
fixmap area.

KASAN_SHADOW_OFFSET is calculated in asm/kasan.h and extracted
by Makefile prepare rule via asm-offsets.h

For modules, the shadow area is allocated at module_alloc().

Note that on book3s it will only work on the 603 because the other
ones use hash table and can therefore not share a single PTE table
covering the entire early KASAN shadow area.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig                          |   1 +
 arch/powerpc/Makefile                         |   7 ++
 arch/powerpc/include/asm/book3s/32/pgtable.h  |   2 +
 arch/powerpc/include/asm/highmem.h            |  10 +-
 arch/powerpc/include/asm/kasan.h              |  23 ++++
 arch/powerpc/include/asm/nohash/32/pgtable.h  |   2 +
 arch/powerpc/include/asm/setup.h              |   5 +
 arch/powerpc/kernel/Makefile                  |   9 +-
 arch/powerpc/kernel/asm-offsets.c             |   4 +
 arch/powerpc/kernel/head_32.S                 |   3 +
 arch/powerpc/kernel/head_40x.S                |   3 +
 arch/powerpc/kernel/head_44x.S                |   3 +
 arch/powerpc/kernel/head_8xx.S                |   3 +
 arch/powerpc/kernel/head_fsl_booke.S          |   3 +
 arch/powerpc/kernel/setup-common.c            |   2 +
 arch/powerpc/lib/Makefile                     |   8 ++
 arch/powerpc/mm/Makefile                      |   1 +
 arch/powerpc/mm/kasan/Makefile                |   5 +
 arch/powerpc/mm/kasan/kasan_init_32.c         | 147 ++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                         |   4 +
 arch/powerpc/mm/ptdump/dump_linuxpagetables.c |   8 ++
 arch/powerpc/purgatory/Makefile               |   3 +
 arch/powerpc/xmon/Makefile                    |   1 +
 23 files changed, 253 insertions(+), 4 deletions(-)
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 08908219fba9..850b06def84f 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -175,6 +175,7 @@ config PPC
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN			if PPC32
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
diff --git a/arch/powerpc/Makefile b/arch/powerpc/Makefile
index ac033341ed55..f0738099e31e 100644
--- a/arch/powerpc/Makefile
+++ b/arch/powerpc/Makefile
@@ -427,6 +427,13 @@ else
 endif
 endif
 
+ifdef CONFIG_KASAN
+prepare: kasan_prepare
+
+kasan_prepare: prepare0
+       $(eval KASAN_SHADOW_OFFSET = $(shell awk '{if ($$2 == "KASAN_SHADOW_OFFSET") print $$3;}' include/generated/asm-offsets.h))
+endif
+
 # Check toolchain versions:
 # - gcc-4.6 is the minimum kernel-wide version so nothing required.
 checkbin:
diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index 49d76adb9bc5..4543016f80ca 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -141,6 +141,8 @@ static inline bool pte_user(pte_t pte)
  */
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
+#elif defined(CONFIG_KASAN)
+#define KVIRT_TOP	KASAN_SHADOW_START
 #else
 #define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
 #endif
diff --git a/arch/powerpc/include/asm/highmem.h b/arch/powerpc/include/asm/highmem.h
index a4b65b186ec6..483b90025bef 100644
--- a/arch/powerpc/include/asm/highmem.h
+++ b/arch/powerpc/include/asm/highmem.h
@@ -28,6 +28,7 @@
 #include <asm/cacheflush.h>
 #include <asm/page.h>
 #include <asm/fixmap.h>
+#include <asm/kasan.h>
 
 extern pte_t *kmap_pte;
 extern pgprot_t kmap_prot;
@@ -50,10 +51,15 @@ extern pte_t *pkmap_page_table;
 #define PKMAP_ORDER	9
 #endif
 #define LAST_PKMAP	(1 << PKMAP_ORDER)
+#ifdef CONFIG_KASAN
+#define PKMAP_TOP	KASAN_SHADOW_START
+#else
+#define PKMAP_TOP	FIXADDR_START
+#endif
 #ifndef CONFIG_PPC_4K_PAGES
-#define PKMAP_BASE	(FIXADDR_START - PAGE_SIZE*(LAST_PKMAP + 1))
+#define PKMAP_BASE	(PKMAP_TOP - PAGE_SIZE*(LAST_PKMAP + 1))
 #else
-#define PKMAP_BASE	((FIXADDR_START - PAGE_SIZE*(LAST_PKMAP + 1)) & PMD_MASK)
+#define PKMAP_BASE	((PKMAP_TOP - PAGE_SIZE*(LAST_PKMAP + 1)) & PMD_MASK)
 #endif
 #define LAST_PKMAP_MASK	(LAST_PKMAP-1)
 #define PKMAP_NR(virt)  ((virt-PKMAP_BASE) >> PAGE_SHIFT)
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 2efd0e42cfc9..0bc9148f5d87 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -12,4 +12,27 @@
 #define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
 #endif
 
+#ifndef __ASSEMBLY__
+
+#include <asm/page.h>
+#include <asm/pgtable-types.h>
+
+#define KASAN_SHADOW_SCALE_SHIFT	3
+
+#define KASAN_SHADOW_OFFSET	(KASAN_SHADOW_START - \
+				 (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT))
+
+#define KASAN_SHADOW_END	(KASAN_SHADOW_START + KASAN_SHADOW_SIZE)
+
+#include <asm/fixmap.h>
+
+#define KASAN_SHADOW_START	(ALIGN_DOWN(FIXADDR_START - KASAN_SHADOW_SIZE, \
+					    PGDIR_SIZE))
+
+#define KASAN_SHADOW_SIZE	((~0UL - PAGE_OFFSET + 1) >> KASAN_SHADOW_SCALE_SHIFT)
+
+void kasan_early_init(void);
+void kasan_init(void);
+
+#endif /* __ASSEMBLY */
 #endif
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index bed433358260..b3b52f02be1a 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -71,6 +71,8 @@ extern int icache_44x_need_flush;
  */
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
+#elif defined(CONFIG_KASAN)
+#define KVIRT_TOP	KASAN_SHADOW_START
 #else
 #define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
 #endif
diff --git a/arch/powerpc/include/asm/setup.h b/arch/powerpc/include/asm/setup.h
index 65676e2325b8..da7768aa996a 100644
--- a/arch/powerpc/include/asm/setup.h
+++ b/arch/powerpc/include/asm/setup.h
@@ -74,6 +74,11 @@ static inline void setup_spectre_v2(void) {};
 #endif
 void do_btb_flush_fixups(void);
 
+#ifndef CONFIG_KASAN
+static inline void kasan_early_init(void) { }
+static inline void kasan_init(void) { }
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #endif	/* _ASM_POWERPC_SETUP_H */
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 879b36602748..fc4c42262694 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -16,8 +16,9 @@ CFLAGS_prom_init.o      += -fPIC
 CFLAGS_btext.o		+= -fPIC
 endif
 
-CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
-CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
+CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
+CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
 CFLAGS_btext.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
 CFLAGS_prom.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
 
@@ -31,6 +32,10 @@ CFLAGS_REMOVE_btext.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_prom.o = $(CC_FLAGS_FTRACE)
 endif
 
+KASAN_SANITIZE_early_32.o := n
+KASAN_SANITIZE_cputable.o := n
+KASAN_SANITIZE_prom_init.o := n
+
 obj-y				:= cputable.o ptrace.o syscalls.o \
 				   irq.o align.o signal_32.o pmc.o vdso.o \
 				   process.o systbl.o idle.o \
diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
index 9ffc72ded73a..846fb30b1190 100644
--- a/arch/powerpc/kernel/asm-offsets.c
+++ b/arch/powerpc/kernel/asm-offsets.c
@@ -783,5 +783,9 @@ int main(void)
 	DEFINE(VIRT_IMMR_BASE, (u64)__fix_to_virt(FIX_IMMR_BASE));
 #endif
 
+#ifdef CONFIG_KASAN
+	DEFINE(KASAN_SHADOW_OFFSET, KASAN_SHADOW_OFFSET);
+#endif
+
 	return 0;
 }
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 05b08db3901d..0ec9dec06bc2 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -962,6 +962,9 @@ start_here:
  * Do early platform-specific initialization,
  * and set up the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
index b19d78410511..5d6ff8fa7e2b 100644
--- a/arch/powerpc/kernel/head_40x.S
+++ b/arch/powerpc/kernel/head_40x.S
@@ -848,6 +848,9 @@ start_here:
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_44x.S b/arch/powerpc/kernel/head_44x.S
index bf23c19c92d6..7ca14dff6192 100644
--- a/arch/powerpc/kernel/head_44x.S
+++ b/arch/powerpc/kernel/head_44x.S
@@ -203,6 +203,9 @@ _ENTRY(_start);
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index fe2857ef0309..88f0cb34cef4 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -823,6 +823,9 @@ start_here:
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	li	r3,0
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/head_fsl_booke.S b/arch/powerpc/kernel/head_fsl_booke.S
index 2386ce2a9c6e..4f4585a68850 100644
--- a/arch/powerpc/kernel/head_fsl_booke.S
+++ b/arch/powerpc/kernel/head_fsl_booke.S
@@ -274,6 +274,9 @@ set_ivor:
 /*
  * Decide what sort of machine this is and initialize the MMU.
  */
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	mr	r3,r30
 	mr	r4,r31
 	bl	machine_init
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index ca00fbb97cf8..16ff1ea66805 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -978,6 +978,8 @@ void __init setup_arch(char **cmdline_p)
 
 	paging_init();
 
+	kasan_init();
+
 	/* Initialize the MMU context management stuff. */
 	mmu_context_init();
 
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index ee08a7e1bcdf..7efbd5122c74 100644
--- a/arch/powerpc/lib/Makefile
+++ b/arch/powerpc/lib/Makefile
@@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
 
+KASAN_SANITIZE_code-patching.o := n
+KASAN_SANITIZE_feature-fixups.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y += alloc.o code-patching.o feature-fixups.o
 
 ifndef CONFIG_KASAN
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index ee1efa3b3382..292b96ce1efc 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -47,3 +47,4 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
 obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
+obj-$(CONFIG_KASAN)		+= kasan/
diff --git a/arch/powerpc/mm/kasan/Makefile b/arch/powerpc/mm/kasan/Makefile
new file mode 100644
index 000000000000..6577897673dd
--- /dev/null
+++ b/arch/powerpc/mm/kasan/Makefile
@@ -0,0 +1,5 @@
+# SPDX-License-Identifier: GPL-2.0
+
+KASAN_SANITIZE := n
+
+obj-$(CONFIG_PPC32)           += kasan_init_32.o
diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
new file mode 100644
index 000000000000..495c908d6ee6
--- /dev/null
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -0,0 +1,147 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/kasan.h>
+#include <linux/printk.h>
+#include <linux/memblock.h>
+#include <linux/sched/task.h>
+#include <linux/vmalloc.h>
+#include <asm/pgalloc.h>
+
+void __init kasan_early_init(void)
+{
+	unsigned long addr = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
+	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
+	int i;
+	phys_addr_t pa = __pa(kasan_early_shadow_page);
+
+	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
+
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		panic("KASAN not supported with Hash MMU\n");
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
+			     kasan_early_shadow_pte + i,
+			     pfn_pte(PHYS_PFN(pa), PAGE_KERNEL), 0);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void __ref *kasan_get_one_page(void)
+{
+	if (slab_is_available())
+		return (void *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
+
+	return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+}
+
+static int __ref kasan_init_region(void *start, size_t size)
+{
+	void *end = start + size;
+	unsigned long k_start, k_end, k_cur, k_next;
+	pmd_t *pmd;
+	void *block = NULL;
+
+	if (start >= end)
+		return 0;
+
+	k_start = (unsigned long)kasan_mem_to_shadow(start);
+	k_end = (unsigned long)kasan_mem_to_shadow(end);
+	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
+
+	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
+		k_next = pgd_addr_end(k_cur, k_end);
+		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
+			pte_t *new = pte_alloc_one_kernel(&init_mm);
+
+			if (!new)
+				return -ENOMEM;
+			memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
+			pmd_populate_kernel(&init_mm, pmd, new);
+		}
+	};
+
+	if (!slab_is_available())
+		block = memblock_alloc(k_end - k_start, PAGE_SIZE);
+
+	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
+		void *va = block ? block + k_cur - k_start :
+				   kasan_get_one_page();
+		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
+
+		if (!va)
+			return -ENOMEM;
+
+		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
+		pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
+	}
+	flush_tlb_kernel_range(k_start, k_end);
+	return 0;
+}
+
+static void __init kasan_remap_early_shadow_ro(void)
+{
+	unsigned long k_cur;
+	phys_addr_t pa = __pa(kasan_early_shadow_page);
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		ptep_set_wrprotect(&init_mm, 0, kasan_early_shadow_pte + i);
+
+	for (k_cur = PAGE_OFFSET & PAGE_MASK; k_cur; k_cur += PAGE_SIZE) {
+		pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
+		pte_t *ptep = pte_offset_kernel(pmd, k_cur);
+
+		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte)
+			continue;
+		if ((pte_val(*ptep) & PAGE_MASK) != pa)
+			continue;
+
+		ptep_set_wrprotect(&init_mm, k_cur, ptep);
+	}
+	flush_tlb_mm(&init_mm);
+}
+
+void __init kasan_init(void)
+{
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg) {
+		int ret = kasan_init_region(__va(reg->base), reg->size);
+
+		if (ret)
+			panic("kasan: kasan_init_region() failed");
+	}
+
+	kasan_remap_early_shadow_ro();
+
+	clear_page(kasan_early_shadow_page);
+
+	/* At this point kasan is fully initialized. Enable error messages */
+	init_task.kasan_depth = 0;
+	pr_info("KASAN init done\n");
+}
+
+#ifdef CONFIG_MODULES
+void *module_alloc(unsigned long size)
+{
+	void *base = vmalloc_exec(size);
+
+	if (!base)
+		return NULL;
+
+	if (!kasan_init_region(base, size))
+		return base;
+
+	vfree(base);
+
+	return NULL;
+}
+#endif
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 81f251fc4169..1bb055775e60 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -336,6 +336,10 @@ void __init mem_init(void)
 	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
 		PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
 #endif /* CONFIG_HIGHMEM */
+#ifdef CONFIG_KASAN
+	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
+		KASAN_SHADOW_START, KASAN_SHADOW_END);
+#endif
 #ifdef CONFIG_NOT_COHERENT_CACHE
 	pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
 		IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
diff --git a/arch/powerpc/mm/ptdump/dump_linuxpagetables.c b/arch/powerpc/mm/ptdump/dump_linuxpagetables.c
index b0da447197d4..4a03910974e2 100644
--- a/arch/powerpc/mm/ptdump/dump_linuxpagetables.c
+++ b/arch/powerpc/mm/ptdump/dump_linuxpagetables.c
@@ -94,6 +94,10 @@ static struct addr_marker address_markers[] = {
 	{ 0,	"Consistent mem start" },
 	{ 0,	"Consistent mem end" },
 #endif
+#ifdef CONFIG_KASAN
+	{ 0,	"kasan shadow mem start" },
+	{ 0,	"kasan shadow mem end" },
+#endif
 #ifdef CONFIG_HIGHMEM
 	{ 0,	"Highmem PTEs start" },
 	{ 0,	"Highmem PTEs end" },
@@ -316,6 +320,10 @@ static void populate_markers(void)
 	address_markers[i++].start_address = IOREMAP_TOP +
 					     CONFIG_CONSISTENT_SIZE;
 #endif
+#ifdef CONFIG_KASAN
+	address_markers[i++].start_address = KASAN_SHADOW_START;
+	address_markers[i++].start_address = KASAN_SHADOW_END;
+#endif
 #ifdef CONFIG_HIGHMEM
 	address_markers[i++].start_address = PKMAP_BASE;
 	address_markers[i++].start_address = PKMAP_ADDR(LAST_PKMAP);
diff --git a/arch/powerpc/purgatory/Makefile b/arch/powerpc/purgatory/Makefile
index 4314ba5baf43..7c6d8b14f440 100644
--- a/arch/powerpc/purgatory/Makefile
+++ b/arch/powerpc/purgatory/Makefile
@@ -1,4 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
+
+KASAN_SANITIZE := n
+
 targets += trampoline.o purgatory.ro kexec-purgatory.c
 
 LDFLAGS_purgatory.ro := -e purgatory_start -r --no-undefined
diff --git a/arch/powerpc/xmon/Makefile b/arch/powerpc/xmon/Makefile
index 878f9c1d3615..064f7062c0a3 100644
--- a/arch/powerpc/xmon/Makefile
+++ b/arch/powerpc/xmon/Makefile
@@ -6,6 +6,7 @@ subdir-ccflags-y := $(call cc-disable-warning, builtin-requires-header)
 
 GCOV_PROFILE := n
 UBSAN_SANITIZE := n
+KASAN_SANITIZE := n
 
 # Disable ftrace for the entire directory
 ORIG_CFLAGS := $(KBUILD_CFLAGS)
-- 
2.13.3

