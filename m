Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F385EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC67220818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC67220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C94C78E00C9; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20658E00B5; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A93F08E00C9; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65F3C8E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o24so341999pgh.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=n3xL8tglsp1p5h94RExQEs/it39xNrHdfjkbRBXvvQk=;
        b=a8qP9JNkxW6mE1TkD97X9oaPgFseWbt1CqlkyOIkIMEGKBXmmXDtNRfaCbeNAyqnCS
         16VZBpc3SgbDpw6dEq92js7WdJN+4GwCOegynfEQUvQtdjNKIR4BQ0hKYRSw4seOw9ij
         kvre3dbV1e2ZRGOVs3szKlisPkr847wYsCvuGU6W2i1bDybczuaEmD9H2EuNS8oA/+8I
         ZrVm65cty5I6yfA3lagCntzd6brC2ecJwlu/pYsEkngUpr7ol8Iye8vhAaSH824IWAS6
         Juy8r+VnYnlXyVTuVqxRjs1cZeZahX7psltUAnNuuSLcHsECf2yfedC2dW4xr53u0FdD
         OhbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubQW0fAGeoUOu44KVqOc8g7t30Nl88St+25CW023Xw7E+GtJu2h
	mhBnoKpzXn9IXhHUsUT42/Myf8JZwIdQqpehiit+0ye1suLA3bPLC3zMZu6R+0dpfzQWZVA9ldS
	5TR0RHMd/wJPdM4NBPIItq8H8RkMmKQBbcGYtHqsk0LXxJ7xh+N/2bRbXYw0l4ks2vA==
X-Received: by 2002:a65:64d9:: with SMTP id t25mr1106496pgv.244.1550793059067;
        Thu, 21 Feb 2019 15:50:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbaKAPGGw6sB/35DUn1+d5SdF5gAuKmAWisRKNsL7808JH/c1VgbbwbiKVjfGkxw7j04PqZ
X-Received: by 2002:a65:64d9:: with SMTP id t25mr1106450pgv.244.1550793058260;
        Thu, 21 Feb 2019 15:50:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793058; cv=none;
        d=google.com; s=arc-20160816;
        b=yPwcHBeU57cd2gL+64uQg3udGhlotSVjMtotzWls9o1COdh+fTZ+VyBAkVD/k0JzBX
         ZV+ZFmUTorr+Gzv6NZCtboklMNLCl4knSvANWAe6jM1GeQVsGwCHKv3gI63lQHNwc7Jt
         P1EK4JJNvfooujOBl6el8W1ZyAWpGPn6rlTTy1uCmpJlWgHGSlLwbKOhiBDvdV5qtbI4
         AoY+vMR56b6aGBb0ok6kr98ILDV75suWU1NygUeybraQRlSgnCmBeu+NmpIEqtVEKfzh
         1HQ+w/KgU3BJRtMLkAqGcy+ah8eefaQgY6xpMaelUfOCwIg2lqwIldL+bcY6leiepz3+
         HUQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=n3xL8tglsp1p5h94RExQEs/it39xNrHdfjkbRBXvvQk=;
        b=jCErq1psP2RrUjjkhqcBj67TONXjuzzv7fddgMHfSYpTUdoAAJ551bcmux6RuE002Q
         4RPcPveqtHg9cEapXrJBZ8iu3MbNxfZNkfmtbewJHnmQRD97MT0gT0XGvITE5Smpaeg2
         vCJeS8UKnBbobnUAP3/MeW9+LUegESCyUf3sIsZB1JgmZcQm+Q4L/YHLv+S7DnFjtamG
         ksU5tL64lHc9srI+31CnQKfVphiCnN3YBhRsVcLHlSp9KpjkeIaRXiPMrrkWYRYYLgMf
         MXwIH0W5uHSGdkIGBqUirWylEFNyArv5FQ37sVrWfY9CaRYNyokX16VcFhd2V6oFmbDM
         QtmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:58 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:57 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394827"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:56 -0800
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
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 05/20] x86/alternative: Initialize temporary mm for patching
Date: Thu, 21 Feb 2019 15:44:36 -0800
Message-Id: <20190221234451.17632-6-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

To prevent improper use of the PTEs that are used for text patching, the
next patches will use a temporary mm struct. Initailize it by copying
the init mm.

The address that will be used for patching is taken from the lower area
that is usually used for the task memory. Doing so prevents the need to
frequently synchronize the temporary-mm (e.g., when BPF programs are
installed), since different PGDs are used for the task memory.

Finally, randomize the address of the PTEs to harden against exploits
that use these PTEs.

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/pgtable.h       |  3 +++
 arch/x86/include/asm/text-patching.h |  2 ++
 arch/x86/kernel/alternative.c        |  3 +++
 arch/x86/mm/init_64.c                | 36 ++++++++++++++++++++++++++++
 init/main.c                          |  3 +++
 5 files changed, 47 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 40616e805292..e8f630d9a2ed 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1021,6 +1021,9 @@ static inline void __meminit init_trampoline_default(void)
 	/* Default trampoline pgd value */
 	trampoline_pgd_entry = init_top_pgt[pgd_index(__PAGE_OFFSET)];
 }
+
+void __init poking_init(void);
+
 # ifdef CONFIG_RANDOMIZE_MEMORY
 void __meminit init_trampoline(void);
 # else
diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index f8fc8e86cf01..a75eed841eed 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -39,5 +39,7 @@ extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
 extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
+extern __ro_after_init struct mm_struct *poking_mm;
+extern __ro_after_init unsigned long poking_addr;
 
 #endif /* _ASM_X86_TEXT_PATCHING_H */
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 12fddbc8c55b..ae05fbb50171 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -678,6 +678,9 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 	return addr;
 }
 
+__ro_after_init struct mm_struct *poking_mm;
+__ro_after_init unsigned long poking_addr;
+
 static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
 	unsigned long flags;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bccff68e3267..125c8c48aa24 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -53,6 +53,7 @@
 #include <asm/init.h>
 #include <asm/uv/uv.h>
 #include <asm/setup.h>
+#include <asm/text-patching.h>
 
 #include "mm_internal.h"
 
@@ -1383,6 +1384,41 @@ unsigned long memory_block_size_bytes(void)
 	return memory_block_size_probed;
 }
 
+/*
+ * Initialize an mm_struct to be used during poking and a pointer to be used
+ * during patching.
+ */
+void __init poking_init(void)
+{
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	poking_mm = copy_init_mm();
+	BUG_ON(!poking_mm);
+
+	/*
+	 * Randomize the poking address, but make sure that the following page
+	 * will be mapped at the same PMD. We need 2 pages, so find space for 3,
+	 * and adjust the address if the PMD ends after the first one.
+	 */
+	poking_addr = TASK_UNMAPPED_BASE;
+	if (IS_ENABLED(CONFIG_RANDOMIZE_BASE))
+		poking_addr += (kaslr_get_random_long("Poking") & PAGE_MASK) %
+			(TASK_SIZE - TASK_UNMAPPED_BASE - 3 * PAGE_SIZE);
+
+	if (((poking_addr + PAGE_SIZE) & ~PMD_MASK) == 0)
+		poking_addr += PAGE_SIZE;
+
+	/*
+	 * We need to trigger the allocation of the page-tables that will be
+	 * needed for poking now. Later, poking may be performed in an atomic
+	 * section, which might cause allocation to fail.
+	 */
+	ptep = get_locked_pte(poking_mm, poking_addr, &ptl);
+	BUG_ON(!ptep);
+	pte_unmap_unlock(ptep, ptl);
+}
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
diff --git a/init/main.c b/init/main.c
index e2e80ca3165a..f5947ba53bb4 100644
--- a/init/main.c
+++ b/init/main.c
@@ -496,6 +496,8 @@ void __init __weak thread_stack_cache_init(void)
 
 void __init __weak mem_encrypt_init(void) { }
 
+void __init __weak poking_init(void) { }
+
 bool initcall_debug;
 core_param(initcall_debug, initcall_debug, bool, 0644);
 
@@ -730,6 +732,7 @@ asmlinkage __visible void __init start_kernel(void)
 	taskstats_init_early();
 	delayacct_init();
 
+	poking_init();
 	check_bugs();
 
 	acpi_subsystem_init();
-- 
2.17.1

