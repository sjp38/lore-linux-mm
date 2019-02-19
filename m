Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CB8BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EC032083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Z2NizKa3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EC032083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E17E78E0006; Tue, 19 Feb 2019 12:23:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75AF8E0002; Tue, 19 Feb 2019 12:23:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC37D8E0006; Tue, 19 Feb 2019 12:23:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 621778E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:15 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id s5so9253664wrp.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=qsRhj0vXokqCATs6bD55xa5yiXGxn2ORcM7fglpoAKM=;
        b=XGlKvF6H0X+sovX6rJE1khOGpqQ9/Xv9kEFwYdANgtpwbZ0iiQKfyHXIt2oOqfYDkc
         0snHkaYPDibxay83WLla2QNc0Cl8rKz1a2YZKgIfVJFAhrzClOBzCGIqcygXpAr+r/j1
         OefUlUuNOsu3PTjmHePd7wWKk55o7F1C8okqWPLtcY6njn0R30KfVgapaZLQS8jV3v0K
         qabis269oMk8bkXjpva9rf8RCe4GXGqDjGzaIB79T99OdCcCaxSYVh44ArZjqLciBfFN
         1CqaKb6tc3C4kIB9NnlU4NHEoe3xzFirAGnNklpbcLpZMpwNWTEyfP8U9MVLFBfgDcTx
         2uRg==
X-Gm-Message-State: AHQUAuaznIuKv5a1p8Xg1mNSzX7pndUqSDQ9buCelTt4yum7pW2IkeTA
	idHY66Kg///kozU8ZjH9PBQ4eIONJNtoGPy2QQb+PfD/vdG0zmu3yFYHZaTTET4VvcTgM1g27yr
	9lIh5v5beZO5M9cvbf+XDbIBtMkR3Z4LfxYJkJKmSU7NxchYbSCIbyx7KRW0TQGp6JQ==
X-Received: by 2002:adf:f487:: with SMTP id l7mr20630740wro.86.1550596994876;
        Tue, 19 Feb 2019 09:23:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZl4SM8lSpLsMr05Cw7kNz+ypyK6unowIjOdWTFDDwiF8sLEdVfdQ6bgiHfsRKat22pYft+
X-Received: by 2002:adf:f487:: with SMTP id l7mr20630682wro.86.1550596993604;
        Tue, 19 Feb 2019 09:23:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596993; cv=none;
        d=google.com; s=arc-20160816;
        b=GfEExaFLFnLFEt9E81+/5nMdFDpS7cOl0aUAeVHYiEAQT0eMdZvt4gfcOfE1CV5Gaw
         rKeG+Wd7kTbIpWShIncOivF2JMar9jxMFE9aF+WCSG0TXOeoK7LLpJEP9qw29CGAL1FE
         CjudVPMshX0xdOWqDxPgdzZy7qLsqYkOX0wxfwW0R/VLd7J8XFBhJEfE0Oma5Srqc+IF
         J72+Zsto9y54R4BOUIkxzo2fUjwc3d/0dxjHXSaMLzwuUO24JIUgFmOgJmi45JVRn/Ay
         n3OueR6Xi9n+r+Ymelil5NXYVjoeUj/ECgpJ460u4ka2DN1Vdrzqj4eHCjxXZYjafWnq
         ni3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=qsRhj0vXokqCATs6bD55xa5yiXGxn2ORcM7fglpoAKM=;
        b=MOepLlxLvren+Vmf4FbcyGfv/yWNcVx0CMywFrmPs9oAiAmsvpdcqtB/DhNoqUg7QW
         wF1CXtzfydnjbHd0NQ0h/z8DKniDlHzBeL8KwnAazKWzgcGDvg38V4CQLNWomNpcJwXM
         EsvgMTD4xgvkmeoDT+sQMbXElhYkUFozD0S6gDiKKycNKbSvvtSTaGCgOEfvg5UW9n6o
         uRnGj+RLXjQc3yK40t79cloJ1mnw7wOQgaCi8I8rWY4Z0zDZY49V0rB7ED3A8qkJr6bk
         zEeOfoq8nUGJDMNIOZx9Zk9GHeEjoE2TC4drWu+gDVcNLYov0NBZt1B0KeRA3lLfugYW
         P9Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Z2NizKa3;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr ([93.17.236.30])
        by mx.google.com with ESMTPS id c8si11570828wrp.231.2019.02.19.09.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:13 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Z2NizKa3;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443ncv2MCnz9v4wm;
	Tue, 19 Feb 2019 18:23:11 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Z2NizKa3; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id GeAwTSXGJhWu; Tue, 19 Feb 2019 18:23:11 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443ncv19Xyz9v4wf;
	Tue, 19 Feb 2019 18:23:11 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596991; bh=qsRhj0vXokqCATs6bD55xa5yiXGxn2ORcM7fglpoAKM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Z2NizKa3yuDfh2pE1+/fIpyRr/azwvHaG3JNm+r3KovQVMXsp7pMSRLqeLHuB1r9n
	 zJ7E4c0RRMi1Vo/lQ6DowJqNR1u0auTNOC0jOjqYWcf1ezy+m0AiXjGrSEoci+tb+5
	 FqvNMe5flGBdHn4dslC2suk2SERroSS/9EBwj/ng=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C8DBC8B7FE;
	Tue, 19 Feb 2019 18:23:12 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 2ysJhypZQCmG; Tue, 19 Feb 2019 18:23:12 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7E3B28B7F9;
	Tue, 19 Feb 2019 18:23:12 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 61E2A6E81D; Tue, 19 Feb 2019 17:23:12 +0000 (UTC)
Message-Id: <303c3f274e7d165b955ba6d23b399e055b6e650f.1550596242.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1550596242.git.christophe.leroy@c-s.fr>
References: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 3/6] powerpc: prepare string/mem functions for KASAN
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_KASAN implements wrappers for memcpy() memmove() and memset()
Those wrappers are doing the verification then call respectively
__memcpy() __memmove() and __memset(). The arches are therefore
expected to rename their optimised functions that way.

For files on which KASAN is inhibited, #defines are used to allow
them to directly call optimised versions of the functions without
going through the KASAN wrappers.

See 393f203f5fd5 ("x86_64: kasan: add interceptors for
memset/memmove/memcpy functions") for details.

Other string / mem functions do not (yet) have kasan wrappers,
we therefore have to fallback to the generic versions when
KASAN is active, otherwise KASAN checks will be skipped.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/kasan.h       | 15 +++++++++++++++
 arch/powerpc/include/asm/string.h      | 26 ++++++++++++++++++++++++--
 arch/powerpc/kernel/prom_init_check.sh | 10 +++++++++-
 arch/powerpc/lib/Makefile              |  8 ++++++--
 arch/powerpc/lib/copy_32.S             | 13 +++++++------
 arch/powerpc/lib/mem_64.S              |  8 ++++----
 arch/powerpc/lib/memcpy_64.S           |  4 ++--
 7 files changed, 67 insertions(+), 17 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h

diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
new file mode 100644
index 000000000000..2efd0e42cfc9
--- /dev/null
+++ b/arch/powerpc/include/asm/kasan.h
@@ -0,0 +1,15 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __ASM_KASAN_H
+#define __ASM_KASAN_H
+
+#ifdef CONFIG_KASAN
+#define _GLOBAL_KASAN(fn)	.weak fn ; _GLOBAL(__##fn) ; _GLOBAL(fn)
+#define _GLOBAL_KASAN_TOC(fn)	.weak fn ; _GLOBAL_TOC(__##fn) ; _GLOBAL_TOC(fn)
+#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(__##fn) ; EXPORT_SYMBOL(fn)
+#else
+#define _GLOBAL_KASAN(fn)	_GLOBAL(fn)
+#define _GLOBAL_KASAN_TOC(fn)	_GLOBAL_TOC(fn)
+#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
+#endif
+
+#endif
diff --git a/arch/powerpc/include/asm/string.h b/arch/powerpc/include/asm/string.h
index 1647de15a31e..2aa9ea6751cd 100644
--- a/arch/powerpc/include/asm/string.h
+++ b/arch/powerpc/include/asm/string.h
@@ -4,13 +4,16 @@
 
 #ifdef __KERNEL__
 
+#ifndef CONFIG_KASAN
 #define __HAVE_ARCH_STRNCPY
 #define __HAVE_ARCH_STRNCMP
+#define __HAVE_ARCH_MEMCHR
+#define __HAVE_ARCH_MEMCMP
+#endif
+
 #define __HAVE_ARCH_MEMSET
 #define __HAVE_ARCH_MEMCPY
 #define __HAVE_ARCH_MEMMOVE
-#define __HAVE_ARCH_MEMCMP
-#define __HAVE_ARCH_MEMCHR
 #define __HAVE_ARCH_MEMSET16
 #define __HAVE_ARCH_MEMCPY_FLUSHCACHE
 
@@ -27,6 +30,25 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
 extern void * memchr(const void *,int,__kernel_size_t);
 extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
 
+void *__memset(void *s, int c, __kernel_size_t count);
+void *__memcpy(void *to, const void *from, __kernel_size_t n);
+void *__memmove(void *to, const void *from, __kernel_size_t n);
+
+#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
+/*
+ * For files that are not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+#define memcpy(dst, src, len) __memcpy(dst, src, len)
+#define memmove(dst, src, len) __memmove(dst, src, len)
+#define memset(s, c, n) __memset(s, c, n)
+
+#ifndef __NO_FORTIFY
+#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
+#endif
+
+#endif
+
 #ifdef CONFIG_PPC64
 #define __HAVE_ARCH_MEMSET32
 #define __HAVE_ARCH_MEMSET64
diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
index 667df97d2595..da6bb16e0876 100644
--- a/arch/powerpc/kernel/prom_init_check.sh
+++ b/arch/powerpc/kernel/prom_init_check.sh
@@ -16,8 +16,16 @@
 # If you really need to reference something from prom_init.o add
 # it to the list below:
 
+grep CONFIG_KASAN=y .config >/dev/null
+if [ $? -eq 0 ]
+then
+	MEMFCT="__memcpy __memset"
+else
+	MEMFCT="memcpy memset"
+fi
+
 WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
-_end enter_prom memcpy memset reloc_offset __secondary_hold
+_end enter_prom $MEMFCT reloc_offset __secondary_hold
 __secondary_hold_acknowledge __secondary_hold_spinloop __start
 strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
 reloc_got2 kernstart_addr memstart_addr linux_banner _stext
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index 3bf9fc6fd36c..ee08a7e1bcdf 100644
--- a/arch/powerpc/lib/Makefile
+++ b/arch/powerpc/lib/Makefile
@@ -8,7 +8,11 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
 
-obj-y += string.o alloc.o code-patching.o feature-fixups.o
+obj-y += alloc.o code-patching.o feature-fixups.o
+
+ifndef CONFIG_KASAN
+obj-y	+=	string.o memcmp_$(BITS).o
+endif
 
 obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
 
@@ -33,7 +37,7 @@ obj64-$(CONFIG_ALTIVEC)	+= vmx-helper.o
 obj64-$(CONFIG_KPROBES_SANITY_TEST) += test_emulate_step.o
 
 obj-y			+= checksum_$(BITS).o checksum_wrappers.o \
-			   string_$(BITS).o memcmp_$(BITS).o
+			   string_$(BITS).o
 
 obj-y			+= sstep.o ldstfp.o quad.o
 obj64-y			+= quad.o
diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
index ba66846fe973..57f48d99fbe3 100644
--- a/arch/powerpc/lib/copy_32.S
+++ b/arch/powerpc/lib/copy_32.S
@@ -14,6 +14,7 @@
 #include <asm/ppc_asm.h>
 #include <asm/export.h>
 #include <asm/code-patching-asm.h>
+#include <asm/kasan.h>
 
 #define COPY_16_BYTES		\
 	lwz	r7,4(r4);	\
@@ -91,7 +92,7 @@ EXPORT_SYMBOL(memset16)
  * We therefore skip the optimised bloc that uses dcbz. This jump is
  * replaced by a nop once cache is active. This is done in machine_init()
  */
-_GLOBAL(memset)
+_GLOBAL_KASAN(memset)
 	cmplwi	0,r5,4
 	blt	7f
 
@@ -150,7 +151,7 @@ _GLOBAL(memset)
 9:	stbu	r4,1(r6)
 	bdnz	9b
 	blr
-EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL_KASAN(memset)
 
 /*
  * This version uses dcbz on the complete cache lines in the
@@ -163,12 +164,12 @@ EXPORT_SYMBOL(memset)
  * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
  * replaced by a nop once cache is active. This is done in machine_init()
  */
-_GLOBAL(memmove)
+_GLOBAL_KASAN(memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	/* fall through */
 
-_GLOBAL(memcpy)
+_GLOBAL_KASAN(memcpy)
 1:	b	generic_memcpy
 	patch_site	1b, patch__memcpy_nocache
 
@@ -242,8 +243,8 @@ _GLOBAL(memcpy)
 	stbu	r0,1(r6)
 	bdnz	40b
 65:	blr
-EXPORT_SYMBOL(memcpy)
-EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL_KASAN(memcpy)
+EXPORT_SYMBOL_KASAN(memmove)
 
 generic_memcpy:
 	srwi.	r7,r5,3
diff --git a/arch/powerpc/lib/mem_64.S b/arch/powerpc/lib/mem_64.S
index 3c3be02f33b7..57c8a940c29c 100644
--- a/arch/powerpc/lib/mem_64.S
+++ b/arch/powerpc/lib/mem_64.S
@@ -30,7 +30,7 @@ EXPORT_SYMBOL(__memset16)
 EXPORT_SYMBOL(__memset32)
 EXPORT_SYMBOL(__memset64)
 
-_GLOBAL(memset)
+_GLOBAL_KASAN(memset)
 	neg	r0,r3
 	rlwimi	r4,r4,8,16,23
 	andi.	r0,r0,7			/* # bytes to be 8-byte aligned */
@@ -95,9 +95,9 @@ _GLOBAL(memset)
 10:	bflr	31
 	stb	r4,0(r6)
 	blr
-EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL_KASAN(memset)
 
-_GLOBAL_TOC(memmove)
+_GLOBAL_TOC_KASAN(memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	b	memcpy
@@ -138,4 +138,4 @@ _GLOBAL(backwards_memcpy)
 	beq	2b
 	mtctr	r7
 	b	1b
-EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL_KASAN(memmove)
diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index 273ea67e60a1..2d5358cee711 100644
--- a/arch/powerpc/lib/memcpy_64.S
+++ b/arch/powerpc/lib/memcpy_64.S
@@ -18,7 +18,7 @@
 #endif
 
 	.align	7
-_GLOBAL_TOC(memcpy)
+_GLOBAL_TOC_KASAN(memcpy)
 BEGIN_FTR_SECTION
 #ifdef __LITTLE_ENDIAN__
 	cmpdi	cr7,r5,0
@@ -229,4 +229,4 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
 4:	ld	r3,-STACKFRAMESIZE+STK_REG(R31)(r1)	/* return dest pointer */
 	blr
 #endif
-EXPORT_SYMBOL(memcpy)
+EXPORT_SYMBOL_KASAN(memcpy)
-- 
2.13.3

