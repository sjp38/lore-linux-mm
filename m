Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 152DCC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA414222CC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NpfP7YMb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA414222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 466C08E0004; Wed, 13 Feb 2019 17:42:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418258E0001; Wed, 13 Feb 2019 17:42:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E04F8E0004; Wed, 13 Feb 2019 17:42:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C70698E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:08 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id a5so1456826wrq.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=cpONfAPk6wUEDmhM/mWi+eIpTzfniRXVZiNB9IzUGPk=;
        b=m56d6Gro/7P+kSbz7Aj8sH1yCrBHgKw32OLEyDPlVHnYdYcFKkpQyBVnXURYTQqvb8
         6VdiWmMIg+05IOn/eN1xuo3j7uELvg8jVP0ej2+VyndlWboXTg9fMYfgyWdvql2/My8w
         SX2lGLyZ2ioGzebCpV26ogiSexqH4U7ALseONNG+lHiIvd4RW3PhrsOcD4JiWZhtdhMN
         2IuCAf8QVaw/RqnZd0KOUpqTLCwjZQWNNcLX8ZYtqRAlzYiVGXSxJKPQlcQWfryyTGo7
         ZC4M9KlpMk5mfOWShCBaT4zzFDYqEVSe0V2lVnCvEExSGPWTl8NrOQPSxwUNKczoLEPv
         pyHw==
X-Gm-Message-State: AHQUAuZOGmWdQQXtbkPRI2Uz6qbZaPIiRAFEFNu5vkDxLeT91CsifuEC
	X118UXgmsVL5EkL9Hs7uU2VJ43okVikfJF9/eyLUyc476zuBHL9LVAq/aPhiRsck2s4Mu0LxFjF
	ae14ovQD05+32VCgVxb7qUNk5pA+DrVpNs1SX2hOnOdFousOg6eJyDEsebSy1TP3YY+DcAXZZqt
	cRMiX+fedke470+bG0UdnqIFoWOWAKyLarkQ73Qs5P0Kx0E2rC38l/vqZH7brLxnlloAcbGGp7e
	QBpvHhw5wOM56ZR3fH21eu4/wEGNSzOUsjMIqDGfgiQAtEPo7/PhgZQIkMJ4MQ3lf5vY85oab2w
	6SSFsXLeBcWXNejDlzId6l6h2MhPqPcsfb9mcgeh2RwaDLQQ3d+BEEb6YZsp3wWKqsvsotITwDd
	V
X-Received: by 2002:a5d:684c:: with SMTP id o12mr307814wrw.27.1550097728257;
        Wed, 13 Feb 2019 14:42:08 -0800 (PST)
X-Received: by 2002:a5d:684c:: with SMTP id o12mr307750wrw.27.1550097726645;
        Wed, 13 Feb 2019 14:42:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097726; cv=none;
        d=google.com; s=arc-20160816;
        b=WB0wSRoiM6AxksyWnbFGnXC5TP0VNise2NujphUuzjcABbAK5lZS6E9gHj2r8RSTkz
         P1kPdiyuijTvbE49+o7OqW6h2KVNvGqfGftsXBMrX2/ZCkaEGShEJ5D4XMkvGAlQCXJn
         Bkb4eE/wNBJVPjsKdfHTWip2qzGkd8evXm7vU/C6eizF/Yx18F/FATS665RFMKdBpSY8
         bsVnIn+GaJx4SkFAYgA+CcfhBjkI2V4Tx6LnugKGQMcBgwo0Q+emzmRCQPyziEmYxPkY
         9OOvmAS0TZCSE/bi2LdNM+OO4xIoknxfzKi0GzgToJN28qfA5qRphfUse6Gb98DBAwXC
         sTgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=cpONfAPk6wUEDmhM/mWi+eIpTzfniRXVZiNB9IzUGPk=;
        b=n7jbLBuf2UAjMq6MEwmvGpKURH1iaip/eE5a46/HxudVJvzDj8/u8E5TKB9jnN/C2V
         qsy+ntEUPqYxiwsx/b+EJ04ySeaILRDOmumLmULKs9wnthSgFkdRpfHQmkL2QphUR2sZ
         B8Bo1stZU9G+QAMofUHN/8ZrI/RKsMHIthASP3P74ly0Eotm4MXZ9Ha8ddzD0cqmjIsW
         DEBRvvy5jYevcoAk/k9mYkB9h9sOwfM57mvbStkwHYV3lTIH45qR1u8x5TW0OoXqYrCk
         24+gdRyIisGeNu/ifh0fRbXmyFxVfAYhmR31xLhLG3a0t3GDvvqDl7+EnWaoUuLP6+uW
         JvOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NpfP7YMb;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12sor382713wrw.18.2019.02.13.14.42.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:06 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NpfP7YMb;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=cpONfAPk6wUEDmhM/mWi+eIpTzfniRXVZiNB9IzUGPk=;
        b=NpfP7YMbJknkb6E3ICzhLie/Ht/jwcXKzMye0lW81///ks6jBgvQ+e/FX0ZxxsCtov
         XKeBVlUVXI+U69qDLw2JRlDtAAIxgmqGtUNJFB8QMih7zWs/OLhYMnqgf2o33qQ3ExWR
         qaMPjJOz7wPhv300bJIAb+8aCIyxfD4C5Bjx/3Nv1UekkxpFvKbXF8pDM04Sk+h1Sjwk
         htAExuZfH2AFo0WF8glM+Tk0+CILfeKZYGKeFfpL95nHs6HWuZXX1RiBuNHXcM2q4NSV
         avo1AoEA1DLXHjvXfXygwMstbZR/DmPOQRkVB/bSl5SRRIFyJ9ryc19c52A/fCUkUuF0
         PYfA==
X-Google-Smtp-Source: AHgI3Ia+VS3rKLWjGclsu+NoPrWW7oZG4FVXw0KNdR0DM973AqQZb9oxD5K7+pvCp25qY/FuXW3lEQ==
X-Received: by 2002:adf:ba8e:: with SMTP id p14mr289178wrg.230.1550097726136;
        Wed, 13 Feb 2019 14:42:06 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:05 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 03/12] __wr_after_init: Core and default arch
Date: Thu, 14 Feb 2019 00:41:32 +0200
Message-Id: <b99f0de701e299b9d25ce8cfffa3387b9687f5fc.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The patch provides:
- the core functionality for write-rare after init for statically
  allocated data, based on code from Matthew Wilcox
- the default implementation for generic architecture
  A specific architecture can override one or more of the default
  functions.

The core (API) functions are:
- wr_memset(): write rare counterpart of memset()
- wr_memcpy(): write rare counterpart of memcpy()
- wr_assign(): write rare counterpart of the assignment ('=') operator
- wr_rcu_assign_pointer(): write rare counterpart of rcu_assign_pointer()

In case either the selected architecture doesn't support write rare
after init, or the functionality is disabled, the write rare functions
will resolve into their non-write rare counterpart:
- memset()
- memcpy()
- assignment operator
- rcu_assign_pointer()

For code that can be either link as module or as built-in (ex: device
driver init function), it is not possible to tell upfront what will be the
case. For this scenario if the functions are called during system init,
they will automatically choose, at runtime, to go through the fast path of
non-write rare. Should they be invoked later, during module init, they
will use the write-rare path.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/Kconfig                |   7 ++
 include/linux/prmem.h (new) |  70 ++++++++++++++
 mm/Makefile                 |   1 +
 mm/prmem.c (new)            | 193 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 271 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index b0b6d176f1c1..0380d4a64681 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -814,6 +814,13 @@ config ARCH_HAS_PRMEM
 	  architecture specific symbol stating that the architecture provides
 	  a back-end function for the write rare operation.
 
+config ARCH_HAS_PRMEM_HEADER
+	def_bool n
+	depends on ARCH_HAS_PRMEM
+	help
+	  architecture specific symbol stating that the architecture provides
+	  own specific header back-end for the write rare operation.
+
 config PRMEM
 	bool "Write protect critical data that doesn't need high write speed."
 	depends on ARCH_HAS_PRMEM
diff --git a/include/linux/prmem.h b/include/linux/prmem.h
new file mode 100644
index 000000000000..05a5e5b3abfd
--- /dev/null
+++ b/include/linux/prmem.h
@@ -0,0 +1,70 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * prmem.h: Header for memory protection library - generic part
+ *
+ * (C) Copyright 2018-2019 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#ifndef _LINUX_PRMEM_H
+#define _LINUX_PRMEM_H
+
+#include <linux/set_memory.h>
+#include <linux/mutex.h>
+#include <linux/mm.h>
+
+#ifndef CONFIG_PRMEM
+
+static inline void *wr_memset(void *p, int c, __kernel_size_t n)
+{
+	return memset(p, c, n);
+}
+
+static inline void *wr_memcpy(void *p, const void *q, __kernel_size_t n)
+{
+	return memcpy(p, q, n);
+}
+
+#define wr_assign(var, val)	((var) = (val))
+#define wr_rcu_assign_pointer(p, v)	rcu_assign_pointer(p, v)
+
+#else
+
+void *wr_memset(void *p, int c, __kernel_size_t n);
+void *wr_memcpy(void *p, const void *q, __kernel_size_t n);
+
+/**
+ * wr_assign() - sets a write-rare variable to a specified value
+ * @var: the variable to set
+ * @val: the new value
+ *
+ * Returns: the variable
+ */
+
+#define wr_assign(dst, val) ({			\
+	typeof(dst) tmp = (typeof(dst))val;	\
+						\
+	wr_memcpy(&dst, &tmp, sizeof(dst));	\
+	dst;					\
+})
+
+/**
+ * wr_rcu_assign_pointer() - initialize a pointer in rcu mode
+ * @p: the rcu pointer - it MUST be aligned to a machine word
+ * @v: the new value
+ *
+ * Returns the value assigned to the rcu pointer.
+ *
+ * It is provided as macro, to match rcu_assign_pointer()
+ * The rcu_assign_pointer() is implemented as equivalent of:
+ *
+ * smp_mb();
+ * WRITE_ONCE();
+ */
+#define wr_rcu_assign_pointer(p, v) ({	\
+	smp_mb();			\
+	wr_assign(p, v);		\
+	p;				\
+})
+#endif
+#endif
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..ef3867c16ce0 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -58,6 +58,7 @@ obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_PRMEM) += prmem.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/prmem.c b/mm/prmem.c
new file mode 100644
index 000000000000..455e1e446260
--- /dev/null
+++ b/mm/prmem.c
@@ -0,0 +1,193 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * prmem.c: Memory Protection Library
+ *
+ * (C) Copyright 2018-2019 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/mmu_context.h>
+#include <linux/uaccess.h>
+
+/*
+ * In case an architecture needs a different declaration of struct
+ * wr_state, it can select ARCH_HAS_PRMEM_HEADER and provide its own
+ * version, accompanied by matching __wr_enable() and __wr_disable()
+ */
+#ifdef CONFIG_ARCH_HAS_PRMEM_HEADER
+#include <asm/prmem.h>
+#else
+
+struct wr_state {
+	struct mm_struct *prev;
+};
+
+#endif
+
+
+__ro_after_init struct mm_struct *wr_mm;
+__ro_after_init unsigned long wr_base;
+
+/*
+ * Default implementation of arch-specific functionality.
+ * Each arch can override the parts that require special handling.
+ */
+unsigned long __init __weak __init_wr_base(void)
+{
+	return 0UL;
+}
+
+void * __weak __wr_addr(void *addr)
+{
+	return (void *)(wr_base + (unsigned long)addr);
+}
+
+void __weak __wr_enable(struct wr_state *state)
+{
+	lockdep_assert_irqs_disabled();
+	state->prev = current->active_mm;
+	switch_mm_irqs_off(NULL, wr_mm, current);
+}
+
+void __weak __wr_disable(struct wr_state *state)
+{
+	lockdep_assert_irqs_disabled();
+	switch_mm_irqs_off(NULL, state->prev, current);
+}
+
+bool __init __weak __wr_map_address(unsigned long addr)
+{
+	spinlock_t *ptl;
+	pte_t pte;
+	pte_t *ptep;
+	unsigned long wr_addr;
+	struct page *page = virt_to_page(addr);
+
+	if (unlikely(!page))
+		return false;
+	wr_addr = (unsigned long)__wr_addr((void *)addr);
+
+	/* The lock is not needed, but avoids open-coding. */
+	ptep = get_locked_pte(wr_mm, wr_addr, &ptl);
+	if (unlikely(!ptep))
+		return false;
+
+	pte = mk_pte(page, PAGE_KERNEL);
+	set_pte_at(wr_mm, wr_addr, ptep, pte);
+	spin_unlock(ptl);
+	return true;
+}
+
+
+#if ((defined(INLINE_COPY_TO_USER) && !defined(memset_user)) || \
+     !defined(INLINE_COPY_TO_USER))
+unsigned long __weak memset_user(void __user *to, int c, unsigned long n)
+{
+	unsigned long i;
+	char b = (char)c;
+
+	for (i = 0; i < n; i++)
+		copy_to_user((void __user *)((unsigned long)to + i), &b, 1);
+	return n;
+}
+#endif
+
+void * __weak __wr_memset(void *p, int c, __kernel_size_t n)
+{
+	return (void *)memset_user((void __user *)p, (u8)c, n);
+}
+
+void * __weak __wr_memcpy(void *p, const void *q, __kernel_size_t n)
+{
+	return (void *)copy_to_user((void __user *)p, q, n);
+}
+
+/*
+ * The following two variables are statically allocated by the linker
+ * script at the boundaries of the memory region (rounded up to
+ * multiples of PAGE_SIZE) reserved for __wr_after_init.
+ */
+extern long __start_wr_after_init;
+extern long __end_wr_after_init;
+static unsigned long start = (unsigned long)&__start_wr_after_init;
+static unsigned long end = (unsigned long)&__end_wr_after_init;
+static inline bool is_wr_after_init(void *p, __kernel_size_t n)
+{
+	unsigned long low = (unsigned long)p;
+	unsigned long high = low + n;
+
+	return likely(start <= low && high <= end);
+}
+
+#define wr_mem_is_writable() (system_state == SYSTEM_BOOTING)
+
+/**
+ * wr_memcpy() - copies n bytes from q to p
+ * @p: beginning of the memory to write to
+ * @q: beginning of the memory to read from
+ * @n: amount of bytes to copy
+ *
+ * Returns pointer to the destination
+ */
+void *wr_memcpy(void *p, const void *q, __kernel_size_t n)
+{
+	struct wr_state state;
+	void *wr_addr;
+
+	if (WARN_ONCE(!is_wr_after_init(p, n), "Invalid WR range."))
+		return p;
+
+	if (unlikely(wr_mem_is_writable()))
+		return memcpy(p, q, n);
+
+	wr_addr = __wr_addr(p);
+	local_irq_disable();
+	__wr_enable(&state);
+	__wr_memcpy(wr_addr, q, n);
+	__wr_disable(&state);
+	local_irq_enable();
+	return p;
+}
+
+/**
+ * wr_memset() - sets n bytes of the destination p to the c value
+ * @p: beginning of the memory to write to
+ * @c: byte to replicate
+ * @n: amount of bytes to copy
+ *
+ * Returns pointer to the destination
+ */
+void *wr_memset(void *p, int c, __kernel_size_t n)
+{
+	struct wr_state state;
+	void *wr_addr;
+
+	if (WARN_ONCE(!is_wr_after_init(p, n), "Invalid WR range."))
+		return p;
+
+	if (unlikely(wr_mem_is_writable()))
+		return memset(p, c, n);
+
+	wr_addr = __wr_addr(p);
+	local_irq_disable();
+	__wr_enable(&state);
+	__wr_memset(wr_addr, c, n);
+	__wr_disable(&state);
+	local_irq_enable();
+	return p;
+}
+
+struct mm_struct *copy_init_mm(void);
+void __init wr_init(void)
+{
+	unsigned long addr;
+
+	wr_mm = copy_init_mm();
+	BUG_ON(!wr_mm);
+
+	wr_base = __init_wr_base();
+
+	/* Create alternate mapping for the entire wr_after_init range. */
+	for (addr = start; addr < end; addr += PAGE_SIZE)
+		BUG_ON(!__wr_map_address(addr));
+}
-- 
2.19.1

