Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71157C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:34:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E929206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:34:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E929206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B30906B0006; Wed, 17 Apr 2019 10:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8216B0007; Wed, 17 Apr 2019 10:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97FD16B0008; Wed, 17 Apr 2019 10:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41A306B0006
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:34:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h27so12580145eda.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:34:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7MNIGDebGDlQDgQSI54iZCsuoK7QjhvBmM2Uc9b1xWk=;
        b=OL9bJEsVlh3UtGbmmBoV+bg9N0ktfTS4cEmWHYZmZ7KfkWIh/+2yU++0rXFEvcVFDa
         zgo/qcHoTYgdwzAauz5cihLOGl6k8EDQkUA/tbSnMMYNb1BjGg11gctZOpwdykRAO9jr
         vE8IaqNrfJp4YwIga2moxsQfecySUmcKhiLvEnntvsz27P9YEQtBi5WxuMaTODeKZq+d
         51D0KJrOBlNVoKEWHlxpVd53G/e5LrNDDvw6tmOQlBuLVRgpUxtlW4N2YwQhDSUNQUOB
         52WldSSCoN+ltxogfWql8a2DCy5W3B0QbjblQOKl190jH59VUVc3dF7dJQC8MjJQn9Ol
         Gcfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXuTBWnwmPrHfT24/uAOCkUXnTTH3soBzNN0Yeh+YtTYd3rODpT
	A+ulHp6LQUUODmdUg0hWSe1SBoaab1Y51c0qQyb3YGuy2mLl9z6fabhSDg+tGojzx0/XfjY2sjc
	5SsEpxX+7r0zhfDJf7YDbbVFZ3V4ULShdhl8qB2uUVCWPtMG5LliqUz4ZhRjuNuqfEA==
X-Received: by 2002:a50:f74c:: with SMTP id j12mr39489edn.278.1555511675741;
        Wed, 17 Apr 2019 07:34:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqOEJvm+fd4RPYY76uIYun2JUWHs8O2wwnrnP35jLWh2j7Y8fuZohUU1RJhJrhFofeVh9c
X-Received: by 2002:a50:f74c:: with SMTP id j12mr39427edn.278.1555511674572;
        Wed, 17 Apr 2019 07:34:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555511674; cv=none;
        d=google.com; s=arc-20160816;
        b=pNpUPp36jtts8u4Ks1CiPeXB3tb4rxuQ0YFRBwRZcI0j0J0X609AjiZFGUqEby3Sj8
         mmp/uO0YybXiXy3jp7GkImC6x9uREVccsHGwYP80rk5MUp6UZohvopVln0MnTB4QCptH
         dojncN1puFaLa9FD3Z7FC18l9nH1N+8Y8CYQCT6fdHP+At6hw4zPZhnZ4vdqHIHtPW7s
         JUwvzIS9ba4VBVT8GI0a6A7BG8M2/yYMx2QDOWPM6auCs4X0+mBR6HgtqRvfyirvWU1N
         aQ+iIp8aHpq1+Ii2Q7NTmfLkU2pEnpmf14tWX1blWYAeGy/weshvjApe8y0FA//+6JY8
         N3nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7MNIGDebGDlQDgQSI54iZCsuoK7QjhvBmM2Uc9b1xWk=;
        b=MgniNjuOTk9QzRQXa7LCWCgtHFhagnaOsnRyTv4aF2laPEGgDU1F2bUAmYdfM8U7bH
         kp6gTcbHAymboD+BHnhwiaa0fC9E6Ck4mBRsYbxSeIHioMIb8frYdaFDNzvrrj8O3Fb9
         BDZF1jX34EqUWkR3fKnk87W7E1h2qxtTWGqOT91n/SVzZRcFhLfo6s/UNuXERMJsttLv
         v1zMQyE/1RPxTvl3QuEU+257Dqs5gF51fhCr9s6ZDccGibnLsBEXKYBJDKVtLN1aTT07
         lo3YyrMxyrYqOhnRTWAwU2aCJtP7y94OvI/pZt1R7MxkGS4tfo+c1/cveeMy76uHD0j4
         fxQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w18si7044891edi.121.2019.04.17.07.34.34
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 07:34:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 71BB9A78;
	Wed, 17 Apr 2019 07:34:33 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E3E333F557;
	Wed, 17 Apr 2019 07:34:29 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: Dave Hansen <dave.hansen@intel.com>,
	linux-mm@kvack.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	x86@kernel.org,
	Will Deacon <will.deacon@arm.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Steven Price <steven.price@arm.com>
Subject: [RFC PATCH 1/3] mm: Add generic ptdump
Date: Wed, 17 Apr 2019 15:34:21 +0100
Message-Id: <20190417143423.26665-1-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <3acbf061-8c97-55eb-f4b6-163a33ea4d73@arm.com>
References: <3acbf061-8c97-55eb-f4b6-163a33ea4d73@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a generic version of page table dumping that architectures can
opt-in to

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/ptdump.h |  19 +++++
 mm/Kconfig.debug       |  21 ++++++
 mm/Makefile            |   1 +
 mm/ptdump.c            | 159 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 200 insertions(+)
 create mode 100644 include/linux/ptdump.h
 create mode 100644 mm/ptdump.c

diff --git a/include/linux/ptdump.h b/include/linux/ptdump.h
new file mode 100644
index 000000000000..eb8e78154be3
--- /dev/null
+++ b/include/linux/ptdump.h
@@ -0,0 +1,19 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#ifndef _LINUX_PTDUMP_H
+#define _LINUX_PTDUMP_H
+
+struct ptdump_range {
+	unsigned long start;
+	unsigned long end;
+};
+
+struct ptdump_state {
+	void (*note_page)(struct ptdump_state *st, unsigned long addr,
+			  int level, unsigned long val);
+	const struct ptdump_range *range;
+};
+
+void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm);
+
+#endif /* _LINUX_PTDUMP_H */
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index e3df921208c0..21bbf559408b 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -111,3 +111,24 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config GENERIC_PTDUMP
+	bool
+
+config PTDUMP_CORE
+	bool
+
+config PTDUMP_DEBUGFS
+	bool "Export kerenl pagetable layout to userspace via debugfs"
+	depends on DEBUG_KERNEL
+	depends on DEBUG_FS
+	depends on GENERIC_PTDUMP
+	select PTDUMP_CORE
+	help
+	  Say Y here if you want to show the kernel pagetable layout in a
+	  debugfs file. This information is only useful for kernel developers
+	  who are working in architecture specific areas of the kernel.
+	  It is probably not a good idea to enable this feature in a production
+	  kernel.
+
+	  If in doubt, say N.
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..59d653c3250d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -99,3 +99,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_PTDUMP_CORE) += ptdump.o
diff --git a/mm/ptdump.c b/mm/ptdump.c
new file mode 100644
index 000000000000..c8e4c08ce206
--- /dev/null
+++ b/mm/ptdump.c
@@ -0,0 +1,159 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <linux/mm.h>
+#include <linux/ptdump.h>
+#include <linux/kasan.h>
+
+static int ptdump_pgd_entry(pgd_t *pgd, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	pgd_t val = READ_ONCE(*pgd);
+
+	if (pgd_large(val))
+		st->note_page(st, addr, 1, pgd_val(val));
+
+	return 0;
+}
+
+static int ptdump_p4d_entry(p4d_t *p4d, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	p4d_t val = READ_ONCE(*p4d);
+
+	if (p4d_large(val))
+		st->note_page(st, addr, 2, p4d_val(val));
+
+	return 0;
+}
+
+static int ptdump_pud_entry(pud_t *pud, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	pud_t val = READ_ONCE(*pud);
+
+	if (pud_large(val))
+		st->note_page(st, addr, 3, pud_val(val));
+
+	return 0;
+}
+
+static int ptdump_pmd_entry(pmd_t *pmd, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+	pmd_t val = READ_ONCE(*pmd);
+
+	if (pmd_large(val))
+		st->note_page(st, addr, 4, pmd_val(val));
+
+	return 0;
+}
+
+static int ptdump_pte_entry(pte_t *pte, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	st->note_page(st, addr, 5, pte_val(READ_ONCE(*pte)));
+
+	return 0;
+}
+
+#ifdef CONFIG_KASAN
+/*
+ * This is an optimization for KASAN=y case. Since all kasan page tables
+ * eventually point to the kasan_early_shadow_page we could call note_page()
+ * right away without walking through lower level page tables. This saves
+ * us dozens of seconds (minutes for 5-level config) while checking for
+ * W+X mapping or reading kernel_page_tables debugfs file.
+ */
+static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
+				    unsigned long addr)
+{
+	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
+	    (pgtable_l5_enabled() &&
+			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
+	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
+		st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
+		return true;
+	}
+	return false;
+}
+#else
+static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
+				    unsigned long addr)
+{
+	return false;
+}
+#endif
+
+static int ptdump_test_p4d(unsigned long addr, unsigned long next,
+			   p4d_t *p4d, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	if (kasan_page_table(st, p4d, addr))
+		return 1;
+	return 0;
+}
+
+static int ptdump_test_pud(unsigned long addr, unsigned long next,
+			   pud_t *pud, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	if (kasan_page_table(st, pud, addr))
+		return 1;
+	return 0;
+}
+
+static int ptdump_test_pmd(unsigned long addr, unsigned long next,
+			   pmd_t *pmd, struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	if (kasan_page_table(st, pmd, addr))
+		return 1;
+	return 0;
+}
+
+static int ptdump_hole(unsigned long addr, unsigned long next,
+		       struct mm_walk *walk)
+{
+	struct ptdump_state *st = walk->private;
+
+	st->note_page(st, addr, -1, 0);
+
+	return 0;
+}
+
+void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm)
+{
+	struct mm_walk walk = {
+		.mm		= mm,
+		.pgd_entry	= ptdump_pgd_entry,
+		.p4d_entry	= ptdump_p4d_entry,
+		.pud_entry	= ptdump_pud_entry,
+		.pmd_entry	= ptdump_pmd_entry,
+		.pte_entry	= ptdump_pte_entry,
+		.test_p4d	= ptdump_test_p4d,
+		.test_pud	= ptdump_test_pud,
+		.test_pmd	= ptdump_test_pmd,
+		.pte_hole	= ptdump_hole,
+		.private	= st
+	};
+	const struct ptdump_range *range = st->range;
+
+	down_read(&mm->mmap_sem);
+	while (range->start != range->end) {
+		walk_page_range(range->start, range->end, &walk);
+		range++;
+	}
+	up_read(&mm->mmap_sem);
+
+	/* Flush out the last page */
+	st->note_page(st, 0, 0, 0);
+}
-- 
2.20.1

