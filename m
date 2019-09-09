Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE8D9C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79D36218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="fWLhzckv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79D36218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EBC26B0266; Mon,  9 Sep 2019 14:12:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24DE66B0269; Mon,  9 Sep 2019 14:12:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09FF36B026A; Mon,  9 Sep 2019 14:12:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id CF5216B0266
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:38 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 798268243762
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:38 +0000 (UTC)
X-FDA: 75916177596.28.hat62_6e4b798485045
X-HE-Tag: hat62_6e4b798485045
X-Filterd-Recvd-Size: 17956
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:37 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id 201so13959917qkd.13
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Rg4d64JpnTaANXvX3uzyA9vcQSLPYA1Q9YCgAGVLAdE=;
        b=fWLhzckvBH61fecR7zB865Jg/3mFMNrYTLWAWSGeq+qWJtOfowYsPpUvq+bwuAW9P6
         Z7LCFr1BVmxOwJUaO6i/9ZSlrZhuUcqGmWFWOeD/uUuJM8ydEkwk3ivrc1lX1b3hNVsI
         6DCj0nb0JRGJZT18h7YflhWJE2k7q9W1HmDDXrGfOZ0SDf8q97x1rnWuJFB2BKLzTCS4
         NImAULxu7GGCCiRFsYtpyVn6ijZglF0Iuhiup0xopLhz0Sg5ThcJxkS8CoKbCNGFuH6S
         ra2JD13gWjlkh3BXg2VAIuzQMCsPc0R75DpBdBNbyUvp01oSAI3Kne5Ef52+Ng+GtYDK
         Jo/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Rg4d64JpnTaANXvX3uzyA9vcQSLPYA1Q9YCgAGVLAdE=;
        b=PrdeKd4lgyKEoGcAVcEsuWkkPUVir+vZoEt8c/ptj1DZQhw/lMrwq3wZI7PW1Mucwl
         ShSbcrwdVbzdirX8vKPP5r7+ZOZZrQJhrDFbNAw7eXuKk5DLRyRCIxDSO1A1lRpGUqJ4
         470M5bCdO8VS5ARtrnl200UQWz1W0eDhLS/a4FzUhymtZ6XMkfA90XcDbii38ycLVWHj
         mscZR8PrhEkgDgZQ0DLya2kDoh00Wq8GHzUb6pUeRgn61kas//pvs2eM7fCdlZ77pmo2
         wCAdSOFAUdCXJnl22sT/6dPTICZpxiTX8AW625Z1t0eVyF35LSpLpJ3bBSNnvSzljXQC
         OblQ==
X-Gm-Message-State: APjAAAUwsWwXfJdTXVal4fSaFcKXgV2WZbFlysBUIBp+2H0TXgG+YuQB
	NM+2tK2SC9dnmBlBQLSzaTwafg==
X-Google-Smtp-Source: APXvYqzBKILQWUrwZxLxdaMSqsJPQCxgxErrstUv9wanVZcERloJPtlkE4yx+Jd36p+uvRKFpIPi1w==
X-Received: by 2002:a05:620a:14c:: with SMTP id e12mr24483007qkn.47.1568052757183;
        Mon, 09 Sep 2019 11:12:37 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:36 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v4 09/17] arm64: hibernate: move page handling function to new trans_pgd.c
Date: Mon,  9 Sep 2019 14:12:13 -0400
Message-Id: <20190909181221.309510-10-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909181221.309510-1-pasha.tatashin@soleen.com>
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now, that we abstracted the required functions move them to a new home.
Later, we will generalize these function in order to be useful outside
of hibernation.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/Kconfig                 |   4 +
 arch/arm64/include/asm/trans_pgd.h |  20 +++
 arch/arm64/kernel/hibernate.c      | 199 +-------------------------
 arch/arm64/mm/Makefile             |   1 +
 arch/arm64/mm/trans_pgd.c          | 219 +++++++++++++++++++++++++++++
 5 files changed, 245 insertions(+), 198 deletions(-)
 create mode 100644 arch/arm64/include/asm/trans_pgd.h
 create mode 100644 arch/arm64/mm/trans_pgd.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..91a7416ffe4e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -999,6 +999,10 @@ config CRASH_DUMP
=20
 	  For more details see Documentation/admin-guide/kdump/kdump.rst
=20
+config TRANS_TABLE
+	def_bool y
+	depends on HIBERNATION || KEXEC_CORE
+
 config XEN_DOM0
 	def_bool y
 	depends on XEN
diff --git a/arch/arm64/include/asm/trans_pgd.h b/arch/arm64/include/asm/=
trans_pgd.h
new file mode 100644
index 000000000000..c7b5402b7d87
--- /dev/null
+++ b/arch/arm64/include/asm/trans_pgd.h
@@ -0,0 +1,20 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+/*
+ * Copyright (c) 2019, Microsoft Corporation.
+ * Pavel Tatashin <patatash@linux.microsoft.com>
+ */
+
+#ifndef _ASM_TRANS_TABLE_H
+#define _ASM_TRANS_TABLE_H
+
+#include <linux/bits.h>
+#include <asm/pgtable-types.h>
+
+int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
+			  unsigned long end);
+
+int trans_pgd_map_page(pgd_t *trans_pgd, void *page, unsigned long dst_a=
ddr,
+		       pgprot_t pgprot);
+
+#endif /* _ASM_TRANS_TABLE_H */
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 178488a902c7..94ede33bd777 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -16,7 +16,6 @@
 #define pr_fmt(x) "hibernate: " x
 #include <linux/cpu.h>
 #include <linux/kvm_host.h>
-#include <linux/mm.h>
 #include <linux/pm.h>
 #include <linux/sched.h>
 #include <linux/suspend.h>
@@ -31,14 +30,12 @@
 #include <asm/kexec.h>
 #include <asm/memory.h>
 #include <asm/mmu_context.h>
-#include <asm/pgalloc.h>
-#include <asm/pgtable.h>
-#include <asm/pgtable-hwdef.h>
 #include <asm/sections.h>
 #include <asm/smp.h>
 #include <asm/smp_plat.h>
 #include <asm/suspend.h>
 #include <asm/sysreg.h>
+#include <asm/trans_pgd.h>
 #include <asm/virt.h>
=20
 /*
@@ -182,45 +179,6 @@ int arch_hibernation_header_restore(void *addr)
 }
 EXPORT_SYMBOL(arch_hibernation_header_restore);
=20
-int trans_pgd_map_page(pgd_t *trans_pgd, void *page,
-		       unsigned long dst_addr,
-		       pgprot_t pgprot)
-{
-	pgd_t *pgdp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t *ptep;
-
-	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
-	if (pgd_none(READ_ONCE(*pgdp))) {
-		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!pudp)
-			return -ENOMEM;
-		pgd_populate(&init_mm, pgdp, pudp);
-	}
-
-	pudp =3D pud_offset(pgdp, dst_addr);
-	if (pud_none(READ_ONCE(*pudp))) {
-		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!pmdp)
-			return -ENOMEM;
-		pud_populate(&init_mm, pudp, pmdp);
-	}
-
-	pmdp =3D pmd_offset(pudp, dst_addr);
-	if (pmd_none(READ_ONCE(*pmdp))) {
-		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!ptep)
-			return -ENOMEM;
-		pmd_populate_kernel(&init_mm, pmdp, ptep);
-	}
-
-	ptep =3D pte_offset_kernel(pmdp, dst_addr);
-	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
-
-	return 0;
-}
-
 /*
  * Copies length bytes, starting at src_start into an new page,
  * perform cache maintenance, then maps it at the specified address low
@@ -339,161 +297,6 @@ int swsusp_arch_suspend(void)
 	return ret;
 }
=20
-static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long ad=
dr)
-{
-	pte_t pte =3D READ_ONCE(*src_ptep);
-
-	if (pte_valid(pte)) {
-		/*
-		 * Resume will overwrite areas that may be marked
-		 * read only (code, rodata). Clear the RDONLY bit from
-		 * the temporary mappings we use during restore.
-		 */
-		set_pte(dst_ptep, pte_mkwrite(pte));
-	} else if (debug_pagealloc_enabled() && !pte_none(pte)) {
-		/*
-		 * debug_pagealloc will removed the PTE_VALID bit if
-		 * the page isn't in use by the resume kernel. It may have
-		 * been in use by the original kernel, in which case we need
-		 * to put it back in our copy to do the restore.
-		 *
-		 * Before marking this entry valid, check the pfn should
-		 * be mapped.
-		 */
-		BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-		set_pte(dst_ptep, pte_mkpresent(pte_mkwrite(pte)));
-	}
-}
-
-static int copy_pte(pmd_t *dst_pmdp, pmd_t *src_pmdp, unsigned long star=
t,
-		    unsigned long end)
-{
-	pte_t *src_ptep;
-	pte_t *dst_ptep;
-	unsigned long addr =3D start;
-
-	dst_ptep =3D (pte_t *)get_safe_page(GFP_ATOMIC);
-	if (!dst_ptep)
-		return -ENOMEM;
-	pmd_populate_kernel(&init_mm, dst_pmdp, dst_ptep);
-	dst_ptep =3D pte_offset_kernel(dst_pmdp, start);
-
-	src_ptep =3D pte_offset_kernel(src_pmdp, start);
-	do {
-		_copy_pte(dst_ptep, src_ptep, addr);
-	} while (dst_ptep++, src_ptep++, addr +=3D PAGE_SIZE, addr !=3D end);
-
-	return 0;
-}
-
-static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp, unsigned long star=
t,
-		    unsigned long end)
-{
-	pmd_t *src_pmdp;
-	pmd_t *dst_pmdp;
-	unsigned long next;
-	unsigned long addr =3D start;
-
-	if (pud_none(READ_ONCE(*dst_pudp))) {
-		dst_pmdp =3D (pmd_t *)get_safe_page(GFP_ATOMIC);
-		if (!dst_pmdp)
-			return -ENOMEM;
-		pud_populate(&init_mm, dst_pudp, dst_pmdp);
-	}
-	dst_pmdp =3D pmd_offset(dst_pudp, start);
-
-	src_pmdp =3D pmd_offset(src_pudp, start);
-	do {
-		pmd_t pmd =3D READ_ONCE(*src_pmdp);
-
-		next =3D pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
-			continue;
-		if (pmd_table(pmd)) {
-			if (copy_pte(dst_pmdp, src_pmdp, addr, next))
-				return -ENOMEM;
-		} else {
-			set_pmd(dst_pmdp,
-				__pmd(pmd_val(pmd) & ~PMD_SECT_RDONLY));
-		}
-	} while (dst_pmdp++, src_pmdp++, addr =3D next, addr !=3D end);
-
-	return 0;
-}
-
-static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp, unsigned long star=
t,
-		    unsigned long end)
-{
-	pud_t *dst_pudp;
-	pud_t *src_pudp;
-	unsigned long next;
-	unsigned long addr =3D start;
-
-	if (pgd_none(READ_ONCE(*dst_pgdp))) {
-		dst_pudp =3D (pud_t *)get_safe_page(GFP_ATOMIC);
-		if (!dst_pudp)
-			return -ENOMEM;
-		pgd_populate(&init_mm, dst_pgdp, dst_pudp);
-	}
-	dst_pudp =3D pud_offset(dst_pgdp, start);
-
-	src_pudp =3D pud_offset(src_pgdp, start);
-	do {
-		pud_t pud =3D READ_ONCE(*src_pudp);
-
-		next =3D pud_addr_end(addr, end);
-		if (pud_none(pud))
-			continue;
-		if (pud_table(pud)) {
-			if (copy_pmd(dst_pudp, src_pudp, addr, next))
-				return -ENOMEM;
-		} else {
-			set_pud(dst_pudp,
-				__pud(pud_val(pud) & ~PUD_SECT_RDONLY));
-		}
-	} while (dst_pudp++, src_pudp++, addr =3D next, addr !=3D end);
-
-	return 0;
-}
-
-static int copy_page_tables(pgd_t *dst_pgdp, unsigned long start,
-			    unsigned long end)
-{
-	unsigned long next;
-	unsigned long addr =3D start;
-	pgd_t *src_pgdp =3D pgd_offset_k(start);
-
-	dst_pgdp =3D pgd_offset_raw(dst_pgdp, start);
-	do {
-		next =3D pgd_addr_end(addr, end);
-		if (pgd_none(READ_ONCE(*src_pgdp)))
-			continue;
-		if (copy_pud(dst_pgdp, src_pgdp, addr, next))
-			return -ENOMEM;
-	} while (dst_pgdp++, src_pgdp++, addr =3D next, addr !=3D end);
-
-	return 0;
-}
-
-int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
-			  unsigned long end)
-{
-	int rc;
-	pgd_t *trans_pgd =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
-
-	if (!trans_pgd) {
-		pr_err("Failed to allocate memory for temporary page tables.\n");
-		return -ENOMEM;
-	}
-
-	rc =3D copy_page_tables(trans_pgd, start, end);
-	if (!rc)
-		*dst_pgdp =3D trans_pgd;
-
-	return rc;
-}
-
 /*
  * Setup then Resume from the hibernate image using swsusp_arch_suspend_=
exit().
  *
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 849c1df3d214..f3002f1d0e61 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -6,6 +6,7 @@ obj-y				:=3D dma-mapping.o extable.o fault.o init.o \
 obj-$(CONFIG_HUGETLB_PAGE)	+=3D hugetlbpage.o
 obj-$(CONFIG_ARM64_PTDUMP_CORE)	+=3D dump.o
 obj-$(CONFIG_ARM64_PTDUMP_DEBUGFS)	+=3D ptdump_debugfs.o
+obj-$(CONFIG_TRANS_TABLE)	+=3D trans_pgd.o
 obj-$(CONFIG_NUMA)		+=3D numa.o
 obj-$(CONFIG_DEBUG_VIRTUAL)	+=3D physaddr.o
 KASAN_SANITIZE_physaddr.o	+=3D n
diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
new file mode 100644
index 000000000000..5ac712b92439
--- /dev/null
+++ b/arch/arm64/mm/trans_pgd.c
@@ -0,0 +1,219 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Transitional page tables for kexec and hibernate
+ *
+ * This file derived from: arch/arm64/kernel/hibernate.c
+ *
+ * Copyright (c) 2019, Microsoft Corporation.
+ * Pavel Tatashin <patatash@linux.microsoft.com>
+ *
+ */
+
+/*
+ * Transitional tables are used during system transferring from one worl=
d to
+ * another: such as during hibernate restore, and kexec reboots. During =
these
+ * phases one cannot rely on page table not being overwritten. This is b=
ecause
+ * hibernate and kexec can overwrite the current page tables during tran=
sition.
+ */
+
+#include <asm/trans_pgd.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <linux/suspend.h>
+#include <linux/bug.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+
+static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long ad=
dr)
+{
+	pte_t pte =3D READ_ONCE(*src_ptep);
+
+	if (pte_valid(pte)) {
+		/*
+		 * Resume will overwrite areas that may be marked
+		 * read only (code, rodata). Clear the RDONLY bit from
+		 * the temporary mappings we use during restore.
+		 */
+		set_pte(dst_ptep, pte_mkwrite(pte));
+	} else if (debug_pagealloc_enabled() && !pte_none(pte)) {
+		/*
+		 * debug_pagealloc will removed the PTE_VALID bit if
+		 * the page isn't in use by the resume kernel. It may have
+		 * been in use by the original kernel, in which case we need
+		 * to put it back in our copy to do the restore.
+		 *
+		 * Before marking this entry valid, check the pfn should
+		 * be mapped.
+		 */
+		BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+		set_pte(dst_ptep, pte_mkpresent(pte_mkwrite(pte)));
+	}
+}
+
+static int copy_pte(pmd_t *dst_pmdp, pmd_t *src_pmdp, unsigned long star=
t,
+		    unsigned long end)
+{
+	pte_t *src_ptep;
+	pte_t *dst_ptep;
+	unsigned long addr =3D start;
+
+	dst_ptep =3D (pte_t *)get_safe_page(GFP_ATOMIC);
+	if (!dst_ptep)
+		return -ENOMEM;
+	pmd_populate_kernel(&init_mm, dst_pmdp, dst_ptep);
+	dst_ptep =3D pte_offset_kernel(dst_pmdp, start);
+
+	src_ptep =3D pte_offset_kernel(src_pmdp, start);
+	do {
+		_copy_pte(dst_ptep, src_ptep, addr);
+	} while (dst_ptep++, src_ptep++, addr +=3D PAGE_SIZE, addr !=3D end);
+
+	return 0;
+}
+
+static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp, unsigned long star=
t,
+		    unsigned long end)
+{
+	pmd_t *src_pmdp;
+	pmd_t *dst_pmdp;
+	unsigned long next;
+	unsigned long addr =3D start;
+
+	if (pud_none(READ_ONCE(*dst_pudp))) {
+		dst_pmdp =3D (pmd_t *)get_safe_page(GFP_ATOMIC);
+		if (!dst_pmdp)
+			return -ENOMEM;
+		pud_populate(&init_mm, dst_pudp, dst_pmdp);
+	}
+	dst_pmdp =3D pmd_offset(dst_pudp, start);
+
+	src_pmdp =3D pmd_offset(src_pudp, start);
+	do {
+		pmd_t pmd =3D READ_ONCE(*src_pmdp);
+
+		next =3D pmd_addr_end(addr, end);
+		if (pmd_none(pmd))
+			continue;
+		if (pmd_table(pmd)) {
+			if (copy_pte(dst_pmdp, src_pmdp, addr, next))
+				return -ENOMEM;
+		} else {
+			set_pmd(dst_pmdp,
+				__pmd(pmd_val(pmd) & ~PMD_SECT_RDONLY));
+		}
+	} while (dst_pmdp++, src_pmdp++, addr =3D next, addr !=3D end);
+
+	return 0;
+}
+
+static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp, unsigned long star=
t,
+		    unsigned long end)
+{
+	pud_t *dst_pudp;
+	pud_t *src_pudp;
+	unsigned long next;
+	unsigned long addr =3D start;
+
+	if (pgd_none(READ_ONCE(*dst_pgdp))) {
+		dst_pudp =3D (pud_t *)get_safe_page(GFP_ATOMIC);
+		if (!dst_pudp)
+			return -ENOMEM;
+		pgd_populate(&init_mm, dst_pgdp, dst_pudp);
+	}
+	dst_pudp =3D pud_offset(dst_pgdp, start);
+
+	src_pudp =3D pud_offset(src_pgdp, start);
+	do {
+		pud_t pud =3D READ_ONCE(*src_pudp);
+
+		next =3D pud_addr_end(addr, end);
+		if (pud_none(pud))
+			continue;
+		if (pud_table(pud)) {
+			if (copy_pmd(dst_pudp, src_pudp, addr, next))
+				return -ENOMEM;
+		} else {
+			set_pud(dst_pudp,
+				__pud(pud_val(pud) & ~PUD_SECT_RDONLY));
+		}
+	} while (dst_pudp++, src_pudp++, addr =3D next, addr !=3D end);
+
+	return 0;
+}
+
+static int copy_page_tables(pgd_t *dst_pgdp, unsigned long start,
+			    unsigned long end)
+{
+	unsigned long next;
+	unsigned long addr =3D start;
+	pgd_t *src_pgdp =3D pgd_offset_k(start);
+
+	dst_pgdp =3D pgd_offset_raw(dst_pgdp, start);
+	do {
+		next =3D pgd_addr_end(addr, end);
+		if (pgd_none(READ_ONCE(*src_pgdp)))
+			continue;
+		if (copy_pud(dst_pgdp, src_pgdp, addr, next))
+			return -ENOMEM;
+	} while (dst_pgdp++, src_pgdp++, addr =3D next, addr !=3D end);
+
+	return 0;
+}
+
+int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
+			  unsigned long end)
+{
+	int rc;
+	pgd_t *trans_pgd =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
+
+	if (!trans_pgd) {
+		pr_err("Failed to allocate memory for temporary page tables.\n");
+		return -ENOMEM;
+	}
+
+	rc =3D copy_page_tables(trans_pgd, start, end);
+	if (!rc)
+		*dst_pgdp =3D trans_pgd;
+
+	return rc;
+}
+
+int trans_pgd_map_page(pgd_t *trans_pgd, void *page, unsigned long dst_a=
ddr,
+		       pgprot_t pgprot)
+{
+	pgd_t *pgdp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+
+	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
+	if (pgd_none(READ_ONCE(*pgdp))) {
+		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
+		if (!pudp)
+			return -ENOMEM;
+		pgd_populate(&init_mm, pgdp, pudp);
+	}
+
+	pudp =3D pud_offset(pgdp, dst_addr);
+	if (pud_none(READ_ONCE(*pudp))) {
+		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
+		if (!pmdp)
+			return -ENOMEM;
+		pud_populate(&init_mm, pudp, pmdp);
+	}
+
+	pmdp =3D pmd_offset(pudp, dst_addr);
+	if (pmd_none(READ_ONCE(*pmdp))) {
+		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
+		if (!ptep)
+			return -ENOMEM;
+		pmd_populate_kernel(&init_mm, pmdp, ptep);
+	}
+
+	ptep =3D pte_offset_kernel(pmdp, dst_addr);
+	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
+
+	return 0;
+}
--=20
2.23.0


