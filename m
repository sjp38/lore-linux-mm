Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 793E2C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:22:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 276A720B7C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:22:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 276A720B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C97116B000A; Thu,  8 Aug 2019 02:22:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C22CC6B000D; Thu,  8 Aug 2019 02:22:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2526B000E; Thu,  8 Aug 2019 02:22:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 576A96B000A
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:22:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so57584565edv.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:22:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Szq2k/KYa8HGh/lZff135xvtiKuOQoIRwWhZZ6kmXYk=;
        b=lSXxGC/iJ+pWz3MeJZD5CgUIbpngMr2JbCbR3MKnuVFosCdqM9/gjbg+pR/k2vmswL
         lM4DzDUknCzbqlfh+HhzNh7sZYINWknExixwqs/+uE+S2Hov2/DMNWYG9wKCK12cPcdb
         9GiW+QbEfutK0pFhuLg1VfEaQ43zacdgm9cNFo3cHkqM3gjbLyR2aIR7tz6QcCxM90yF
         o0zYtBBZ//cqBy2DfQYDhchHeJvQznHPAZ2AtEAhBQOtIewIiIzX1xBlcxpJDY8xbsym
         K/8Be5JqqOq2wWO1E8ad/AWsViA27BkwC2FMWGlBGBv4/Ie3Sp/Nuy1a88H7wm1x8/W9
         Gc/w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV6cSrfL+mpQK277QLrI0tJ8i/lp+KsCom6+F/0z8W3VLKNIj79
	kzSSnIiQTCCKencu7uA/9iyTdNIrhZo4hKPpMJW2vy2PNiXeBHrum13EBYCKxaQpi85fxU0WGVt
	XlG9FFclnEw8Uy1/bowdudczpCC98d7nRuIrC3ddZLKeIn3ToSbFQCZEMIlLbmNg=
X-Received: by 2002:aa7:d909:: with SMTP id a9mr14007485edr.261.1565245351902;
        Wed, 07 Aug 2019 23:22:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJk88my6eIkofjzwnUbeYpd4ZK9dxeraeXQsKiWoJAWXbyd9FVIkbjfLX8rsXe1YZpVZ9N
X-Received: by 2002:aa7:d909:: with SMTP id a9mr14007412edr.261.1565245350753;
        Wed, 07 Aug 2019 23:22:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245350; cv=none;
        d=google.com; s=arc-20160816;
        b=AznDSzZq8Xi4F4+SKMdxzHopRO9ixTGIjoF8ghNpaK/YqJMXwByaur25j1joBv9Y3z
         F7AbTMdusjsktrT7tRPZ433lm6GCTbbkJ+uA7R4N2dYu+0ff+mJ5tDswBQsIAVFAdPS1
         LBLyRzae4wYBITc+GeSu+Vtk4bU9ZS9C2JFYC+TOvP24GOdvyXPLHNDaXxTZmo6QHOMR
         /b5GLp2tyQQoiEJXDxcM0+Ll2rnyCAMu84QI6r1EgCfeTKZ5aw+iasxLkYUWWHAuSbC9
         qB3TjIvm8zj3422KnsffoKaCQQMWNDt9ddzzhr1AamkJyuw7++8EoI0oGEQGznmdsJzZ
         BIhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Szq2k/KYa8HGh/lZff135xvtiKuOQoIRwWhZZ6kmXYk=;
        b=NAcc8StuYEUHfyi73FuX6A92L8sryVbcrSFP2WKts9tcikrjNmMpKXk0OtDe/rQs7B
         r7NlAwImVjjPKxrgKHo2Y4JTO7fwLpTVE/aOKlnPwKhapN3llHd/VwtWKI4+PXOAK/ZT
         R00kTzOJKxmDm9X5CaXPEQpKOkDcNFfMQZkeS/lUOKkZvScd7FNgdXnNdzrRlnM8lYur
         ztlpxPVYtY9zeEJRjn2jy0BRPN6ZiNQQ9GHEP5fHgzr0/1sBYKjPjdXN/JpbbbrTxk95
         acl7Dx6NWmodLSKMKFF179bsS3LsOA5srVXGtJC/GiX87irQSndrY33GV18AYJL5tIW6
         EiNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id i3si33668736eda.107.2019.08.07.23.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:22:30 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 96B1260002;
	Thu,  8 Aug 2019 06:22:25 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v6 04/14] arm64, mm: Move generic mmap layout functions to mm
Date: Thu,  8 Aug 2019 02:17:46 -0400
Message-Id: <20190808061756.19712-5-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

arm64 handles top-down mmap layout in a way that can be easily reused
by other architectures, so make it available in mm.

It then introduces a new config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
that can be set by other architectures to benefit from those functions.
Note that this new config depends on MMU being enabled, if selected
without MMU support, a warning will be thrown.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/Kconfig                       | 10 ++++
 arch/arm64/Kconfig                 |  1 +
 arch/arm64/include/asm/processor.h |  2 -
 arch/arm64/mm/mmap.c               | 76 -----------------------------
 kernel/sysctl.c                    |  6 ++-
 mm/util.c                          | 78 +++++++++++++++++++++++++++++-
 6 files changed, 92 insertions(+), 81 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index a7b57dd42c26..a0bb6fa4d381 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -696,6 +696,16 @@ config HAVE_ARCH_COMPAT_MMAP_BASES
 	  and vice-versa 32-bit applications to call 64-bit mmap().
 	  Required for applications doing different bitness syscalls.
 
+# This allows to use a set of generic functions to determine mmap base
+# address by giving priority to top-down scheme only if the process
+# is not in legacy mode (compat task, unlimited stack size or
+# sysctl_legacy_va_layout).
+# Architecture that selects this option can provide its own version of:
+# - STACK_RND_MASK
+config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
+	bool
+	depends on MMU
+
 config HAVE_COPY_THREAD_TLS
 	bool
 	help
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..14a194e63458 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -72,6 +72,7 @@ config ARM64
 	select ARCH_SUPPORTS_INT128 if GCC_VERSION >= 50000 || CC_IS_CLANG
 	select ARCH_SUPPORTS_NUMA_BALANCING
 	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION if COMPAT
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 	select ARCH_WANT_FRAME_POINTERS
 	select ARCH_WANT_HUGE_PMD_SHARE if ARM64_4K_PAGES || (ARM64_16K_PAGES && !ARM64_VA_BITS_36)
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 844e2964b0f5..65e2de00913f 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -281,8 +281,6 @@ static inline void spin_lock_prefetch(const void *ptr)
 		     "nop") : : "p" (ptr));
 }
 
-#define HAVE_ARCH_PICK_MMAP_LAYOUT
-
 #endif
 
 extern unsigned long __ro_after_init signal_minsigstksz; /* sigframe size */
diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index e4acaead67de..3028bacbc4e9 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -20,82 +20,6 @@
 
 #include <asm/cputype.h>
 
-/*
- * Leave enough space between the mmap area and the stack to honour ulimit in
- * the face of randomisation.
- */
-#define MIN_GAP (SZ_128M)
-#define MAX_GAP	(STACK_TOP/6*5)
-
-static int mmap_is_legacy(struct rlimit *rlim_stack)
-{
-	if (current->personality & ADDR_COMPAT_LAYOUT)
-		return 1;
-
-	if (rlim_stack->rlim_cur == RLIM_INFINITY)
-		return 1;
-
-	return sysctl_legacy_va_layout;
-}
-
-unsigned long arch_mmap_rnd(void)
-{
-	unsigned long rnd;
-
-#ifdef CONFIG_COMPAT
-	if (is_compat_task())
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-	else
-#endif
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-	return rnd << PAGE_SHIFT;
-}
-
-static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
-{
-	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = stack_guard_gap;
-
-	/* Account for stack randomization if necessary */
-	if (current->flags & PF_RANDOMIZE)
-		pad += (STACK_RND_MASK << PAGE_SHIFT);
-
-	/* Values close to RLIM_INFINITY can overflow. */
-	if (gap + pad > gap)
-		gap += pad;
-
-	if (gap < MIN_GAP)
-		gap = MIN_GAP;
-	else if (gap > MAX_GAP)
-		gap = MAX_GAP;
-
-	return PAGE_ALIGN(STACK_TOP - gap - rnd);
-}
-
-/*
- * This function, called very early during the creation of a new process VM
- * image, sets up which VM layout function to use:
- */
-void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
-{
-	unsigned long random_factor = 0UL;
-
-	if (current->flags & PF_RANDOMIZE)
-		random_factor = arch_mmap_rnd();
-
-	/*
-	 * Fall back to the standard layout if the personality bit is set, or
-	 * if the expected stack growth is unlimited:
-	 */
-	if (mmap_is_legacy(rlim_stack)) {
-		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
-		mm->get_unmapped_area = arch_get_unmapped_area;
-	} else {
-		mm->mmap_base = mmap_base(random_factor, rlim_stack);
-		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
-	}
-}
-
 /*
  * You really shouldn't be using read() or write() on /dev/mem.  This might go
  * away in the future.
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 078950d9605b..00fcea236eba 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -264,7 +264,8 @@ extern struct ctl_table epoll_table[];
 extern struct ctl_table firmware_config_table[];
 #endif
 
-#ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
+#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
+    defined(CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
 int sysctl_legacy_va_layout;
 #endif
 
@@ -1573,7 +1574,8 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 		.extra1		= SYSCTL_ZERO,
 	},
-#ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
+#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
+    defined(CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
 	{
 		.procname	= "legacy_va_layout",
 		.data		= &sysctl_legacy_va_layout,
diff --git a/mm/util.c b/mm/util.c
index 15a4fb0f5473..0781e5575cb3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -17,7 +17,12 @@
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/elf.h>
+#include <linux/elf-randomize.h>
+#include <linux/personality.h>
 #include <linux/random.h>
+#include <linux/processor.h>
+#include <linux/sizes.h>
+#include <linux/compat.h>
 
 #include <linux/uaccess.h>
 
@@ -315,7 +320,78 @@ unsigned long randomize_stack_top(unsigned long stack_top)
 #endif
 }
 
-#if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
+#ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
+#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
+unsigned long arch_mmap_rnd(void)
+{
+	unsigned long rnd;
+
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
+	if (is_compat_task())
+		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
+	else
+#endif /* CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS */
+		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
+
+	return rnd << PAGE_SHIFT;
+}
+#endif /* CONFIG_ARCH_HAS_ELF_RANDOMIZE */
+
+static int mmap_is_legacy(struct rlimit *rlim_stack)
+{
+	if (current->personality & ADDR_COMPAT_LAYOUT)
+		return 1;
+
+	if (rlim_stack->rlim_cur == RLIM_INFINITY)
+		return 1;
+
+	return sysctl_legacy_va_layout;
+}
+
+/*
+ * Leave enough space between the mmap area and the stack to honour ulimit in
+ * the face of randomisation.
+ */
+#define MIN_GAP		(SZ_128M)
+#define MAX_GAP		(STACK_TOP / 6 * 5)
+
+static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
+{
+	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
+
+	if (gap < MIN_GAP)
+		gap = MIN_GAP;
+	else if (gap > MAX_GAP)
+		gap = MAX_GAP;
+
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
+}
+
+void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
+{
+	unsigned long random_factor = 0UL;
+
+	if (current->flags & PF_RANDOMIZE)
+		random_factor = arch_mmap_rnd();
+
+	if (mmap_is_legacy(rlim_stack)) {
+		mm->mmap_base = TASK_UNMAPPED_BASE + random_factor;
+		mm->get_unmapped_area = arch_get_unmapped_area;
+	} else {
+		mm->mmap_base = mmap_base(random_factor, rlim_stack);
+		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
+	}
+}
+#elif defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
 void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
 	mm->mmap_base = TASK_UNMAPPED_BASE;
-- 
2.20.1

