Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5BFDC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86DB0214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o4AsfiwK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86DB0214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 205F68E0192; Mon, 11 Feb 2019 18:28:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B46F8E0189; Mon, 11 Feb 2019 18:28:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07D7A8E0192; Mon, 11 Feb 2019 18:28:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id A92FD8E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:10 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id u74so253216wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=wwet/Q5nK1jaWJoGHMR0JRbL8eZ4TUVn/3KeiBKAqsE=;
        b=HYSnCgv8qSbimZhHsymIr8NNWbhGG4j/E3XGLm748cMpwblyilgJtwS4b4LhdlGlht
         DZqizv+hSTmF/rUvmKAaqZek6QFj5f7Np4UzHn4EnA/ElklpCjKu9y1YPwKEnOo2EBy1
         Vc5lehbmcbZSDMnRaco4r3+zpBSFmx+qroTKcvXQSR3jsPmp9g6Ef/w6ZKLHwxajCpqx
         qhnNaVMHlCdKvO9elczluIfBnmCxifpPzSn6knvWNFEtlfAxmaziKfbp7x/3NDElvl6A
         X+SALTJ76J81Y9/zebIliuhowQftJ0Fqi1GsEexNd1AGpjlgwEaxSvdEvFhf7TDavU2h
         jNcw==
X-Gm-Message-State: AHQUAubiUF/bTvR/IdCa+hP84K2L4eNJ2lvnhX+o0Y0RuBBMBkQp80dw
	5fN6loHPOoLIntNQSbJj24sZNQnrGZqrZ3y6oWwbfJsBbW5b49jxlU+FfI4Ubx/rnpAdoXUewYa
	Glqi2z5b4tYa5XwjcNPM2YInrzM4+PG3+Oyh7dqOp80KOqMIyXCJLcGZ6YYdtrcWm+PaKby+86K
	ElPRIC+aDN3br7cWZvMZW7jP8/+2c0MZPN6S5+93d/CUMzs9ZW3gC1S7oSoMxQxaI4RBYomBagd
	y+TZ2typbDk4zaOXfcyqOdsXnmfYg0i8MMcOR5iRW+rFlh/irdfkCcZ+Ua1uVuYlIP0uFE1rM3K
	Hwcb7ceGHKR2yONcqXWG2znxaqNZQ5+lg2llcZbxszd59lmBpNzyOCui8u5K577M0EjLk5uzxd7
	x
X-Received: by 2002:adf:8224:: with SMTP id 33mr498003wrb.264.1549927690117;
        Mon, 11 Feb 2019 15:28:10 -0800 (PST)
X-Received: by 2002:adf:8224:: with SMTP id 33mr497920wrb.264.1549927688486;
        Mon, 11 Feb 2019 15:28:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927688; cv=none;
        d=google.com; s=arc-20160816;
        b=idXkgOxETwYqdghK74Q0c7Bjnh1Tw0ddHEQONRwCQYP529psjeFealwfPXFt9avLoW
         QhBhBcSTf2hix7y5d0kIInaRDpBZo85+PM/Aza4Hc0VEfZqRNjbk3dp03AHZl1lYJnx6
         +bci+VtNge2ljc5h3+khFu/iXmZXbye5S8n5x9tHrHkUGlcHK6WSJSlWe+IdmxgmB1Xw
         WUxrQsALU2w/h4lWK+vbmvcKYXr6P2f5fNkrEicjwtg6T9NSC/jTgpmGMCs88wfxERj2
         UaIcZWVGQ/vqrTqB6yoyyNaIYBMqqrAk4Dpbt+36Lj8PPo58wjU81RuFnGW4aN9N+os0
         0iRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=wwet/Q5nK1jaWJoGHMR0JRbL8eZ4TUVn/3KeiBKAqsE=;
        b=LXEm7ax8G2PT77oy+FWzAiR6VUKL86D9fwo5QCWQwanUgsCvVoAa2mm0Jj4Lq7s0Wd
         PtNuAAEoO/IQWqjZXwmr8Bk47HjuD9/VcJPRktPoekV2hYUB3IgDTzPqVA1pPjqkoT91
         p/uMiEAYXjE7V32yCwnMjAHH76OvdIzEJP9uo0ZoAf7NPofok3jYAIZO1RdGLFuB6n+Z
         xgqKeVYVi9vMnT5/jHXskRsj9E2sCalBdwXmSNapqa3MXx+8oW1Or4L6+pPGdA/UMBQl
         5jSaBb0Ep+A/G3Q9qNzLVZJgIa9TvJ26R81QXNc0o/6Wrh9r5zCI6cyjbmDW/O7qYh7b
         8tqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o4AsfiwK;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t13sor517463wmt.4.2019.02.11.15.28.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:08 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o4AsfiwK;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=wwet/Q5nK1jaWJoGHMR0JRbL8eZ4TUVn/3KeiBKAqsE=;
        b=o4AsfiwKL8uP6vCfhfBSMLyt0b/8pK4aPNm+I6vX8+5SScqpZX5+KySYVQUQ9LSw3m
         UC5RAPtu6G4auOPaX6osXzHudAhjAJIulwHiEIwhFIkkO4bpFmnhJ824qLXvmoPuBIu/
         uJ32HlSZ16snVWzBDlSHMe8ASTbCBVWviBDnnLU3KnPHPzT2hyQSSwxAUFqHAOj63SlG
         HSenbzVUMUgtTdEvAxNPLWG/+xtF/mO1AoxNMCCFAdUZ8Q6fDvxsq5PNI3ScvnAZ/K2F
         3QKm8n9ikOOzK6GXgMm1V7iXzW33doDJOnDgPcFROIp/M0MvSV5DGzApmVtDUGN/qi8H
         JRcw==
X-Google-Smtp-Source: AHgI3IamOL48gPVRuSSuco75tzIoBaq0tGv6MdC6vEna43DbDNCsUFMY/ZZlKkEsF0xEPZX54CWe8A==
X-Received: by 2002:a1c:96ce:: with SMTP id y197mr536195wmd.36.1549927688025;
        Mon, 11 Feb 2019 15:28:08 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:07 -0800 (PST)
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
Subject: [RFC PATCH v4 01/12] __wr_after_init: Core and default arch
Date: Tue, 12 Feb 2019 01:27:38 +0200
Message-Id: <9d03ef9d09446da2dd92c357aa39af6cd071d7c4.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
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
 include/linux/prmem.h (new) |  71 +++++++++++++++
 mm/Makefile                 |   1 +
 mm/prmem.c (new)            | 179 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 258 insertions(+)

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
index 000000000000..0e4683c503b9
--- /dev/null
+++ b/include/linux/prmem.h
@@ -0,0 +1,71 @@
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
+#include <linux/mm.h>
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
index 000000000000..9383b7d6951e
--- /dev/null
+++ b/mm/prmem.c
@@ -0,0 +1,179 @@
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

