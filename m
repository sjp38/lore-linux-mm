Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4518EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E822D213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ShTvJkas"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E822D213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF6648E000D; Tue, 12 Mar 2019 18:16:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA82D8E0008; Tue, 12 Mar 2019 18:16:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 947118E000D; Tue, 12 Mar 2019 18:16:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 370018E0008
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:19 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id l1so1604659wrn.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=11bHr9IKG31q/XWzTWTlzmha5VK7c1KEPDFWV7Md6Q0=;
        b=nq3PWj8mdak4U4C/Q/jkf2E85UKHzCLzuCu1i1PO44Qdg5+Oxz8AbV5Q9wMt+2jShg
         Uot8Kaq1ljaIfpRuSVIbcSk0YPNIv0rvybuvVk79X9wjN7QJULjCjfafUG1ebj61xVw7
         cxEe8ZeH7ePzfSKDwJsEAJiZaRn+FrO4M/gOSlGE8hjsNp0HkPlHaQFWKrMDDAKkF5WV
         zIimkt7akir1oU3s5JPPTMF3D8eKsg5vZNHafbIm1PLKpvFdVtQrcmwV6FaoxJyj6WMP
         jdo6LW+V4jmwvHAYtSPqa2A9egAW8GwV63O2QHm6EwsoX6z2B1ehfDYA1zlawz3HYnNt
         P0Iw==
X-Gm-Message-State: APjAAAUkWgEZORF0ZxtSMbG7zUy39UcsXf9BG2lVxe2wQjwZIai4s8+a
	GV+KQIL+5Uw+QEO/3GN9DX/ypwgsklPC4uFD6q0Fncg9tIhqA7Nj3FTuxuLXo4xU89wJaU8PrsW
	1KIwa9kBnfElYfXWivJ8GOedPYoK+dYgDJbgkGeCCUJlPUJEL0YZ/DiMThqhp2sOTSg==
X-Received: by 2002:a7b:c932:: with SMTP id h18mr39098wml.12.1552428978446;
        Tue, 12 Mar 2019 15:16:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMtGNAA2xcciwT7MAA7tUIp05UHH7WuVdtfaJrjQ0N+gu+0vJeITqVMC+PY4FIKBM6qlz6
X-Received: by 2002:a7b:c932:: with SMTP id h18mr39062wml.12.1552428977056;
        Tue, 12 Mar 2019 15:16:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428977; cv=none;
        d=google.com; s=arc-20160816;
        b=kfoyvDTXvKJhA3yMmcMDOTPsC7IN24cv3gRvCs1Vy19njS1PeUw4vcHDbxpez1ClcC
         y0H/WdqZo5FMReGyr6Ws+sSlxGphx4imrl2zVawtJ11i6pRBShStL6fiKhfrL/ZcfWmg
         3zFuhrX44BJ+QkeFuYsBEADP4nRuHS3JjD8LkiTH9242ejxsPUIdkXkQU5b/2DO5uSeg
         u5wBVnq7kx3jpFzXDmrAb98QgJh8mEsUYwnoS2EKz8bkPIGYgBKgy2HQgqFx1E/rEj4j
         59hR01XtwD4gfqqMz4sgFkHpggrPbLRMLAAb1mQ1cCUFBxKhe0V45LQkB8rMv1QRr46y
         nLfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=11bHr9IKG31q/XWzTWTlzmha5VK7c1KEPDFWV7Md6Q0=;
        b=Qb6d7wRilBoWFNjOOetPx9wkWOyDESWKzQT+6Q/WWFOYU3s4l3cWacIE9Rg3Ht/Wup
         iSIfAzZloALrNLQUIxgOb7yFxSb6GQOr3IIT9KvfBx0PIrPzMKiYOlcO/vnzhZ1vKBPy
         tFyb6S72x1Y5MJ2J+MLsR8MmauEHFgHdy63PnruhmDHjmFJKhoC+HRODuILyl2TUA2SH
         m7HDyBzu+Wu6Evt4AyPaLx9w5/xqOviGNjdOTmaLbF8xKquamJpd9iAH5ZUFwOftIDdF
         qc3tfV1sSHzrarBaDOujxYddtDpmrKxqokmPaCGmfSrP0xWA6m3t2JwMomWpNsd4PMYn
         4JCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ShTvJkas;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x6si6202622wrm.149.2019.03.12.15.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ShTvJkas;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7N37jnzB09Zw;
	Tue, 12 Mar 2019 23:16:16 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ShTvJkas; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id nO-H_kZuUfG0; Tue, 12 Mar 2019 23:16:16 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7N21M6zB09ZG;
	Tue, 12 Mar 2019 23:16:16 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428976; bh=11bHr9IKG31q/XWzTWTlzmha5VK7c1KEPDFWV7Md6Q0=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ShTvJkas3sbdAPGOOgR4IJbXIwO0eALyh2u7kydGhCHX6K+1JC/cF7QNbOqO9nRZY
	 qbCdhiuDrUQIvYQEqUZJnqPbwTIPvi8SGtSK1j1zIqIVpcco6RUINZH/YV9/wMHbXx
	 jhJHu9vNHojN5sr1tQN8Ej48rg6bkaui//mP/364=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7CBA28B8B1;
	Tue, 12 Mar 2019 23:16:16 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id V9B0UOowRjR1; Tue, 12 Mar 2019 23:16:16 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 41F1B8B8A7;
	Tue, 12 Mar 2019 23:16:16 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id E0BA96FA15; Tue, 12 Mar 2019 22:16:15 +0000 (UTC)
Message-Id: <759c1323282930614b105d72b3ae459398125478.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 10/18] powerpc: disable KASAN instrumentation on
 early/critical files.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All files containing functions run before kasan_early_init() is called
must have KASAN instrumentation disabled.

For those file, branch profiling also have to be disabled otherwise
each if () generates a call to ftrace_likely_update().

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile             | 12 ++++++++++++
 arch/powerpc/lib/Makefile                |  8 ++++++++
 arch/powerpc/mm/Makefile                 |  6 ++++++
 arch/powerpc/platforms/powermac/Makefile |  6 ++++++
 arch/powerpc/purgatory/Makefile          |  3 +++
 arch/powerpc/xmon/Makefile               |  1 +
 6 files changed, 36 insertions(+)

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 45e47752b692..0ea6c4aa3a20 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -31,6 +31,18 @@ CFLAGS_REMOVE_btext.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_prom.o = $(CC_FLAGS_FTRACE)
 endif
 
+KASAN_SANITIZE_early_32.o := n
+KASAN_SANITIZE_cputable.o := n
+KASAN_SANITIZE_prom_init.o := n
+KASAN_SANITIZE_btext.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_cputable.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_prom_init.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_btext.o += -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y				:= cputable.o ptrace.o syscalls.o \
 				   irq.o align.o signal_32.o pmc.o vdso.o \
 				   process.o systbl.o idle.o \
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index 47a4de434c22..c55f9c27bf79 100644
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
index d52ec118e09d..240d73dce6bb 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -7,6 +7,12 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 
 CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
 
+KASAN_SANITIZE_ppc_mmu_32.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_ppc_mmu_32.o  		+= -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y				:= fault.o mem.o pgtable.o mmap.o \
 				   init_$(BITS).o pgtable_$(BITS).o \
 				   init-common.o mmu_context.o drmem.o
diff --git a/arch/powerpc/platforms/powermac/Makefile b/arch/powerpc/platforms/powermac/Makefile
index 20ebf35d7913..f4247ade71ca 100644
--- a/arch/powerpc/platforms/powermac/Makefile
+++ b/arch/powerpc/platforms/powermac/Makefile
@@ -2,6 +2,12 @@
 CFLAGS_bootx_init.o  		+= -fPIC
 CFLAGS_bootx_init.o  		+= $(call cc-option, -fno-stack-protector)
 
+KASAN_SANITIZE_bootx_init.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_bootx_init.o  		+= -DDISABLE_BRANCH_PROFILING
+endif
+
 ifdef CONFIG_FUNCTION_TRACER
 # Do not trace early boot code
 CFLAGS_REMOVE_bootx_init.o = $(CC_FLAGS_FTRACE)
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
index 3050f9323254..f142570ad860 100644
--- a/arch/powerpc/xmon/Makefile
+++ b/arch/powerpc/xmon/Makefile
@@ -7,6 +7,7 @@ subdir-ccflags-y := $(call cc-disable-warning, builtin-requires-header)
 GCOV_PROFILE := n
 KCOV_INSTRUMENT := n
 UBSAN_SANITIZE := n
+KASAN_SANITIZE := n
 
 # Disable ftrace for the entire directory
 ORIG_CFLAGS := $(KBUILD_CFLAGS)
-- 
2.13.3

