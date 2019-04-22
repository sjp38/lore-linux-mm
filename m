Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34623C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E729D2177B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E729D2177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BBF56B000C; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 386496B0266; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFA1A6B0010; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69E5A6B0007
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j1so8140264pff.1
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=EpX7PmmGjCsoe95ecfJDQVEnFby3S4g+dchtH/l+eVw=;
        b=D+R5Hb8WgvlRCwpAKkQFm63Q+dYdVQv/DyW/JTx86FMxIcBuDjH583RBL7+la4lV0+
         gK89ZRJ3tMjD7yLwgicosvWYRBd1JgxcjBzaeqkUohGufTZVFMzXUQ4J/9E07WM87hk2
         +ij/Chj+1Rf2OlYg3EWje85jRNhsvjfMfiFvbO2H9GbkLPqfSNudHHElzXJaawK+LhjK
         zInqT3K/UEW9/19BgBmYGVIEun4E2LZ1glRlyorXLmmeP8oEUj0RoHtCdqw0KkYN8bcw
         /pD0lsjnQTCQom/3W32eZfnDMA5ekpnFNSyUBlYzBVE6fzXh+YtOAi1PW3n5Hq2Uqcx3
         0Nag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUzMB+vKp4Xzrtc+Lfz69we/Myx7yZJJadwJXtVBqMNYtEGIOVY
	PZyIn6FixGpSirR1kOXkjT3w5+sWm6iQz1qQmorNp7QwU/xJvPA999SZA8U/4BeOmGkE229BqZ6
	BEA/RR/kgZa2BlNSfEMS/dt6kuxARc6rfon3wHnXMObHEwsXQ7mRrWkHkeHWT6bCVkQ==
X-Received: by 2002:a65:524a:: with SMTP id q10mr19741338pgp.224.1555959524039;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzY1F+/tQEbrVRcXdxG71FSOSZ5itmH4sINA/uVENlkFaH6XUIQw3B1VAowhqy13eoDhNR
X-Received: by 2002:a65:524a:: with SMTP id q10mr19741273pgp.224.1555959522814;
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959522; cv=none;
        d=google.com; s=arc-20160816;
        b=X33vT83UW+49Vh5mWDlEZGqwZ6QjkuhXxcGdHD9ABapcMG5VzCp4T2DyMm+9r4Z6EF
         6fRQuPEUOw49F6htp+DcdlRPZOPCVc/DDDMNpFFapeio69OuQja8RdsdIcA+bR014SFn
         9tfpD52TEwsosAR5b6st77E4H2Z7nZFUrHCDc7QNaPEhldyg1puRqir8hKC1o2OV6KV1
         udefRjonZfFtk3s/ObLebZM8U818Oh1ZMsVAUFax8fJn0E5QzWilHj71EG9HmJXJrHr+
         om5HaDC8FrjJImCi5VbJVQBSV5rdliGtMTkvVWtICTBJJI+LHJoX7ZEfCJlmXVCTWMf7
         J1jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=EpX7PmmGjCsoe95ecfJDQVEnFby3S4g+dchtH/l+eVw=;
        b=cxVQ7+mcx6EJOEMR88XkgI18qvXPS6pefxsYyojRdTFjskJEzYFgiwI5yKRw8H3BeT
         zXq/ZhQr7ueld86VlnvBJ2EFSzsRwDFBJpBzLzpHXzAwCTJLP2qD8MmXB6ya5UH/T+Iy
         MIYwt5++zCSgPpF8l986arqRH5gw42y1FGPx3fBc/4Wmknr/3kgz3AMw96FLuLjWOfOR
         JXq+vOYTbrE5ycqasPltKWXb7IocshszIof2SaqNLMMNHV/xbAsozsTZNrkIPtpggZqC
         5iQ+s4MmEdMD5/lww25l7LbliZfK5XXKYe+1QGNLcmpY3DzH6wabjCcvSfwtdKku2K9N
         oUjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417128"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
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
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 04/23] x86/mm: Save DRs when loading a temporary mm
Date: Mon, 22 Apr 2019 11:57:46 -0700
Message-Id: <20190422185805.1169-5-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Prevent user watchpoints from mistakenly firing while the temporary mm
is being used. As the addresses that of the temporary mm might overlap
those of the user-process, this is necessary to prevent wrong signals
or worse things from happening.

Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index d684b954f3c0..81861862038a 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/debugreg.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -380,6 +381,21 @@ static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
 	lockdep_assert_irqs_disabled();
 	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
 	switch_mm_irqs_off(NULL, mm, current);
+
+	/*
+	 * If breakpoints are enabled, disable them while the temporary mm is
+	 * used. Userspace might set up watchpoints on addresses that are used
+	 * in the temporary mm, which would lead to wrong signals being sent or
+	 * crashes.
+	 *
+	 * Note that breakpoints are not disabled selectively, which also causes
+	 * kernel breakpoints (e.g., perf's) to be disabled. This might be
+	 * undesirable, but still seems reasonable as the code that runs in the
+	 * temporary mm should be short.
+	 */
+	if (hw_breakpoint_active())
+		hw_breakpoint_disable();
+
 	return state;
 }
 
@@ -387,6 +403,13 @@ static inline void unuse_temporary_mm(temp_mm_state_t prev)
 {
 	lockdep_assert_irqs_disabled();
 	switch_mm_irqs_off(NULL, prev.prev, current);
+
+	/*
+	 * Restore the breakpoints if they were disabled before the temporary mm
+	 * was loaded.
+	 */
+	if (hw_breakpoint_active())
+		hw_breakpoint_restore();
 }
 
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

