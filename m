Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF81BC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63F00218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63F00218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9F906B000E; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B03CD6B026A; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F0E56B026B; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F44F6B000E
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so8448365pge.16
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=WY0+L0pIgfyvCUmzFdIy1LTc5Xw09u0bbyF0A1uVjso=;
        b=YTpz0NgTceX30YxmCZIcrkr8j0A2vSLMrkX3NzkCH9nNra8h91vWIafkbXKx2prJVj
         cM8FzKquaEVATZsZsWQfSXQQd+mxIa/72nzJfDArk9Bs67AeGlw9/shFTxG3sKUk8no0
         GoYCs5lrVZFGrjgcHn8pLbPJSbhSz1G57STNov2UXnSFnOFTUyABzzkE+H2vnwAfjbru
         AyRw7AufAe/uUY2wWlDMNILuaVGzysaoOrarb9c6ByoFZ26oDMcwVgfm5fJEHK4wmjLA
         kbDCqlN1wPuZ8U0rTRDdezgfjd6NF6E10PaSpH2Yw6SBERkT1PQqncQWrwBHJyvbohpk
         tudw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWj/ojfaNaPiSup6wj833VbUdkgMMR0AQ4BwhAimSGX5LzDTJi+
	JN7wrRAkdI8A0S9jAZds2R67KFlEuzJtA6l8r/42KwgK/Z6T96JW1jm1yI+dJBMaDzphMQ3ncEg
	GHYQWXiMBMk3EaPYVexxVrv0lynjdBYLY4ntmYl1AovAuIT3gi6L1dy+PeR0MOVu3IA==
X-Received: by 2002:a65:5206:: with SMTP id o6mr4088765pgp.341.1555959525792;
        Mon, 22 Apr 2019 11:58:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyi1UFK2Go08wsVw0XGCnfVfVSDpGj8548I8nC8RZvFhiK9bSmqRlAXfhRXNbM7EWXE5MCc
X-Received: by 2002:a65:5206:: with SMTP id o6mr4088661pgp.341.1555959523923;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=COeBenfkR2Stq0kLiZH3VPoI7PZuZNZv+Ver0koeMAiov41TxzESVq/e9adCQFLuPU
         tn67GNxv9I/FiYlnmEm0qn9TQlUDCb8n6AyQUC5mI7xRNi3LCEXsM5F+yWqwzxyFUOEM
         5Asv2iB1Ojpcs3Ii1qKCMJr1y27mjrfZX/GnqJGOdb6Vcz/Vdf30pkkfriaZ81080UkD
         6FnYV8RuM0LX87LOECUQbVaniXzCplrO68+Xc8whzbE0561Hn0AbW6KH7rjU/fnG67vm
         Lw+7iIvNSlPwn8Ueoc9Vto+Ovv16lWCyPTMuyulfHN2y216Is0aG+lcCxPY5Z0Q9kzJS
         G98A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=WY0+L0pIgfyvCUmzFdIy1LTc5Xw09u0bbyF0A1uVjso=;
        b=xe48gWxzX+Cc2dpjhvUbUm3xGQUhQrAWCh6yI3+2Hu5yvVOYiAp/wEiMjhdmviUh5E
         LfvpNS9yHbyf15zQqK4/5/H2Eh4BOyr9ed8GIZFVutpNMKrj29XqCCD/VCXIJIOSFhp4
         AXXRKZ7XEc9gP06xdPy3or52suw/kyHHwypPTQScoOjdIJZf9siV3P6q0gnnhGtNLlLZ
         UnDiTuqcNY9gnNxhx1wswvSngYNmdOQUIlRNl/7PVAHEB2s0mq+27h4DwC+TAUp4H1DU
         qYyC0qymJ+0qyVBpYcVtELYxk5Z+4NUrbsOKk9Mwh6YG1mnIJO1WEtnqIO6BUkcLhVfu
         4Ptw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417158"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:42 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
Subject: [PATCH v4 14/23] x86/mm/cpa: Add set_direct_map_ functions
Date: Mon, 22 Apr 2019 11:57:56 -0700
Message-Id: <20190422185805.1169-15-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add two new functions set_direct_map_default_noflush() and
set_direct_map_invalid_noflush() for setting the direct map alias for the
page to its default valid permissions and to an invalid state that cannot
be cached in a TLB, respectively. These functions do not flush the TLB.

Note, __kernel_map_pages() does something similar but flushes the TLB and
doesn't reset the permission bits to default on all architectures.

Also add an ARCH config ARCH_HAS_SET_DIRECT_MAP for specifying whether
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
 include/linux/set_memory.h        | 11 +++++++++++
 5 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 3ab446bd12ef..5e43fcbad4ca 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -249,6 +249,10 @@ config ARCH_HAS_FORTIFY_SOURCE
 config ARCH_HAS_SET_MEMORY
 	bool
 
+# Select if arch has all set_direct_map_invalid/default() functions
+config ARCH_HAS_SET_DIRECT_MAP
+	bool
+
 # Select if arch init_task must go in the __init_task_data section
 config ARCH_TASK_STRUCT_ON_STACK
        bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2ec5e850b807..45d788354376 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -66,6 +66,7 @@ config X86
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
 	select ARCH_HAS_UACCESS_MCSAFE		if X86_64 && X86_MCE
 	select ARCH_HAS_SET_MEMORY
+	select ARCH_HAS_SET_DIRECT_MAP
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_SYNC_CORE_BEFORE_USERMODE
diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
index 07a25753e85c..ae7b909dc242 100644
--- a/arch/x86/include/asm/set_memory.h
+++ b/arch/x86/include/asm/set_memory.h
@@ -85,6 +85,9 @@ int set_pages_nx(struct page *page, int numpages);
 int set_pages_ro(struct page *page, int numpages);
 int set_pages_rw(struct page *page, int numpages);
 
+int set_direct_map_invalid_noflush(struct page *page);
+int set_direct_map_default_noflush(struct page *page);
+
 extern int kernel_set_to_readonly;
 void set_kernel_text_rw(void);
 void set_kernel_text_ro(void);
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 4c570612e24e..3574550192c6 100644
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
 
+int set_direct_map_invalid_noflush(struct page *page)
+{
+	return __set_pages_np(page, 1);
+}
+
+int set_direct_map_default_noflush(struct page *page)
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
index 2a986d282a97..b5071497b8cb 100644
--- a/include/linux/set_memory.h
+++ b/include/linux/set_memory.h
@@ -17,6 +17,17 @@ static inline int set_memory_x(unsigned long addr,  int numpages) { return 0; }
 static inline int set_memory_nx(unsigned long addr, int numpages) { return 0; }
 #endif
 
+#ifndef CONFIG_ARCH_HAS_SET_DIRECT_MAP
+static inline int set_direct_map_invalid_noflush(struct page *page)
+{
+	return 0;
+}
+static inline int set_direct_map_default_noflush(struct page *page)
+{
+	return 0;
+}
+#endif
+
 #ifndef set_mce_nospec
 static inline int set_mce_nospec(unsigned long pfn)
 {
-- 
2.17.1

