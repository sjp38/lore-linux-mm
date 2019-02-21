Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B692C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDEFF20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:50:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDEFF20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6B658E00C5; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C21728E00B5; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6F108E00C5; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67D048E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w18so313791plq.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=TDi+ZaxaGFwMJnbi/KBZqpgNpblOvtV7DEanhYCdmjY=;
        b=K8N24PormxV+dEH+1jewt9asa2ry96tJ7PU9o7auf5pZC1puP/AwNsUYhd322rsTsP
         YhI+jCWA62EnpqKBuM9PeFMJXy0nGJvJmSaAuycP3DMRo93mozpPk5fQWGGx8Sc7qtnG
         3x4IyYlGa17MufiE95Fdg93Pn4XBHrNdjog7mvYIE60oH4UPVMsnQaV0HzANhHQhBlDc
         v7r3G8YhKosivGYkvsrRzbMuFRKAeOmiJuN+VEyDmGdKIKuCShX3LkgLlL5YjqhGdq79
         QOTqiuKWDiQFrTawWkPtPl/+7qXDf10PQuZKRylTr+de5UcLuBLHlOa3qNjxgZ0WhRX6
         gA2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubld2AqrKVyrFP514Kk6EKtwjm0n1SJPvS3WyDjP/w5sCG9z/a6
	GCMyjbUlcyrY4yLnAPuJGJokUOZfxSAWaDEo6a52qGgHWegtI1CUsUaRU9gUCBsxtqvClP487TO
	fkGr+AFnCcES56on+4qfzBMW+X2KuYwN592CFIgZ+WfFiqcM5AgqxQY4CQ59juLkhHA==
X-Received: by 2002:a63:d442:: with SMTP id i2mr1085375pgj.246.1550793056064;
        Thu, 21 Feb 2019 15:50:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/iv4hBEd8A4TCyrQvuxBfTX9ltVqKMV4Eh9nI0BKqU5r2wPWBqhrxeICsBovhqkeMr23e
X-Received: by 2002:a63:d442:: with SMTP id i2mr1085334pgj.246.1550793055303;
        Thu, 21 Feb 2019 15:50:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793055; cv=none;
        d=google.com; s=arc-20160816;
        b=I27LP6yjhQId7oAdU6YXL6I2aODuMdlDUFDVys+TLu6DBbI5COTyIiyHQM58lA78o6
         OejAAC5Mxydc36cKV0tfaAvEXZuBlxrmvwlmLPaUuXYI4IOJsCHqhpbT+qHvQFLuD1hp
         dabu3oDv64Hkmmvi+jP0AP1Y6l/dH6V8OC8oSMASYZkH5bsmuFEngydYgIcpXdOkk7Yr
         dkvAxPO0aD6f+Uf6V/KWOS3nfsReKoXOIiqsBWSLDi8JxjkxZfZNk1gURthKWwHI3TLQ
         MLPfS2zLdFyGTAU4p9ZvIzeIB63k0sDHTo0EF24ah+wDZ4WLqeLAQpZfDRX4ZxfYu34u
         xakA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=TDi+ZaxaGFwMJnbi/KBZqpgNpblOvtV7DEanhYCdmjY=;
        b=xuBXzVmyKmdDOxT67hglBqAakbjSZ7paXlcx5hDFd2JSafMfo6Ex9BAF6CizxRe0HQ
         mhTMcWbB+IMBoAEsTpLXh6P9fN/fvS0PxHxbkyfs1qCMOD1CsE+69robDS8dHa2YE3kW
         8Mbf4zszisDlmA95Xz10Zei/gQ16mQhfHxP2A4Sn8s9ZPAAiz5wl8RecXdFALwawwPaD
         K9A21DH9bOFOPRt4vtno5yrkZLAnXB/qqFSRFC2mX75IxRVjPXO/SWh5Rh3T87QmG9TE
         vNfOG94XPJZx3tBVwq/+Of8FXOn8ZTXJZBuA1sUN7eFT93kmLRzZSNCTOeCZe4YquYFT
         M4mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:55 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:54 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394811"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:53 -0800
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
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 02/20] x86/mm: Introduce temporary mm structs
Date: Thu, 21 Feb 2019 15:44:33 -0800
Message-Id: <20190221234451.17632-3-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

Using a dedicated page-table for temporary PTEs prevents other cores
from using - even speculatively - these PTEs, thereby providing two
benefits:

(1) Security hardening: an attacker that gains kernel memory writing
abilities cannot easily overwrite sensitive data.

(2) Avoiding TLB shootdowns: the PTEs do not need to be flushed in
remote page-tables.

To do so a temporary mm_struct can be used. Mappings which are private
for this mm can be set in the userspace part of the address-space.
During the whole time in which the temporary mm is loaded, interrupts
must be disabled.

The first use-case for temporary mm struct, which will follow, is for
poking the kernel text.

[ Commit message was written by Nadav Amit ]

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 19d18fae6ec6..d684b954f3c0 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -356,4 +356,37 @@ static inline unsigned long __get_current_cr3_fast(void)
 	return cr3;
 }
 
+typedef struct {
+	struct mm_struct *prev;
+} temp_mm_state_t;
+
+/*
+ * Using a temporary mm allows to set temporary mappings that are not accessible
+ * by other cores. Such mappings are needed to perform sensitive memory writes
+ * that override the kernel memory protections (e.g., W^X), without exposing the
+ * temporary page-table mappings that are required for these write operations to
+ * other cores. Using temporary mm also allows to avoid TLB shootdowns when the
+ * mapping is torn down.
+ *
+ * Context: The temporary mm needs to be used exclusively by a single core. To
+ *          harden security IRQs must be disabled while the temporary mm is
+ *          loaded, thereby preventing interrupt handler bugs from overriding
+ *          the kernel memory protection.
+ */
+static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
+{
+	temp_mm_state_t state;
+
+	lockdep_assert_irqs_disabled();
+	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	switch_mm_irqs_off(NULL, mm, current);
+	return state;
+}
+
+static inline void unuse_temporary_mm(temp_mm_state_t prev)
+{
+	lockdep_assert_irqs_disabled();
+	switch_mm_irqs_off(NULL, prev.prev, current);
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

