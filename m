Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16563C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24A5218CD
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24A5218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B5EC6B027E; Mon, 22 Apr 2019 15:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C736B0280; Mon, 22 Apr 2019 15:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 557E06B0281; Mon, 22 Apr 2019 15:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF166B027E
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l13so8487575pgp.3
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RkWBxdSztj8rR+UGwRQ8u46DAnXrPhDoGJsRNKYizGU=;
        b=VdASqhthpj4VS6NLcapUoEyp6tgrMpSthZKYjHgccMx1zs9VxlLXx+ZtyZfErWCiPZ
         Zj9CIoQlim6lkEIZTkb5HCMfleMIqRdlKc9eBsp2D3kuZ1/fIw4EPGK/XDX97i8ibRf1
         ZIe+Pw3H/HxPehkDQCBurgJl8yasfNP94Y8dH0Gnu7qQx6ttPUZBBIezk3zwIYChNQb8
         Apve4+60o0M9E9247DIcpj7HFPaGtobU6YcvMRxEU2yZJ1cmTCjsAx40yem4JJkvZG6i
         1qPn94kTlFKrIMDdZCFThdL0Rrxbhrp7OK18VYmJwF/lw9Odt+Zde9b0KEYctKc2HodN
         AL+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWZBURu8KrZuhueSTwezR7ECwE4BpdFKZDeUU3kqv8Fl9ROlvCB
	GSDbOfMTX/y4J7PXvV15I6YRKvpe5O8uE4lF6bnm+sxdFjlU/Rp5jlDDy/9/o93fu8vlkO9HCet
	8xTIknHF7/4H3b+UOxXeXfdAnDePrcnl1zez93ambshftJv9zwx336W2jTLEwTdhrHA==
X-Received: by 2002:a63:5c43:: with SMTP id n3mr20180971pgm.163.1555959624770;
        Mon, 22 Apr 2019 12:00:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq8i+iaBrpWDs/gLIxeVTK0hYKvXj0Xhz7MZttV//COV7qyNeh56KMj/Wx0yyU4gX+Xnv2
X-Received: by 2002:a63:5c43:: with SMTP id n3mr20174252pgm.163.1555959523841;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=bv+/fk5bAlNhlK/W930uUylm+AgOV8X+5x7p+fHGO06/5erbxtEG6vufdHSS2pcpeT
         Q/wGFhlhIdMNPdpezQdQ4V0n4RNdilkiDKEyowqyw8QTDSEDsBf8LWDBfpe17ozuC74B
         E8wAV0/X3vhJnG1YzYxUNHCfe/rMy6V8FiqZdxCF9wXjJHFZL4+BEqV7SM9Z0iKtwMOi
         PfQx+B5lcZcpShfFOf21arltXBhicgs0f4rbp7Sd/wIowwTKGOd33jtN3ggClmw1r/RM
         tFyF8v/s5x6CcIDYwQd/3CrkkNNPNZKlmnm3D0zoJ+4ogKN3ybeZOquzVsri9VkkLsDt
         +pfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RkWBxdSztj8rR+UGwRQ8u46DAnXrPhDoGJsRNKYizGU=;
        b=TVSEstu7BVfrf3xqhJDJhG7L0Q5E9CSNKaXl90jUedpMog2Mze/q4UdTd2OW05UgWL
         RRaGq76qWImsem3ZHNGpZMDMk/s7p4bwJnHz7nrJZtrZPFZQV84tHYGvr96Pf+nFwIuA
         f/SWew0vnmAVJqHZxk0ziAX905CDMbquK4yOzu09v6QBpRzLgn+VCNqLEfP4ild+dK2t
         oLW69Mv+3MhmW9MW13VDCDX5avy+1qU2Xq3PKPUjl2b8gb82xkF8vi3OgfvFskstC4p1
         +/ZnSlwQxXg/DGScnaV1aV/No1/T2RI3/m+eV4At6ZuBbksxs7o+IMGWcWeAMfbwhLpT
         Xekw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.43
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
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417155"
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
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 13/23] x86/alternative: Remove the return value of text_poke_*()
Date: Mon, 22 Apr 2019 11:57:55 -0700
Message-Id: <20190422185805.1169-14-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
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
index 3d2b6b6fb20c..18f959975ea0 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -265,7 +265,7 @@ static void __init_or_module add_nops(void *insns, unsigned int len)
 
 extern struct alt_instr __alt_instructions[], __alt_instructions_end[];
 extern s32 __smp_locks[], __smp_locks_end[];
-void *text_poke_early(void *addr, const void *opcode, size_t len);
+void text_poke_early(void *addr, const void *opcode, size_t len);
 
 /*
  * Are we looking at a near JMP with a 1 or 4-byte displacement.
@@ -667,8 +667,8 @@ void __init alternative_instructions(void)
  * instructions. And on the local CPU you need to be protected again NMI or MCE
  * handlers seeing an inconsistent instruction while you patch.
  */
-void *__init_or_module text_poke_early(void *addr, const void *opcode,
-				       size_t len)
+void __init_or_module text_poke_early(void *addr, const void *opcode,
+				      size_t len)
 {
 	unsigned long flags;
 
@@ -691,7 +691,6 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 		 * that causes hangs on some VIA CPUs.
 		 */
 	}
-	return addr;
 }
 
 __ro_after_init struct mm_struct *poking_mm;
@@ -893,7 +892,7 @@ NOKPROBE_SYMBOL(poke_int3_handler);
  *	  replacing opcode
  *	- sync cores
  */
-void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
+void text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 {
 	unsigned char int3 = 0xcc;
 
@@ -935,7 +934,5 @@ void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 	 * the writing of the new instruction.
 	 */
 	bp_patching_in_progress = false;
-
-	return addr;
 }
 
-- 
2.17.1

