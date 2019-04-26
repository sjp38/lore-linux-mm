Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D0BCC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9633C208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jRSkWPKF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9633C208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACF576B0005; Sat, 27 Apr 2019 02:43:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A827C6B0006; Sat, 27 Apr 2019 02:43:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FBC16B0008; Sat, 27 Apr 2019 02:43:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5294A6B0005
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z12so3498299pgs.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=2uQh+p4niM1XazCyX0W8SClLNopGSLFeOTKZKD97XRE=;
        b=MLfmDTCFjAK0unw/9p9YdFGERYFscN6J1WTT/q/Ub0fI1DD0hpfwmdGplxSf8W5KSG
         JtpXLcge0XNcGpXligs4OD0NT6bIt6fKMLKR8VVZT2ImVQEOeq9cR4/o6Elg+V1jqcqs
         QFmqVUho1WzTiTiW8ph7+/wVAIsk6u+I9R8ZLp4Q2454QlRl/XSGcDw339cpANFuYZx0
         ZDWN9SoEBrwo24AvKI6sY6GFX1aKl8GR0sEiGz+ts/YP60ec5Wm8u0cEQuFyUlV1WiWy
         k8vI9yN9flXOYrSPfYDA1XXfVZci6+MHrKfJOEc++uXBfBw3cw9fvfZb3kdQNQQ56hIQ
         VLyg==
X-Gm-Message-State: APjAAAXcZlFAh8vME5fKirS0dM36AfNBkjdPr5cY6MldIrW0hOY7xSji
	M5KGjFJJ5Kdfkobx+8SCh4qgJUSLvQtU9hpkhIy0F+o+npcrkdeYy4o/JpKNy5nLqcE0fazci9H
	TbWIdE0G2uGfArfOjqKP1ZhW0j/7r02h1sEQd4LyAHK1nU4GwRu7UhKscocksCNYAvw==
X-Received: by 2002:a62:f24e:: with SMTP id y14mr51417190pfl.209.1556347385979;
        Fri, 26 Apr 2019 23:43:05 -0700 (PDT)
X-Received: by 2002:a62:f24e:: with SMTP id y14mr51417122pfl.209.1556347384892;
        Fri, 26 Apr 2019 23:43:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347384; cv=none;
        d=google.com; s=arc-20160816;
        b=Umtte7N4qPDCYJsU8OPEKA+shf32FsUK3pUYgiKqrFBiqg0ek+Hh/0G4vV9lbKxJcF
         PuytvHWgGKs9ZDi+ToKj6ARoZgs01/sQdfbh1iF+RpubUPFa12XXwzBSFQKK/BCRshjj
         ZcZMxu9jh4VWgqdsCQHzZpIlc3Eec2LD5vmXcLRK8Yy8fCeo25PFXEa6CeGC3Zug03fn
         GDwTJyBCmb6PfF3vDvnE8x4pDc2t2KWExh6ph40Sj0pAqu4KHMNRMKjhvOyQ24M1XLbo
         q67h6ZsyWGvcLT8TkXK2AFDcFwCAIlOf6BLUPbm5KG2i0eexIbffdxVSzRfYE6/nPy54
         xWDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=2uQh+p4niM1XazCyX0W8SClLNopGSLFeOTKZKD97XRE=;
        b=NUcHWn08ZyDLl+V59p7WFA3jWtgWJbSzLu06pkXiNP8U5MXaqX1zGLGhsBwYsbnHyJ
         6s52i8PS4r2CaDb/+GI8KO+hcCcayzEBMmnD8n3qLG844+7/8WgTu4oCUoSVlyKvCMtI
         12GmR5eVWEMQrvKrNMNIlkvIIUHNTl9W2cfm1cps4VQrzZpwbSwGYHb26JX/pZCUTGy7
         ROXFk6ZAhKufbV/m4m9m/Y9ptohU3LvJeN+UVlt4Mcud8SHDz8cCM33+VGd1u1Ul6S74
         whjdtHLJPkfvhKgpujB453uBpHIy8dbOiCQ6S6M2NCLK4zi7Y9vAawcuNHx7m3v52yij
         BFJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jRSkWPKF;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p66sor30592729pfp.35.2019.04.26.23.43.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jRSkWPKF;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=2uQh+p4niM1XazCyX0W8SClLNopGSLFeOTKZKD97XRE=;
        b=jRSkWPKFy+aX307nFA9nwPtBSyUtI3Rx2wzXkDoawmNR9EBxnEgbgOuHqpJlUzURZT
         sV7k69m+oa16kaqF4hrYU8VlNGgLedRPtIQMrWtFfI1lYATZNKlBhFfYsdwu71vQpo8l
         4hsC4E1OYjLOCvcQc0ZNw7818nwUnGdICNM7KZF/Pj8oVL04L5HnrLC4hGuv9gcmfZac
         QEF3y8KkPlAdKQa7pk8VGNHlHNoii/EZVaGEr6IiXqB8Q9AYGmnR5/+s61lipbxEVDy4
         WVZil8tiOMGEBeIN6IOofRQtzUr/x76R5xEihGyGfY+KVuW7UGM6aZN17saLTTNxIC81
         Y9Xg==
X-Google-Smtp-Source: APXvYqxfDuRpBbYxO71iQgRCpp9YwcxdysZGYp8xW7ZBvNhCbiRnBK6qmFG1IHuGhuou8D2zduF20Q==
X-Received: by 2002:a62:26c1:: with SMTP id m184mr12194274pfm.102.1556347384381;
        Fri, 26 Apr 2019 23:43:04 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:03 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v6 01/24] Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
Date: Fri, 26 Apr 2019 16:22:40 -0700
Message-Id: <20190426232303.28381-2-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

text_mutex is currently expected to be held before text_poke() is
called, but kgdb does not take the mutex, and instead *supposedly*
ensures the lock is not taken and will not be acquired by any other core
while text_poke() is running.

The reason for the "supposedly" comment is that it is not entirely clear
that this would be the case if gdb_do_roundup is zero.

Create two wrapper functions, text_poke() and text_poke_kgdb(), which do
or do not run the lockdep assertion respectively.

While we are at it, change the return code of text_poke() to something
meaningful. One day, callers might actually respect it and the existing
BUG_ON() when patching fails could be removed. For kgdb, the return
value can actually be used.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Fixes: 9222f606506c ("x86/alternatives: Lockdep-enforce text_mutex in text_poke*()")
Suggested-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Jiri Kosina <jkosina@suse.cz>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/text-patching.h |  1 +
 arch/x86/kernel/alternative.c        | 52 ++++++++++++++++++++--------
 arch/x86/kernel/kgdb.c               | 11 +++---
 3 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index e85ff65c43c3..f8fc8e86cf01 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -35,6 +35,7 @@ extern void *text_poke_early(void *addr, const void *opcode, size_t len);
  * inconsistent instruction while you patch.
  */
 extern void *text_poke(void *addr, const void *opcode, size_t len);
+extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
 extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 9a79c7808f9c..0a814d73547a 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -679,18 +679,7 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 	return addr;
 }
 
-/**
- * text_poke - Update instructions on a live kernel
- * @addr: address to modify
- * @opcode: source of the copy
- * @len: length to copy
- *
- * Only atomic text poke/set should be allowed when not doing early patching.
- * It means the size must be writable atomically and the address must be aligned
- * in a way that permits an atomic write. It also makes sure we fit on a single
- * page.
- */
-void *text_poke(void *addr, const void *opcode, size_t len)
+static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
 	unsigned long flags;
 	char *vaddr;
@@ -703,8 +692,6 @@ void *text_poke(void *addr, const void *opcode, size_t len)
 	 */
 	BUG_ON(!after_bootmem);
 
-	lockdep_assert_held(&text_mutex);
-
 	if (!core_kernel_text((unsigned long)addr)) {
 		pages[0] = vmalloc_to_page(addr);
 		pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
@@ -733,6 +720,43 @@ void *text_poke(void *addr, const void *opcode, size_t len)
 	return addr;
 }
 
+/**
+ * text_poke - Update instructions on a live kernel
+ * @addr: address to modify
+ * @opcode: source of the copy
+ * @len: length to copy
+ *
+ * Only atomic text poke/set should be allowed when not doing early patching.
+ * It means the size must be writable atomically and the address must be aligned
+ * in a way that permits an atomic write. It also makes sure we fit on a single
+ * page.
+ */
+void *text_poke(void *addr, const void *opcode, size_t len)
+{
+	lockdep_assert_held(&text_mutex);
+
+	return __text_poke(addr, opcode, len);
+}
+
+/**
+ * text_poke_kgdb - Update instructions on a live kernel by kgdb
+ * @addr: address to modify
+ * @opcode: source of the copy
+ * @len: length to copy
+ *
+ * Only atomic text poke/set should be allowed when not doing early patching.
+ * It means the size must be writable atomically and the address must be aligned
+ * in a way that permits an atomic write. It also makes sure we fit on a single
+ * page.
+ *
+ * Context: should only be used by kgdb, which ensures no other core is running,
+ *	    despite the fact it does not hold the text_mutex.
+ */
+void *text_poke_kgdb(void *addr, const void *opcode, size_t len)
+{
+	return __text_poke(addr, opcode, len);
+}
+
 static void do_sync_core(void *info)
 {
 	sync_core();
diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
index 4ff6b4cdb941..2b203ee5b879 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -759,13 +759,13 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 	if (!err)
 		return err;
 	/*
-	 * It is safe to call text_poke() because normal kernel execution
+	 * It is safe to call text_poke_kgdb() because normal kernel execution
 	 * is stopped on all cores, so long as the text_mutex is not locked.
 	 */
 	if (mutex_is_locked(&text_mutex))
 		return -EBUSY;
-	text_poke((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
-		  BREAK_INSTR_SIZE);
+	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
+		       BREAK_INSTR_SIZE);
 	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
 	if (err)
 		return err;
@@ -784,12 +784,13 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 	if (bpt->type != BP_POKE_BREAKPOINT)
 		goto knl_write;
 	/*
-	 * It is safe to call text_poke() because normal kernel execution
+	 * It is safe to call text_poke_kgdb() because normal kernel execution
 	 * is stopped on all cores, so long as the text_mutex is not locked.
 	 */
 	if (mutex_is_locked(&text_mutex))
 		goto knl_write;
-	text_poke((void *)bpt->bpt_addr, bpt->saved_instr, BREAK_INSTR_SIZE);
+	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
+		       BREAK_INSTR_SIZE);
 	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
 	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
 		goto knl_write;
-- 
2.17.1

