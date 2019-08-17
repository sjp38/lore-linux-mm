Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92874C3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 387C92173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="k1g17ItQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 387C92173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219166B026E; Fri, 16 Aug 2019 22:46:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CCCD6B026F; Fri, 16 Aug 2019 22:46:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E752F6B0270; Fri, 16 Aug 2019 22:46:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id BFEF96B026E
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:38 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6BC36348D
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:38 +0000 (UTC)
X-FDA: 75830381676.10.bone83_913718c26a04e
X-HE-Tag: bone83_913718c26a04e
X-Filterd-Recvd-Size: 17693
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:37 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id m2so6317425qkd.10
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ia53lpF+y+jsoKGHo4pZ0MvB3e3Jf3WyVjCdlp7ODvY=;
        b=k1g17ItQEBYJmRi3kGMgc7SRgOi7ia9plW++8Fw82rdODTbdTdgAT9pNGbvyqShEs1
         d8Qducw0kaDk7dH5J+wdZ8x/K3pu0BE6AB81fpYvZB0qVYavVTJAvDKVQ4MUVPK6px0h
         iawka1VFFXKMlrcpg0F2HvkFd/JvqhH81sevYJrXjRcAuEDxaZQ3hrO6s0mujNF9akC5
         d0+rVDpnGeNHbCFKP9nLOHI1Jb2bXA5x+6hQkDJDYH6BIIbqZfsc2U+JrFoikBiHkc8i
         Ppf5jwp6QGJDHMaCAHN7q16sXsN1wDV2HtXk1Q7RikQ7pTttNk5rgUHE2+4PWYror0yb
         Uvug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Ia53lpF+y+jsoKGHo4pZ0MvB3e3Jf3WyVjCdlp7ODvY=;
        b=GdNX+72bTMPu+IX5lTaFEtchjvNo91PzZzAbRGE5wwVvwQvAhW2FIQbgiAKxF1uG+0
         dC04nEUQWb1OhTSNFEuCu4NLJuZ/r6/k9Vl0BDHWQP349KAF2qla0yM5IOTTH19nvNYQ
         cAVfWTh2hO4tthfDJ/1OhZvUTD0/chHnGDialUV5/ghuh2z881kIfRM0ePipdyCONhwU
         hoYugtfQiqX0zc2Oxg9/FTR/dAj0REUBimQ64/2FBpm5D5kZLe3yRHqDNPMm0dWDggOE
         hlIxa3SohOrz0JqMq2tu+iCDZv2+ikbhJulUnqexs+fSWnB256jZ19iFOAINPNvhpmxq
         wVzw==
X-Gm-Message-State: APjAAAWMgBNLvoYFFvIj8z1J3fPwTwXXyJtj+iTNN0md4pIh3MdfiZi7
	kQdsmYR+WHJ0yuOqc6vMSXcw9Q==
X-Google-Smtp-Source: APXvYqzaAGnt+5F2jOXRPihTzS5EBFvFLzSlco/lHjdytkzKyZxaRFw70HD+WpDljQLIjSqUbzIP5w==
X-Received: by 2002:a37:624b:: with SMTP id w72mr12264137qkb.368.1566009997057;
        Fri, 16 Aug 2019 19:46:37 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:36 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 04/14] arm64, hibernate: move page handling function to new trans_table.c
Date: Fri, 16 Aug 2019 22:46:19 -0400
Message-Id: <20190817024629.26611-5-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
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
 arch/arm64/Kconfig                   |   4 +
 arch/arm64/include/asm/trans_table.h |  21 +++
 arch/arm64/kernel/hibernate.c        | 199 +------------------------
 arch/arm64/mm/Makefile               |   1 +
 arch/arm64/mm/trans_table.c          | 212 +++++++++++++++++++++++++++
 5 files changed, 239 insertions(+), 198 deletions(-)
 create mode 100644 arch/arm64/include/asm/trans_table.h
 create mode 100644 arch/arm64/mm/trans_table.c

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
diff --git a/arch/arm64/include/asm/trans_table.h b/arch/arm64/include/as=
m/trans_table.h
new file mode 100644
index 000000000000..f57b2ab2a0b8
--- /dev/null
+++ b/arch/arm64/include/asm/trans_table.h
@@ -0,0 +1,21 @@
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
+int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
+			    unsigned long end);
+
+int trans_table_map_page(pgd_t *trans_table, void *page,
+			 unsigned long dst_addr,
+			 pgprot_t pgprot);
+
+#endif /* _ASM_TRANS_TABLE_H */
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 449d69b5651c..0cb858b3f503 100644
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
+#include <asm/trans_table.h>
 #include <asm/virt.h>
=20
 /*
@@ -182,45 +179,6 @@ int arch_hibernation_header_restore(void *addr)
 }
 EXPORT_SYMBOL(arch_hibernation_header_restore);
=20
-int trans_table_map_page(pgd_t *trans_table, void *page,
-			 unsigned long dst_addr,
-			 pgprot_t pgprot)
-{
-	pgd_t *pgdp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t *ptep;
-
-	pgdp =3D pgd_offset_raw(trans_table, dst_addr);
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
  * perform cache maintentance, then maps it at the specified address low
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
-				__pud(pud_val(pud) & ~PMD_SECT_RDONLY));
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
-int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
-			    unsigned long end)
-{
-	int rc;
-	pgd_t *trans_table =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
-
-	if (!trans_table) {
-		pr_err("Failed to allocate memory for temporary page tables.\n");
-		return -ENOMEM;
-	}
-
-	rc =3D copy_page_tables(trans_table, start, end);
-	if (!rc)
-		*dst_pgdp =3D trans_table;
-
-	return rc;
-}
-
 /*
  * Setup then Resume from the hibernate image using swsusp_arch_suspend_=
exit().
  *
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 849c1df3d214..3794fff18659 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -6,6 +6,7 @@ obj-y				:=3D dma-mapping.o extable.o fault.o init.o \
 obj-$(CONFIG_HUGETLB_PAGE)	+=3D hugetlbpage.o
 obj-$(CONFIG_ARM64_PTDUMP_CORE)	+=3D dump.o
 obj-$(CONFIG_ARM64_PTDUMP_DEBUGFS)	+=3D ptdump_debugfs.o
+obj-$(CONFIG_TRANS_TABLE)	+=3D trans_table.o
 obj-$(CONFIG_NUMA)		+=3D numa.o
 obj-$(CONFIG_DEBUG_VIRTUAL)	+=3D physaddr.o
 KASAN_SANITIZE_physaddr.o	+=3D n
diff --git a/arch/arm64/mm/trans_table.c b/arch/arm64/mm/trans_table.c
new file mode 100644
index 000000000000..b4bbb559d9cf
--- /dev/null
+++ b/arch/arm64/mm/trans_table.c
@@ -0,0 +1,212 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Copyright (c) 2019, Microsoft Corporation.
+ * Pavel Tatashin <patatash@linux.microsoft.com>
+ */
+
+/*
+ * Transitional tables are used during system transferring from one worl=
d to
+ * another: such as during hibernate restore, and kexec reboots. During =
these
+ * phases one cannot rely on page table not being overwritten.
+ *
+ */
+
+#include <asm/trans_table.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <linux/suspend.h>
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
+				__pud(pud_val(pud) & ~PMD_SECT_RDONLY));
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
+int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
+			    unsigned long end)
+{
+	int rc;
+	pgd_t *trans_table =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
+
+	if (!trans_table) {
+		pr_err("Failed to allocate memory for temporary page tables.\n");
+		return -ENOMEM;
+	}
+
+	rc =3D copy_page_tables(trans_table, start, end);
+	if (!rc)
+		*dst_pgdp =3D trans_table;
+
+	return rc;
+}
+
+int trans_table_map_page(pgd_t *trans_table, void *page,
+			 unsigned long dst_addr,
+			 pgprot_t pgprot)
+{
+	pgd_t *pgdp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+
+	pgdp =3D pgd_offset_raw(trans_table, dst_addr);
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
2.22.1


