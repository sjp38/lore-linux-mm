Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A2BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465E6206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="aaexGiu/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465E6206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D01C38E000C; Fri,  1 Mar 2019 07:33:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB1B18E0006; Fri,  1 Mar 2019 07:33:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB6C18E000C; Fri,  1 Mar 2019 07:33:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0BF8E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:51 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z16so11517486wrt.0
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=oMzap2j2bfc5OfrfewmFoolVJdX1DDnl6sy2Y4MlHOE=;
        b=CHsQxLItiuJw0Rl4aydw4WkRQoyLX4AM6/8l6yndl3G0+2yQ8Dtg/8AU83/lXb+73Z
         68BgoYN7/2/FVI1xdx7Yuo7wdeOuRrQK2159zg78me9lNr7/l8XH7EEXYTksMozRqb3O
         XBA5G8glvqfhY5hgtPgak1Z/Kddzh9l3ZeeP0pteeXE/qUe3jbigM6HJ63QZEUzhQNV+
         VVziku5s5L/bgE9N7mc92ONof7nVwGoy3Cu2k58/ttsXVZJBvlf+KcNvHxbnpTyiSrbC
         twKQSQWKTz+wkFjL9QtqBf/W5rh5oTEUmUh2Hnjf9/j+Wd3l8BkM5eXJm1zZGKyGnjNj
         tS2w==
X-Gm-Message-State: APjAAAWXf7zgzSnKrt7Sc0LWxbXg3S7Ca/EImPRSkpTCQR8hVGcYscBz
	9qb6DVvXyIYsFEEUZStk00O5SN2frhNvimyfH5fozTxbIaqvvEAkdrtEMsLC1tVC6P4kEiD59su
	3PwQbD86LrYVtUtsI7hWsTQLKccgcmrWFz1KyrpckLl5wxJtxzbPj17R9J4ixQ4nDJQ==
X-Received: by 2002:adf:f786:: with SMTP id q6mr3122570wrp.125.1551443630781;
        Fri, 01 Mar 2019 04:33:50 -0800 (PST)
X-Google-Smtp-Source: APXvYqw1G9nZ6/tBjzFgqkEifW83uvHNYzWi3KNCe3TPes39caKT8UptgBYhwrnbxIl8zWcZsJFo
X-Received: by 2002:adf:f786:: with SMTP id q6mr3122484wrp.125.1551443628965;
        Fri, 01 Mar 2019 04:33:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443628; cv=none;
        d=google.com; s=arc-20160816;
        b=jhxfmjDpH7/vdzmbH0eaVr5Uvv332GyDITKF3vnwSP7LWRg0WtUyqqcAOk1XVrBY1Z
         jqPpwjGR4OhgZbRZeIS6WwNNsgnI5RUS/VhJE4GmwRva7vRoU0Z73rx6le/a3JiY71Vb
         0OBFOs2/A7by/x56MkkzqY7Uh3RRVsWk6NdVmCTFh/27huIA65Mu4T/0YvEYAhtEcNPp
         uFp21SsxCVlilJ6RavwbBwqpoqKmshrg7a+eXmhEAiHvd1weMu7OJUYUA8dzegFuWAlz
         PWcZEV2Pp+sR4Q/SckWGdoQv7fTC/JgP+NYuuEvWtcfAgOq4zln9tRks/lqJ3/elxsTr
         Pyzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=oMzap2j2bfc5OfrfewmFoolVJdX1DDnl6sy2Y4MlHOE=;
        b=Tw7ZJgV22hB/erKHeoOQcE/ysWnnl7Gz3yrYYmOLm5i25OZxfpXAPjXVtZkaFuAmIC
         zjjs6XT5QhULRaxryyLTJXFGertVQ6beaQDg8awndzDDf6HjIfwHKXZVvb9uM7N5Z/Nw
         db6JUOHD2ntVLhdHuI3WBf+8ePsrnnP4GadKuBJ2a/KNlpX5jZBu0egO7sS1sCAmpK3M
         M17a2eGLXwoXQicY4Mm4Amz2pE03a+aBfiNJI0Mj1osI4NZzZC0z138C+OPs91A5vKjG
         EKDiwVA3mCuydPt4Msxj8puyOWvN/9VlE5bAhXcR08khBfT0pLmHBuGgqfXKG2ttqbi6
         QfEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="aaexGiu/";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x9si4788722wmg.120.2019.03.01.04.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:48 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="aaexGiu/";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkL5vSYz9txrv;
	Fri,  1 Mar 2019 13:33:46 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=aaexGiu/; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id kr5qCgX4g2El; Fri,  1 Mar 2019 13:33:46 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkL3vZJz9txrh;
	Fri,  1 Mar 2019 13:33:46 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443626; bh=oMzap2j2bfc5OfrfewmFoolVJdX1DDnl6sy2Y4MlHOE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=aaexGiu/WoGgObW+bWaWKVPW+f4rj7Qlw1xc5ukojxgg6L8bJmzWkJqGwmV9NmaAq
	 qHzzLGZyVkJOC68xOocSq4Cm36iBUcghh+VBereWlsuLIPekp0NiIi9rBe9IO8S6wi
	 rLTfwB8+rREzBxRtXTUp1BJd2N49ldBUUjO/txtQ=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CABCA8BB8B;
	Fri,  1 Mar 2019 13:33:47 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id ySIhsT3bajqr; Fri,  1 Mar 2019 13:33:47 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 797498BB73;
	Fri,  1 Mar 2019 13:33:47 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 56A5D6F89E; Fri,  1 Mar 2019 12:33:47 +0000 (UTC)
Message-Id: <4e09cd6e3ca628a1980739129a9b7f4a92f1b61e.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 09/11] powerpc/32: Add KASAN support
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds KASAN support for PPC32. The following patch
will add an early activation of hash table for book3s. Until
then, a warning will be raised if trying to use KASAN on an
hash 6xx.

To support KASAN, this patch initialises that MMU mapings for
accessing to the KASAN shadow area defined in a previous patch.

An early mapping is set as soon as the kernel code has been
relocated at its definitive place.

Then the definitive mapping is set once paging is initialised.

For modules, the shadow area is allocated at module_alloc().

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig                  |   1 +
 arch/powerpc/include/asm/kasan.h      |   7 ++
 arch/powerpc/kernel/head_32.S         |   3 +
 arch/powerpc/kernel/head_40x.S        |   3 +
 arch/powerpc/kernel/head_44x.S        |   3 +
 arch/powerpc/kernel/head_8xx.S        |   3 +
 arch/powerpc/kernel/head_fsl_booke.S  |   3 +
 arch/powerpc/kernel/setup-common.c    |   3 +
 arch/powerpc/mm/Makefile              |   1 +
 arch/powerpc/mm/kasan/Makefile        |   5 ++
 arch/powerpc/mm/kasan/kasan_init_32.c | 152 ++++++++++++++++++++++++++++++++++
 11 files changed, 184 insertions(+)
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 652c25260838..8d6108c83299 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -172,6 +172,7 @@ config PPC
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN			if PPC32
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 8dc1e3819171..74a4ba9fb8a3 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -27,5 +27,12 @@
 
 #define KASAN_SHADOW_SIZE	(KASAN_SHADOW_END - KASAN_SHADOW_START)
 
+#ifdef CONFIG_KASAN
+void kasan_early_init(void);
+void kasan_init(void);
+#else
+static inline void kasan_init(void) { }
+#endif
+
 #endif /* __ASSEMBLY */
 #endif
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index ce6a972f2584..02229c005853 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -952,6 +952,9 @@ start_here:
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
index a9c934f2319b..efa219d2136e 100644
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
index 37117ab11584..34a5df827b38 100644
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
index 03c73b4c6435..d25adb6ef235 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -853,6 +853,9 @@ start_here:
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
index 1881127682e9..0fc38eb957b7 100644
--- a/arch/powerpc/kernel/head_fsl_booke.S
+++ b/arch/powerpc/kernel/head_fsl_booke.S
@@ -275,6 +275,9 @@ set_ivor:
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
index e7534f306c8e..3c6c5a43901e 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -67,6 +67,7 @@
 #include <asm/livepatch.h>
 #include <asm/mmu_context.h>
 #include <asm/cpu_has_feature.h>
+#include <asm/kasan.h>
 
 #include "setup.h"
 
@@ -865,6 +866,8 @@ static void smp_setup_pacas(void)
  */
 void __init setup_arch(char **cmdline_p)
 {
+	kasan_init();
+
 	*cmdline_p = boot_command_line;
 
 	/* Set a half-reasonable default so udelay does something sensible */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 240d73dce6bb..80382a2d169b 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
 obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
+obj-$(CONFIG_KASAN)		+= kasan/
 
 # Disable kcov instrumentation on sensitive code
 # This is necessary for booting with kcov enabled on book3e machines
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
index 000000000000..cc788917ce38
--- /dev/null
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -0,0 +1,152 @@
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
+#include <asm/code-patching.h>
+#include <mm/mmu_decl.h>
+
+static void kasan_populate_pte(pte_t *ptep, pgprot_t prot)
+{
+	unsigned long va = (unsigned long)kasan_early_shadow_page;
+	phys_addr_t pa = __pa(kasan_early_shadow_page);
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++, ptep++)
+		__set_pte_at(&init_mm, va, ptep, pfn_pte(PHYS_PFN(pa), prot), 0);
+}
+
+static int kasan_init_shadow_page_tables(unsigned long k_start, unsigned long k_end)
+{
+	pmd_t *pmd;
+	unsigned long k_cur, k_next;
+
+	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
+
+	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
+		pte_t *new;
+
+		k_next = pgd_addr_end(k_cur, k_end);
+		if ((void *)pmd_page_vaddr(*pmd) != kasan_early_shadow_pte)
+			continue;
+
+		new = pte_alloc_one_kernel(&init_mm);
+
+		if (!new)
+			return -ENOMEM;
+		kasan_populate_pte(new, PAGE_KERNEL_RO);
+		pmd_populate_kernel(&init_mm, pmd, new);
+	}
+	return 0;
+}
+
+static void __ref *kasan_get_one_page(void)
+{
+	if (slab_is_available())
+		return (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+
+	return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+}
+
+static int __ref kasan_init_region(void *start, size_t size)
+{
+	unsigned long k_start = (unsigned long)kasan_mem_to_shadow(start);
+	unsigned long k_end = (unsigned long)kasan_mem_to_shadow(start + size);
+	unsigned long k_cur;
+	pmd_t *pmd;
+	void *block = NULL;
+	int ret = kasan_init_shadow_page_tables(k_start, k_end);
+
+	if (ret)
+		return ret;
+
+	if (!slab_is_available())
+		block = memblock_alloc(k_end - k_start, PAGE_SIZE);
+
+	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
+		void *va = block ? block + k_cur - k_start : kasan_get_one_page();
+		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
+
+		if (!va)
+			return -ENOMEM;
+
+		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
+		__set_pte_at(&init_mm, k_cur, pte_offset_kernel(pmd, k_cur), pte, 0);
+	}
+	flush_tlb_kernel_range(k_start, k_end);
+	return 0;
+}
+
+static void __init kasan_remap_early_shadow_ro(void)
+{
+	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
+	flush_tlb_kernel_range(KASAN_SHADOW_START, KASAN_SHADOW_END);
+}
+
+void __init kasan_init(void)
+{
+	int ret;
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg) {
+		phys_addr_t base = reg->base;
+		phys_addr_t top = min(base + reg->size, total_lowmem);
+
+		if (base >= top)
+			continue;
+
+		ret = kasan_init_region(__va(base), top - base);
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
+
+void __init kasan_early_init(void)
+{
+	unsigned long addr = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
+	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
+
+	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
+
+	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
+	} while (pmd++, addr = next, addr != end);
+
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		WARN(1, "KASAN not supported on hash 6xx");
+}
-- 
2.13.3

