Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C06AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD096218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EV0/Kezf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD096218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62C5A8E0007; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 518088E0005; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 341EF8E0006; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6DA78E0004
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:39 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y12so1764668pll.15
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=tGIuo+6XNLWxTeQwFkrLNJKDwNp+81usp+K2xaNMZbQ=;
        b=t4BTTMz0R7iFxHiVXjzOjq//DGTNytO61LmM2mdWEGknnFQAytzQ8pCG1AYmd/0/uq
         y3/x2Y+Z1Z9G5AcdMu5SINZZ7dq2r3XX0iQ2C60PuMGsE13/tvk8MoQrizqlIPe5YDY6
         dtC+dMB//GT0v8asnOTEJJqta74u929m2ZRyKCLOo2i1sF1UWd0p08RpBHvSgcbU8XAv
         9FSWrn7mrkKplFsIDOikjpbYViy3nZPuqiH2/lLAf8kLFoq6F8/3/ELqZzpynwg4wiZa
         aCy/HHVhs+O2AgwI0k8TSujyIPaAZDDi5MaVfeE3JOwBQLo/7HDmFlveb1JL0OeAS4zf
         DOfg==
X-Gm-Message-State: AHQUAuZ0e3vPcOLos0yA3AmOjfYPPP/QIymow+rUsabBYLiSr46OTdlV
	S6y/HEVSnjAAKPWQDC9HltarNDuO2dkzGwbEqx06dKdfYnF0Hy227JtTh9mH0AyMJl5hkz6UWrQ
	vj/2uwxJ9N4IF6ahrnda3DDdGrydslgOqyVjdOklXZRcWzLuHKfXxfkMnm2tBsh2sIg==
X-Received: by 2002:a63:4b60:: with SMTP id k32mr845414pgl.186.1550102559411;
        Wed, 13 Feb 2019 16:02:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbdUvmKsFyYVZ1P4KkXwBoyGe6x8XD6uQfKRc3wNnRfy488LkeKkjIS5cNwQZm9NsEcTlYd
X-Received: by 2002:a63:4b60:: with SMTP id k32mr845257pgl.186.1550102557698;
        Wed, 13 Feb 2019 16:02:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102557; cv=none;
        d=google.com; s=arc-20160816;
        b=TNHKQUQ34RIQcl1vChvcLlo4Zy9ERQPDBqTMHdZWUBXe4wotmF0MXnAbTmuXME+9m1
         JdmXoKJ4gxo0K6a9/DzfULTjE3hQUW+CGg4TiCt+SpozPF1QFSm2agFog3wzSg0Bkkn8
         pxszS13UkmXCCiA0h9hh7ci4G5kTBoDfthlDqf/wayedYyb9/aLm/CAZGfRvBfn2PyEz
         bFND/1qEOYl5xX8dMX+JY2xyPV05Hs24VKniGvmASgjy17y005/vCZjbnbrPz2egyfSa
         CH93i/5DFb3mf3gUo13pZThjQ13xkt+CxmyMBqxN7Dq5vMI3g+hhQxYfUhXr47MERxeF
         +mfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=tGIuo+6XNLWxTeQwFkrLNJKDwNp+81usp+K2xaNMZbQ=;
        b=qhLrPPvGR8vPmI/2PVP+WsFlEPBbwBTfTdOO2yiIe0WnD1xPICMcnc34bhxAubkt8p
         XAtm7Z80g3sTAaC6HJNAMMZed2z9cWj76dZyv4ujkaxJt50Wy4hwuFSC+vfwT4CE8ANF
         f/3mr829qugStg81x+wNiSPIbGYwdvWbMC6ujrkVAhDeDrFPK5JREzi1l4xhiqc8UJr7
         xTXNT8okyBH9okKFzofi9mo3sQYVjMn2f7kB/kZAiRqtaW5HR9NYOfYE9IXTVWhlujke
         TleeLKi0hhYnCt1V3j94mkvXLiL3zimvxZFoK1tZEwVPALd1glplxD9VyAkm19476cTp
         FaPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="EV0/Kezf";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a68si772715pla.267.2019.02.13.16.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:37 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="EV0/Kezf";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwnGH100531;
	Thu, 14 Feb 2019 00:02:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=tGIuo+6XNLWxTeQwFkrLNJKDwNp+81usp+K2xaNMZbQ=;
 b=EV0/KezfENVHmr/AMNMxy2Nd61uEG5+pcnOu5DPfYMTva1/IdPx+bbb8siANlxD0fdgY
 sZukNc6EGxpttdwgr8JPyw6hQH4zlHCuBvnmuyXP71eeBk2S8t7slIaSOrF+P6M5wC5y
 4Jv2X3fB+dQq9pFM9aC2bB4beiAYPs0WbvJHQz9UfOi+aD489bz7N77ZxE4TQOG/CrX2
 05lcdk23um8iMP0q5FcGMFpG+98u25VFNMJtTzpAfxlaCt8/lCpSyfYuK/e5sd3YmYYB
 EWzKyo9eiVRG1uOsHGyawgrR7H9TeOXmHDB7Hd3VozbXXXOXFmJTQwVd1e+JN7Gs6ldm 1A== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3ud-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:07 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1E0224s007646
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:02 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E022w3018542;
	Thu, 14 Feb 2019 00:02:02 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:01 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho@docker.com>,
        Marco Benatto <marco.antonio.780@gmail.com>
Subject: [RFC PATCH v8 03/14] mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
Date: Wed, 13 Feb 2019 17:01:26 -0700
Message-Id: <8275de2a7e6b72d19b1cd2ec5d71a42c2c7dd6c5.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

This patch adds support for XPFO which protects against 'ret2dir' kernel
attacks. The basic idea is to enforce exclusive ownership of page frames
by either the kernel or userspace, unless explicitly requested by the
kernel. Whenever a page destined for userspace is allocated, it is
unmapped from physmap (the kernel's page table). When such a page is
reclaimed from userspace, it is mapped back to physmap.

Additional fields in the page_ext struct are used for XPFO housekeeping,
specifically:
  - two flags to distinguish user vs. kernel pages and to tag unmapped
    pages.
  - a reference counter to balance kmap/kunmap operations.
  - a lock to serialize access to the XPFO fields.

This patch is based on the work of Vasileios P. Kemerlis et al. who
published their work in this paper:
  http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

v6: * use flush_tlb_kernel_range() instead of __flush_tlb_one, so we flush
      the tlb entry on all CPUs when unmapping it in kunmap
    * handle lookup_page_ext()/lookup_xpfo() returning NULL
    * drop lots of BUG()s in favor of WARN()
    * don't disable irqs in xpfo_kmap/xpfo_kunmap, export
      __split_large_page so we can do our own alloc_pages(GFP_ATOMIC) to
      pass it

CC: x86@kernel.org
Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
[jsteckli@amazon.de: rebased from v4.13 to v4.19]
Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 .../admin-guide/kernel-parameters.txt         |   2 +
 arch/x86/Kconfig                              |   1 +
 arch/x86/include/asm/pgtable.h                |  26 ++
 arch/x86/mm/Makefile                          |   2 +
 arch/x86/mm/pageattr.c                        |  23 +-
 arch/x86/mm/xpfo.c                            | 119 ++++++++++
 include/linux/highmem.h                       |  15 +-
 include/linux/xpfo.h                          |  48 ++++
 mm/Makefile                                   |   1 +
 mm/page_alloc.c                               |   2 +
 mm/page_ext.c                                 |   4 +
 mm/xpfo.c                                     | 223 ++++++++++++++++++
 security/Kconfig                              |  19 ++
 13 files changed, 463 insertions(+), 22 deletions(-)
 create mode 100644 arch/x86/mm/xpfo.c
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index aefd358a5ca3..c4c62599f216 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2982,6 +2982,8 @@
 
 	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
 
+	noxpfo		[X86-64] Disable XPFO when CONFIG_XPFO is on.
+
 	cpu0_hotplug	[X86] Turn on CPU0 hotplug feature when
 			CONFIG_BOOTPARAM_HOTPLUG_CPU0 is off.
 			Some features depend on CPU0. Known dependencies are:
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8689e794a43c..d69d8cc6e57e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -207,6 +207,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_SUPPORTS_XPFO		if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 40616e805292..f6eeb75c8a21 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1437,6 +1437,32 @@ static inline bool arch_has_pfn_modify_check(void)
 	return boot_cpu_has_bug(X86_BUG_L1TF);
 }
 
+/*
+ * The current flushing context - we pass it instead of 5 arguments:
+ */
+struct cpa_data {
+	unsigned long	*vaddr;
+	pgd_t		*pgd;
+	pgprot_t	mask_set;
+	pgprot_t	mask_clr;
+	unsigned long	numpages;
+	int		flags;
+	unsigned long	pfn;
+	unsigned	force_split		: 1,
+			force_static_prot	: 1;
+	int		curpage;
+	struct page	**pages;
+};
+
+
+int
+should_split_large_page(pte_t *kpte, unsigned long address,
+			struct cpa_data *cpa);
+extern spinlock_t cpa_lock;
+int
+__split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
+		   struct page *base);
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..93b0fdaf4a99 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
+
+obj-$(CONFIG_XPFO)		+= xpfo.o
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a1bcde35db4c..84002442ab61 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -26,23 +26,6 @@
 #include <asm/pat.h>
 #include <asm/set_memory.h>
 
-/*
- * The current flushing context - we pass it instead of 5 arguments:
- */
-struct cpa_data {
-	unsigned long	*vaddr;
-	pgd_t		*pgd;
-	pgprot_t	mask_set;
-	pgprot_t	mask_clr;
-	unsigned long	numpages;
-	int		flags;
-	unsigned long	pfn;
-	unsigned	force_split		: 1,
-			force_static_prot	: 1;
-	int		curpage;
-	struct page	**pages;
-};
-
 enum cpa_warn {
 	CPA_CONFLICT,
 	CPA_PROTECT,
@@ -57,7 +40,7 @@ static const int cpa_warn_level = CPA_PROTECT;
  * entries change the page attribute in parallel to some other cpu
  * splitting a large page entry along with changing the attribute.
  */
-static DEFINE_SPINLOCK(cpa_lock);
+DEFINE_SPINLOCK(cpa_lock);
 
 #define CPA_FLUSHTLB 1
 #define CPA_ARRAY 2
@@ -869,7 +852,7 @@ static int __should_split_large_page(pte_t *kpte, unsigned long address,
 	return 0;
 }
 
-static int should_split_large_page(pte_t *kpte, unsigned long address,
+int should_split_large_page(pte_t *kpte, unsigned long address,
 				   struct cpa_data *cpa)
 {
 	int do_split;
@@ -919,7 +902,7 @@ static void split_set_pte(struct cpa_data *cpa, pte_t *pte, unsigned long pfn,
 	set_pte(pte, pfn_pte(pfn, ref_prot));
 }
 
-static int
+int
 __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 		   struct page *base)
 {
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
new file mode 100644
index 000000000000..6c7502993351
--- /dev/null
+++ b/arch/x86/mm/xpfo.c
@@ -0,0 +1,119 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+
+#include <asm/tlbflush.h>
+
+extern spinlock_t cpa_lock;
+
+/* Update a single kernel page table entry */
+inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
+{
+	unsigned int level;
+	pgprot_t msk_clr;
+	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
+
+	if (unlikely(!pte)) {
+		WARN(1, "xpfo: invalid address %p\n", kaddr);
+		return;
+	}
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		set_pte_atomic(pte, pfn_pte(page_to_pfn(page),
+			       canon_pgprot(prot)));
+		break;
+	case PG_LEVEL_2M:
+	case PG_LEVEL_1G: {
+		struct cpa_data cpa = { };
+		int do_split;
+
+		if (level == PG_LEVEL_2M)
+			msk_clr = pmd_pgprot(*(pmd_t *)pte);
+		else
+			msk_clr = pud_pgprot(*(pud_t *)pte);
+
+		cpa.vaddr = kaddr;
+		cpa.pages = &page;
+		cpa.mask_set = prot;
+		cpa.mask_clr = msk_clr;
+		cpa.numpages = 1;
+		cpa.flags = 0;
+		cpa.curpage = 0;
+		cpa.force_split = 0;
+
+
+		do_split = should_split_large_page(pte, (unsigned long)kaddr,
+						   &cpa);
+		if (do_split) {
+			struct page *base;
+
+			base = alloc_pages(GFP_ATOMIC, 0);
+			if (!base) {
+				WARN(1, "xpfo: failed to split large page\n");
+				break;
+			}
+
+			if (!debug_pagealloc_enabled())
+				spin_lock(&cpa_lock);
+			if  (__split_large_page(&cpa, pte,
+						(unsigned long)kaddr, base) < 0)
+				WARN(1, "xpfo: failed to split large page\n");
+			if (!debug_pagealloc_enabled())
+				spin_unlock(&cpa_lock);
+		}
+
+		break;
+	}
+	case PG_LEVEL_512G:
+		/* fallthrough, splitting infrastructure doesn't
+		 * support 512G pages.
+		 */
+	default:
+		WARN(1, "xpfo: unsupported page level %x\n", level);
+	}
+
+}
+
+inline void xpfo_flush_kernel_tlb(struct page *page, int order)
+{
+	int level;
+	unsigned long size, kaddr;
+
+	kaddr = (unsigned long)page_address(page);
+
+	if (unlikely(!lookup_address(kaddr, &level))) {
+		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr,
+		     level);
+		return;
+	}
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		size = PAGE_SIZE;
+		break;
+	case PG_LEVEL_2M:
+		size = PMD_SIZE;
+		break;
+	case PG_LEVEL_1G:
+		size = PUD_SIZE;
+		break;
+	default:
+		WARN(1, "xpfo: unsupported page level %x\n", level);
+		return;
+	}
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+}
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 0690679832d4..1fdae929e38b 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -8,6 +8,7 @@
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 #include <linux/hardirq.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 
@@ -56,24 +57,34 @@ static inline struct page *kmap_to_page(void *addr)
 #ifndef ARCH_HAS_KMAP
 static inline void *kmap(struct page *page)
 {
+	void *kaddr;
+
 	might_sleep();
-	return page_address(page);
+	kaddr = page_address(page);
+	xpfo_kmap(kaddr, page);
+	return kaddr;
 }
 
 static inline void kunmap(struct page *page)
 {
+	xpfo_kunmap(page_address(page), page);
 }
 
 static inline void *kmap_atomic(struct page *page)
 {
+	void *kaddr;
+
 	preempt_disable();
 	pagefault_disable();
-	return page_address(page);
+	kaddr = page_address(page);
+	xpfo_kmap(kaddr, page);
+	return kaddr;
 }
 #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
 
 static inline void __kunmap_atomic(void *addr)
 {
+	xpfo_kunmap(addr, virt_to_page(addr));
 	pagefault_enable();
 	preempt_enable();
 }
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
new file mode 100644
index 000000000000..b15234745fb4
--- /dev/null
+++ b/include/linux/xpfo.h
@@ -0,0 +1,48 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (C) 2017 Docker, Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *   Tycho Andersen <tycho@docker.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef _LINUX_XPFO_H
+#define _LINUX_XPFO_H
+
+#include <linux/types.h>
+#include <linux/dma-direction.h>
+
+struct page;
+
+#ifdef CONFIG_XPFO
+
+extern struct page_ext_operations page_xpfo_ops;
+
+void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
+void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
+				    enum dma_data_direction dir);
+void xpfo_flush_kernel_tlb(struct page *page, int order);
+
+void xpfo_kmap(void *kaddr, struct page *page);
+void xpfo_kunmap(void *kaddr, struct page *page);
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
+void xpfo_free_pages(struct page *page, int order);
+
+#else /* !CONFIG_XPFO */
+
+static inline void xpfo_kmap(void *kaddr, struct page *page) { }
+static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
+static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
+static inline void xpfo_free_pages(struct page *page, int order) { }
+
+#endif /* CONFIG_XPFO */
+
+#endif /* _LINUX_XPFO_H */
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..e99e1e6ae5ae 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -99,3 +99,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_XPFO) += xpfo.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e95b5b7c9c3d..08e277790b5f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1038,6 +1038,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 	kasan_free_pages(page, order);
+	xpfo_free_pages(page, order);
 
 	return true;
 }
@@ -1915,6 +1916,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	xpfo_alloc_pages(page, order, gfp_flags);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7adbe07..38e5013dcb9a 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -8,6 +8,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/xpfo.h>
 
 /*
  * struct page extension
@@ -68,6 +69,9 @@ static struct page_ext_operations *page_ext_ops[] = {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
+#ifdef CONFIG_XPFO
+	&page_xpfo_ops,
+#endif
 };
 
 static unsigned long total_usage;
diff --git a/mm/xpfo.c b/mm/xpfo.c
new file mode 100644
index 000000000000..24b33d3c20cb
--- /dev/null
+++ b/mm/xpfo.c
@@ -0,0 +1,223 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2017 Docker, Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *   Tycho Andersen <tycho@docker.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/page_ext.h>
+#include <linux/xpfo.h>
+
+#include <asm/tlbflush.h>
+
+/* XPFO page state flags */
+enum xpfo_flags {
+	XPFO_PAGE_USER,		/* Page is allocated to user-space */
+	XPFO_PAGE_UNMAPPED,	/* Page is unmapped from the linear map */
+};
+
+/* Per-page XPFO house-keeping data */
+struct xpfo {
+	unsigned long flags;	/* Page state */
+	bool inited;		/* Map counter and lock initialized */
+	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
+	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
+};
+
+DEFINE_STATIC_KEY_FALSE(xpfo_inited);
+
+static bool xpfo_disabled __initdata;
+
+static int __init noxpfo_param(char *str)
+{
+	xpfo_disabled = true;
+
+	return 0;
+}
+
+early_param("noxpfo", noxpfo_param);
+
+static bool __init need_xpfo(void)
+{
+	if (xpfo_disabled) {
+		pr_info("XPFO disabled\n");
+		return false;
+	}
+
+	return true;
+}
+
+static void init_xpfo(void)
+{
+	pr_info("XPFO enabled\n");
+	static_branch_enable(&xpfo_inited);
+}
+
+struct page_ext_operations page_xpfo_ops = {
+	.size = sizeof(struct xpfo),
+	.need = need_xpfo,
+	.init = init_xpfo,
+};
+
+static inline struct xpfo *lookup_xpfo(struct page *page)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+
+	if (unlikely(!page_ext)) {
+		WARN(1, "xpfo: failed to get page ext");
+		return NULL;
+	}
+
+	return (void *)page_ext + page_xpfo_ops.offset;
+}
+
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
+{
+	int i, flush_tlb = 0;
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++)  {
+		xpfo = lookup_xpfo(page + i);
+		if (!xpfo)
+			continue;
+
+		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
+		     "xpfo: unmapped page being allocated\n");
+
+		/* Initialize the map lock and map counter */
+		if (unlikely(!xpfo->inited)) {
+			spin_lock_init(&xpfo->maplock);
+			atomic_set(&xpfo->mapcount, 0);
+			xpfo->inited = true;
+		}
+		WARN(atomic_read(&xpfo->mapcount),
+		     "xpfo: already mapped page being allocated\n");
+
+		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
+			/*
+			 * Tag the page as a user page and flush the TLB if it
+			 * was previously allocated to the kernel.
+			 */
+			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
+				flush_tlb = 1;
+		} else {
+			/* Tag the page as a non-user (kernel) page */
+			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
+		}
+	}
+
+	if (flush_tlb)
+		xpfo_flush_kernel_tlb(page, order);
+}
+
+void xpfo_free_pages(struct page *page, int order)
+{
+	int i;
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++) {
+		xpfo = lookup_xpfo(page + i);
+		if (!xpfo || unlikely(!xpfo->inited)) {
+			/*
+			 * The page was allocated before page_ext was
+			 * initialized, so it is a kernel page.
+			 */
+			continue;
+		}
+
+		/*
+		 * Map the page back into the kernel if it was previously
+		 * allocated to user space.
+		 */
+		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
+			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+			set_kpte(page_address(page + i), page + i,
+				 PAGE_KERNEL);
+		}
+	}
+}
+
+void xpfo_kmap(void *kaddr, struct page *page)
+{
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	xpfo = lookup_xpfo(page);
+
+	/*
+	 * The page was allocated before page_ext was initialized (which means
+	 * it's a kernel page) or it's allocated to the kernel, so nothing to
+	 * do.
+	 */
+	if (!xpfo || unlikely(!xpfo->inited) ||
+	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+		return;
+
+	spin_lock(&xpfo->maplock);
+
+	/*
+	 * The page was previously allocated to user space, so map it back
+	 * into the kernel. No TLB flush required.
+	 */
+	if ((atomic_inc_return(&xpfo->mapcount) == 1) &&
+	    test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+		set_kpte(kaddr, page, PAGE_KERNEL);
+
+	spin_unlock(&xpfo->maplock);
+}
+EXPORT_SYMBOL(xpfo_kmap);
+
+void xpfo_kunmap(void *kaddr, struct page *page)
+{
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	xpfo = lookup_xpfo(page);
+
+	/*
+	 * The page was allocated before page_ext was initialized (which means
+	 * it's a kernel page) or it's allocated to the kernel, so nothing to
+	 * do.
+	 */
+	if (!xpfo || unlikely(!xpfo->inited) ||
+	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+		return;
+
+	spin_lock(&xpfo->maplock);
+
+	/*
+	 * The page is to be allocated back to user space, so unmap it from the
+	 * kernel, flush the TLB and tag it as a user page.
+	 */
+	if (atomic_dec_return(&xpfo->mapcount) == 0) {
+		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
+		     "xpfo: unmapping already unmapped page\n");
+		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+		set_kpte(kaddr, page, __pgprot(0));
+		xpfo_flush_kernel_tlb(page, 0);
+	}
+
+	spin_unlock(&xpfo->maplock);
+}
+EXPORT_SYMBOL(xpfo_kunmap);
diff --git a/security/Kconfig b/security/Kconfig
index d9aa521b5206..8d0e4e303551 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -6,6 +6,25 @@ menu "Security options"
 
 source security/keys/Kconfig
 
+config ARCH_SUPPORTS_XPFO
+	bool
+
+config XPFO
+	bool "Enable eXclusive Page Frame Ownership (XPFO)"
+	default n
+	depends on ARCH_SUPPORTS_XPFO
+	select PAGE_EXTENSION
+	help
+	  This option offers protection against 'ret2dir' kernel attacks.
+	  When enabled, every time a page frame is allocated to user space, it
+	  is unmapped from the direct mapped RAM region in kernel space
+	  (physmap). Similarly, when a page frame is freed/reclaimed, it is
+	  mapped back to physmap.
+
+	  There is a slight performance impact when this option is enabled.
+
+	  If in doubt, say "N".
+
 config SECURITY_DMESG_RESTRICT
 	bool "Restrict unprivileged access to the kernel syslog"
 	default n
-- 
2.17.1

