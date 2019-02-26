Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A97C6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6917C2184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="EabuQZ8p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6917C2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14A178E0003; Tue, 26 Feb 2019 12:22:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6F118E000B; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF9DF8E000A; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 514928E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:52 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id q126so710501wme.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
        b=uihn37qX9znCByQwcP8OOQe4wN00vWM0hlevORVMLzjfO5V0/HATrj9324ikKgSrzV
         3GXmOh3g3XGk+jU5fEIs0GjdCSODo4IIQYevJh3zJdiwZNn95MhjQzH6vCuuk5HtlFiM
         Gd6ZPmB79tekMDjCr4yWh6/Q4bs12X8uuubU5v/5icM7oytQy9FV79xa/IrtnNeIfFGu
         ugIoXMncIiltanBUvwi72gIyOiaCBNR6K6H1Ulm6RFgW8ah3vm28vhtHm5M5tMEtFitO
         CmSDQanPbyLs4dO2es03Huk5tOCuvUWSRQOIf4Oj7ZAbB5G8j5sgaqeU4tMRjTg5rMup
         w6ug==
X-Gm-Message-State: AHQUAuZd3KKCcr6pGi/UuJvpSYBWl6nfXLpzUJPnVLfTOzQZBss8tTSo
	iJiR8/p/IeKB2HFm7sL1ZkQRIAyPvVlmidSb2v6Oug6TC7KOOk5P3oe2/8XWtHDFkGLyayd+I/9
	4qqhBRu7aGUncUqhuBFqd9TxTChrwvzR6cV4BBNXmHH1uLUu3mfLArpNV4DN6vwY2yQ==
X-Received: by 2002:a1c:44d7:: with SMTP id r206mr3462068wma.40.1551201771839;
        Tue, 26 Feb 2019 09:22:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpCNN1Kc0U0GDSKTHGIiFABoSvBt3YRFGq6GQliaweHEwiJ4X36Z8zx61MQRrhjyIB7LUg
X-Received: by 2002:a1c:44d7:: with SMTP id r206mr3461996wma.40.1551201770606;
        Tue, 26 Feb 2019 09:22:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201770; cv=none;
        d=google.com; s=arc-20160816;
        b=hyWc+coayy2gzCX6ONE4CgR75qyvZF5zS5SEeNBoO/64Y4x8Q5nYHmJE0lrznseMe/
         aN2RYNwS4oxLO8s5/74OmKiF4Pu/VKOARlopaexV0YgPIwqDMw3Uza7caqVWifEqkFCc
         +u6j6FkRfQxoKQAILIjM6/WYpTDRJ3rvHFc0s3POO87lCuk6nEbx+oirnqhcIcVlzUx6
         PeLfyxDmHMx5Gl64OjmnrPoloH3mS5M1qxwvo78gSId7eViAORCPoDb9A9wj5V5FWJqN
         QgzhtpaKDViYVSeXhbDdhcrqF95Ng4iDgbF82yha9HokCKuWrJ65GhMTm2l92CjD4NJ2
         TnlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
        b=GxSgTGZaH2qerhgJ9SP1UbgS8+RH6AK9KYyAxyo1O9ZtHkAn//xwcUqK1mM9DOHOSK
         ZZ2m/Q73+FcaT4EuuYHM0hh6xJTsPaGxUIDN3ybhhVSTZvfzl1D0Cn6u2MSShlxPZFgX
         QDnIFmSIU6IKo9q9HWHH4Wd74wGhkJ9bo03+nOt5h4G+RgOSxPuaBgWzThNVVz5wX3kr
         +7BTMHHEcjLc2NzBH07fUe6WuIZg/ks1OoCRY7uve6qk/ezYrkzp4QzLr4/RbpeK3kx+
         3ilrx92oTfvXBK33D7XlsR0BGcMTCtrMatsn+4QBGKKtiLfsxTKxGKQj8k75Gk00fUCZ
         kG9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=EabuQZ8p;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id r206si7808417wma.78.2019.02.26.09.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:50 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=EabuQZ8p;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485HD3Bpnz9vJLk;
	Tue, 26 Feb 2019 18:22:48 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=EabuQZ8p; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id fn0bSWVprqoY; Tue, 26 Feb 2019 18:22:48 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485HD279yz9vJLY;
	Tue, 26 Feb 2019 18:22:48 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201768; bh=mcZlyr+Y9QTQOXdd/Np+U2T6LsmbrnCiae9jtlgpNP8=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=EabuQZ8pAOdE2sQleX2t3SsPq1GArv0PjWBeopOvSrOV1zCv5d60OdiVvczorgLNP
	 jO4py2Mf5W3YJsoYrebjgjO6E1nuSIPtrYB/IBVVMhMV8c62eEPDubSNbsGzFVgqt5
	 UEYn+7ZFCuaEBHyLco9QRIwOCXj1Fvrm55L1RO+0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DFF9A8B97A;
	Tue, 26 Feb 2019 18:22:49 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id wP5ytr-hUdni; Tue, 26 Feb 2019 18:22:49 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 95E928B96A;
	Tue, 26 Feb 2019 18:22:49 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 6F6BC6F7A6; Tue, 26 Feb 2019 17:22:49 +0000 (UTC)
Message-Id: <b7437e44dc43e5aff83d0537bb9afb8885f1ce6e.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 08/11] powerpc: disable KASAN instrumentation on
 early/critical files.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:49 +0000 (UTC)
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

