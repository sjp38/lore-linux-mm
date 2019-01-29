Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F6E4C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:40:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28285217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:40:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28285217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE9698E0004; Mon, 28 Jan 2019 19:40:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6E778E0001; Mon, 28 Jan 2019 19:40:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86318E0004; Mon, 28 Jan 2019 19:40:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 659508E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:40:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so12659084pgj.21
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:40:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Y027RJiR9dYgsRTHYJcUS1hjFZKi3qjEOVY152/wOMs=;
        b=rMvBrZke5ALQI4QQFV8ThUfwAm2mZ18cPVJX2ybXKdwLaFLqftaYZWt9AOoco4vGKC
         JQQWRYeg7z8IvFOnquYyD1USnuAvoIw+g3B7FycingnvGm2B/ZFuZfAeLo6Lmaxwv4x/
         K7qyd395J8hdcrbbZUSfJD1KsTCco889u8MfhibpzNlGsm2VAydzov07w7zRgBsv0qUR
         eQq4h7KOageaI2HAj1GdKJcHRF7I9ePB4S+myDh1mHW+XOTGFwXp7HEo/ESyiqfyPqwJ
         JLXEXwU08ankGA3fpn11fVSIV3jjRvx8SkAXwCbOpIbrkynCFtgSGc9UZM4IId2HbRFn
         k33Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfSy0h3Tys8UQ5u9kJQFaX1Nj8xFJKxZwapl0koAYrMwuE3FAco
	k058IeKoUQeqBypRCdnfDjD6xcEq77/6r8Tlz43BQhRV9QbMu4OyTmYSnAAb0qZwDSaokL5hclW
	3GNCjS4Z9pa7LQRpI2qgFJalARZ1DIMvMkqaDdb8gdzmBiuH2pBiNU227jQq1x0jcCw==
X-Received: by 2002:a63:304:: with SMTP id 4mr19893574pgd.99.1548722448059;
        Mon, 28 Jan 2019 16:40:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN48o1HRcT06+m4qjR4g8R7v72g9wmAQ1oE/wRNA67RCPxIc0M7bV2Vh5vVHmZkJlDxUEudv
X-Received: by 2002:a63:304:: with SMTP id 4mr19889583pgd.99.1548722353604;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=xdiZl/wv9/0dun/O7MhDBAwEC7V7SEtZB9N9ZQD29Afz8RB20pNI2+LtxGXsC+QlSy
         9hzCzBSNtE4IRXR02ujxjq9a4W/jBY10jWoY5JeGdSkn2t3VsGJCTwJpKmjobINVK8ej
         ab4KaInPf0xbeuOxh1Ycns9vHAslNOXTnz+WZYxobd0u1wGzi9rD15jMi7JODXfSV6eI
         CqjXkAHlF6EGX0sO8HZqKdKc1O/PGFCI1AbnPBS67yoacUV2IGe8N0dB0bvcszCgfYJK
         fK3XhYrIOzlXYWdv8lRUIPqQeOqra+JBEVjQLAiJ0Wxv+6iEekLeZUBnXSf4yyG93r/o
         A8iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Y027RJiR9dYgsRTHYJcUS1hjFZKi3qjEOVY152/wOMs=;
        b=hzP/K5vbjWDi3Ab9z1/Jy4f/ztilNQknAvbaCFIs4b9E1rY4LUx2XiOuq7iXkag1fI
         pxQd7N4b9caZGlqzJfvnH1EDxlukSIWI89bj8x+h+3wHc0619wnKZtC5ABWebjoCml1g
         HxjkSQmHo737OKemTKOS8/mZCxr9Hl2qDn1CTZ23nqt0gcyRqUQQkgYMF12ZOb+WU+Lt
         LBgUEAPKC9xiZSzGuuAYKmbC9lD8B5VbwiDsmrlK2grGaM7UAWu0inJXuQQre+qcAlQx
         fsy0IS3ivHLnZMsCsdXyaRVaLKLyFDxm7DsBVco3Jr5+ORXNGUeIaHQf6pgxFKaRiwAP
         5c3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i9si7660357plb.35.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921922"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
Date: Mon, 28 Jan 2019 16:34:15 -0800
Message-Id: <20190129003422.9328-14-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds two new functions set_alias_default_noflush and
set_alias_nv_noflush for setting the alias mapping for the page to its
default valid permissions and to an invalid state that cannot be cached in
a TLB, respectively. These functions to not flush the TLB.

Note, __kernel_map_pages does something similar but flushes the TLB and
doesn't reset the permission bits to default on all architectures.

There is also an ARCH config ARCH_HAS_SET_ALIAS for specifying whether
these have an actual implementation or a default empty one.

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/Kconfig                      |  4 ++++
 arch/x86/Kconfig                  |  1 +
 arch/x86/include/asm/set_memory.h |  3 +++
 arch/x86/mm/pageattr.c            | 14 +++++++++++---
 include/linux/set_memory.h        | 10 ++++++++++
 5 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 4cfb6de48f79..4ef9db190f2d 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -249,6 +249,10 @@ config ARCH_HAS_FORTIFY_SOURCE
 config ARCH_HAS_SET_MEMORY
 	bool
 
+# Select if arch has all set_alias_nv/default() functions
+config ARCH_HAS_SET_ALIAS
+	bool
+
 # Select if arch init_task must go in the __init_task_data section
 config ARCH_TASK_STRUCT_ON_STACK
        bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 26387c7bf305..42bb1df4ea94 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -66,6 +66,7 @@ config X86
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
 	select ARCH_HAS_UACCESS_MCSAFE		if X86_64 && X86_MCE
 	select ARCH_HAS_SET_MEMORY
+	select ARCH_HAS_SET_ALIAS
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_SYNC_CORE_BEFORE_USERMODE
diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
index 07a25753e85c..2ef4e4222df1 100644
--- a/arch/x86/include/asm/set_memory.h
+++ b/arch/x86/include/asm/set_memory.h
@@ -85,6 +85,9 @@ int set_pages_nx(struct page *page, int numpages);
 int set_pages_ro(struct page *page, int numpages);
 int set_pages_rw(struct page *page, int numpages);
 
+int set_alias_nv_noflush(struct page *page);
+int set_alias_default_noflush(struct page *page);
+
 extern int kernel_set_to_readonly;
 void set_kernel_text_rw(void);
 void set_kernel_text_ro(void);
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 4f8972311a77..3a51915a1410 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2209,8 +2209,6 @@ int set_pages_rw(struct page *page, int numpages)
 	return set_memory_rw(addr, numpages);
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-
 static int __set_pages_p(struct page *page, int numpages)
 {
 	unsigned long tempaddr = (unsigned long) page_address(page);
@@ -2249,6 +2247,17 @@ static int __set_pages_np(struct page *page, int numpages)
 	return __change_page_attr_set_clr(&cpa, 0);
 }
 
+int set_alias_nv_noflush(struct page *page)
+{
+	return __set_pages_np(page, 1);
+}
+
+int set_alias_default_noflush(struct page *page)
+{
+	return __set_pages_p(page, 1);
+}
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
 	if (PageHighMem(page))
@@ -2282,7 +2291,6 @@ void __kernel_map_pages(struct page *page, int numpages, int enable)
 }
 
 #ifdef CONFIG_HIBERNATION
-
 bool kernel_page_present(struct page *page)
 {
 	unsigned int level;
diff --git a/include/linux/set_memory.h b/include/linux/set_memory.h
index 2a986d282a97..d19481ac6a8f 100644
--- a/include/linux/set_memory.h
+++ b/include/linux/set_memory.h
@@ -10,6 +10,16 @@
 
 #ifdef CONFIG_ARCH_HAS_SET_MEMORY
 #include <asm/set_memory.h>
+#ifndef CONFIG_ARCH_HAS_SET_ALIAS
+static inline int set_alias_nv_noflush(struct page *page)
+{
+	return 0;
+}
+static inline int set_alias_default_noflush(struct page *page)
+{
+	return 0;
+}
+#endif
 #else
 static inline int set_memory_ro(unsigned long addr, int numpages) { return 0; }
 static inline int set_memory_rw(unsigned long addr, int numpages) { return 0; }
-- 
2.17.1

