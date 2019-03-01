Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B003CC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FE82206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="B9i7cTo9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FE82206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 406948E000B; Fri,  1 Mar 2019 07:33:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2560D8E0006; Fri,  1 Mar 2019 07:33:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 034B18E000B; Fri,  1 Mar 2019 07:33:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 946248E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:49 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id m2so8694592wrs.23
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
        b=qHjQFcVVeHru2fhC+8/drufp5sE6iQINuf1wThf57+ODAjmBj+tSYN536Qtl6LNb3y
         XSvcB48XbMU6VhTftLycgt0xgeQEMxlWjnZ/5FgHIo6POodxmSfZI4g2UcUtJSVzj9/2
         nqVQm+8iM0yBZLXiiS9RGv4AFGF/EkcjUizurfw51Q0RzjnJxJnWYQc5zoDDWALuk+q9
         GO+m+YncY96ie25LMRiKwj2MF2kh1oy+ZfGZ6sVed0QL4vzyc6junCkH2TLVOAKCavA5
         /g/ixhssgDqmWc6kw4PbCJlzmQDVQKwklbZcazaAN45gjGZUrn4brBxUMQEx8yWkCznB
         n9nA==
X-Gm-Message-State: AHQUAuYwQETlBGPhBNjQElm+nmC8A/mqYtL9oQ4r0m0bSSgQUWgIT4ZF
	NG/Se1Sk4SuWgC4N8JIgWC3qpk1OBbnaMvtpAA+IEYa83ck66s/sAtTMooDDL+xwSJjELWBwyIW
	HZDxRrtNwoclJ9IF0PbrFgaiZHRngx5DMm9Sc46Bt30YX02dOKoJj2TIpii6tSPGXMw==
X-Received: by 2002:a1c:6789:: with SMTP id b131mr3031699wmc.22.1551443629078;
        Fri, 01 Mar 2019 04:33:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3v7dc+XIBgs+a84yUDoCPBDthtzAzmzuG+4Lu7PR1WjJCYPvQnRrY9CGJYzH4GsOlLZeG
X-Received: by 2002:a1c:6789:: with SMTP id b131mr3031649wmc.22.1551443627927;
        Fri, 01 Mar 2019 04:33:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443627; cv=none;
        d=google.com; s=arc-20160816;
        b=CPrsOJF+gZfNkAdOrve5VXGcnIdxcB/H3P56p21seNxA9B8NYo01VuPYD2pbqlf00N
         IQ/sxLzHB8N8hn2oOdqL3Smyk5hu1qM56XrWdK7BMc5+wN4fbzEXCRw3lXgX550lYW2c
         bRc/Sh545DytBU8rnNDBhs2GWuvE5W+2yL5KVKXwFEXQRcJstwYrfmXmLSB5tLvwbv17
         CAcO0lqeVQZn3nvSoPLSk2Au53UpRkuWAHey0mVgJMgudn5G4qmbTGbEjJOV+FawMwCm
         NGbbw7WENJmQY+7a9OrRtvAc0uDc0rR1FkoyiVp3QAdwJphsx/1/k5GSezwd7fNg4hFn
         yGvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
        b=YC8QjPOTkbL1OhCTp3P0B5xxS7hW/gZJLRV1XQtIZ7+UCK95gCrObsj892217MClr8
         md7x39zU5SDx3k54xnMxXaUvLGQaWu3G4932i+m4dVQsd3WyZT41VvqGeiIcx9pGR2zh
         wmI5SLgpe2RTQpvr6NU7cPJs8RSDRLRz4j5SvsZk4mV8awwTdvPMPpT/HB5UYWCs/tmK
         R402eUrqtAyUrHgWE7WyltYRVyYV1HqUG0RSeP0w9uM3FthOCU1HsQ9ChGRKWPzC9iqt
         TcNG7r1Y/SX9YzUq+pOFhxDUQC/ZaLfft/qjrDyEFcX/JobyGZ8KUm4zLDVhIMy3YB5v
         XU1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=B9i7cTo9;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l8si4603943wmg.93.2019.03.01.04.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:47 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=B9i7cTo9;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkK4h0Nz9txrt;
	Fri,  1 Mar 2019 13:33:45 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=B9i7cTo9; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id gtSNb2Sq3_YU; Fri,  1 Mar 2019 13:33:45 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkK38xRz9txrh;
	Fri,  1 Mar 2019 13:33:45 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443625; bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=B9i7cTo9rS8TkSt0I214ItZD0m0vcWhi5DjUC6rSiTgM6kGUuRqME2MNr3FLS2kT0
	 I5GUiUeB7dTCeCOZQbF3B5K7ESQ+NppKo7RsxxePDMF5EIZ/rKTu8bTyN4wJM5oflH
	 +NsIxKGY5b3h6MdbpJ6woa4bqmSu6SZaOjshgMwA=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B3A1F8BB8B;
	Fri,  1 Mar 2019 13:33:46 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id OwCpOqwk-QtK; Fri,  1 Mar 2019 13:33:46 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7405A8BB73;
	Fri,  1 Mar 2019 13:33:46 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 4F0206F89E; Fri,  1 Mar 2019 12:33:46 +0000 (UTC)
Message-Id: <2adea63caf38d51f6cfc5b98906c6a3c05f0b8d3.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 08/11] powerpc: disable KASAN instrumentation on
 early/critical files.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:46 +0000 (UTC)
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
index 923bfb340433..859efbacdf06 100644
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

