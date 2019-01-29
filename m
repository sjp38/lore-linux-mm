Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFF89C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:40:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4C592177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:40:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4C592177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 556068E0002; Mon, 28 Jan 2019 19:40:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 504D78E0001; Mon, 28 Jan 2019 19:40:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41B9E8E0002; Mon, 28 Jan 2019 19:40:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F20178E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:40:45 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so12640062pgv.23
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:40:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=9618xtgXUZ8Ek1wm3UNb4fJDvCUikNkBQc6KAG864pg=;
        b=PqUchcSkoHXgLa2F6rSIUQLXQoKo+P/ycu5z24LeowLrsel6rUwn06Y0R48oT3Dh1T
         ELqr1eO/0zPKbUMaD5soBBYQfJkOrlLLIGVHI8v787EuFvvxlg3VOd7hjJXzxlTursJa
         BNY2POKduL7Fj33mbvjyEZNAxjUt5iAhrjz9wRsrG32iX8Ws2P1nE8M5H9DB0vhNIVGb
         noz0ymBVxd+ux/avvT4qIsJmtO9UKzG2mPs7Li0kU3FPupr6ti/ljXf+mT+t7sYSSKXa
         IjzFjJg9Q7ntHenbdgL364TNMYxHjRbRj3DiAAdoB+ycCh3dXcZlHZ1BRQKt/yi4mvN5
         1BVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfj5IfG8v2xdW96BS3Sp/y4WHdRsmyP8xU8W4f+gWFbOhwINo5W
	pWxJQQCDaGJJMuxBk3/FWigDORvEhAbrM/c6+yb2RifhLAPTEzviEPAqeGQRrjov/3OuPzsccsx
	Hkuwz2UTNIeqwlLcBz19fOSpeRN+pQdIrOYVpNUumAf1WPeFBhGHV1CWhDG3WK9V77A==
X-Received: by 2002:a62:9f1b:: with SMTP id g27mr23311351pfe.87.1548722445642;
        Mon, 28 Jan 2019 16:40:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5iI6amSwTGwJbLBEOH1oe08f84a01Z1ups8g49tB4v8QSP79plwyyao2jCgURN5W1eDvWm
X-Received: by 2002:a62:9f1b:: with SMTP id g27mr23306610pfe.87.1548722353321;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=cRvVn2QOHrVfduEpwC8o4zvTF3fGigPAfWFQBTdsfq56l3hp91QFerkop9qnEKh0c2
         ZqJYS1nVvtIyyKhflZWYWI6V/fOMM7imh1y+XwGyelKv8BJvLKbBd78+Tni0H6xDleNR
         fGvqJYhWrgXqQNjW3CkyAvy/Jd003IPmSkRTixVLXC+7MQKnpmrwY76nMFsGGn8DUJ7S
         dMbG2AiByP2IYIgCldkQePpx/pR8ieSQgullWvvM2wpkJPoI+lB9ea6nwHKbU0mI9COk
         xPDHOSvlAdvzJcbfOxYI0Mcxf9A+5Pdvngs2gmts40D/V0eeGbIl+quqzQCpXnluhkEN
         qh9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=9618xtgXUZ8Ek1wm3UNb4fJDvCUikNkBQc6KAG864pg=;
        b=xTaZmmL4A/gOybMIKTDWf4fxl2MrjNyrSIYEFYqeAdEjtalI/jZBgCCvvD3kmTCS7x
         EzRzTAhJ+8dCF+3rjqlbEFWDTVeMyanwNGOj8rQe9dwtl/Pn6jBE2rpTzxWk0aFhf8UE
         2BEaAKHa54SneqxRkCmXywo1UeOVfLMz/pZYmOb8cCU5RRYEafni+QbyuIYxJzpHX/0/
         w50OqRtk2Qvi1FcmOTZ5TtS65i3scTMZ5g7n1E81Dch2s3J4UnCz3FN7ouJ0J2AiEne6
         VCdUMA0fIs9Yz8qTb5mdHyi9pn+WcTcZ3L9PxJC96QNEMklqRephbOfeQ6F5RCQHEl4W
         Anng==
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
   d="scan'208";a="133921919"
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
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 12/20] x86/alternative: Remove the return value of text_poke_*()
Date: Mon, 28 Jan 2019 16:34:14 -0800
Message-Id: <20190129003422.9328-13-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

The return value of text_poke_early() and text_poke_bp() is useless.
Remove it.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/text-patching.h |  4 ++--
 arch/x86/kernel/alternative.c        | 11 ++++-------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index a75eed841eed..c90678fd391a 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -18,7 +18,7 @@ static inline void apply_paravirt(struct paravirt_patch_site *start,
 #define __parainstructions_end	NULL
 #endif
 
-extern void *text_poke_early(void *addr, const void *opcode, size_t len);
+extern void text_poke_early(void *addr, const void *opcode, size_t len);
 
 /*
  * Clear and restore the kernel write-protection flag on the local CPU.
@@ -37,7 +37,7 @@ extern void *text_poke_early(void *addr, const void *opcode, size_t len);
 extern void *text_poke(void *addr, const void *opcode, size_t len);
 extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
-extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
+extern void text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
 extern __ro_after_init struct mm_struct *poking_mm;
 extern __ro_after_init unsigned long poking_addr;
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 69f3e650ada8..81876e3ef3fd 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -264,7 +264,7 @@ static void __init_or_module add_nops(void *insns, unsigned int len)
 
 extern struct alt_instr __alt_instructions[], __alt_instructions_end[];
 extern s32 __smp_locks[], __smp_locks_end[];
-void *text_poke_early(void *addr, const void *opcode, size_t len);
+void text_poke_early(void *addr, const void *opcode, size_t len);
 
 /*
  * Are we looking at a near JMP with a 1 or 4-byte displacement.
@@ -666,8 +666,8 @@ void __init alternative_instructions(void)
  * instructions. And on the local CPU you need to be protected again NMI or MCE
  * handlers seeing an inconsistent instruction while you patch.
  */
-void *__init_or_module text_poke_early(void *addr, const void *opcode,
-				       size_t len)
+void __init_or_module text_poke_early(void *addr, const void *opcode,
+				      size_t len)
 {
 	unsigned long flags;
 
@@ -690,7 +690,6 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 		 * that causes hangs on some VIA CPUs.
 		 */
 	}
-	return addr;
 }
 
 __ro_after_init struct mm_struct *poking_mm;
@@ -890,7 +889,7 @@ int poke_int3_handler(struct pt_regs *regs)
  *	  replacing opcode
  *	- sync cores
  */
-void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
+void text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 {
 	unsigned char int3 = 0xcc;
 
@@ -932,7 +931,5 @@ void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 	 * the writing of the new instruction.
 	 */
 	bp_patching_in_progress = false;
-
-	return addr;
 }
 
-- 
2.17.1

