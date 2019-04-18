Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4730C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E115218A1
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E115218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72B376B0293; Thu, 18 Apr 2019 05:07:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B84C6B0295; Thu, 18 Apr 2019 05:07:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 534186B0296; Thu, 18 Apr 2019 05:07:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id F26D06B0293
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:07:10 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id u18so1515810wrp.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:07:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=XYjtgkQ+gRYguATgChHdH9FUUx591xA2t7TyaZHD9QY=;
        b=INmH/8p1hCV9uB0mGwXDBXm1F6vmrGOCvJHYzpz1r2D9te07nWCZH1rl669WFmyb8V
         jm+8pSBPitb1RcOTEruCCSzSweEVoL1FDE48OL7ZlduwvJtGT/k1k1eJeX6tOV4raWdf
         5UQM9m+s5kgC6bHtDWFG4+KpWm/K5woE7VqKycRImqb5sVAt3ElJP9ld/J7xvMXg2AKX
         hJo1rfZxWEBOabKCbKAVdBJn2BATOK9jSwN4B6l/2RsT3aKBcc2+02Ax5NZ5yeijR26g
         olk2v3ZYy5ZCcQ8JtDlKyOhot1oxGfan9eBYSJ2TRJNESP9Eg4KwlUboii0uRTEbvA3W
         VqOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXf768kvMutMSpi3Q6iz8T0XI1jxOflNREjVUIX/om/XbCCIABE
	aeM7e/fqSlzT7jHJdAhXOdCTYxjHxxRu96QUE5toRjDZtvRL0xN5mIfe9e5efIK5y1iPRTg2Z61
	RQofp0sWlJvVjmSB7ae/aPBnMzvz/w++2svJAx3EpaBFe3UMyu+to8xQaE3d+XLa5vQ==
X-Received: by 2002:a1c:5459:: with SMTP id p25mr2205414wmi.20.1555578430371;
        Thu, 18 Apr 2019 02:07:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2ZdrX+v9OFMYOxX/nrU6WkhAz7yysnxn/7LnG+GAlm1fFg8PSNuqZQeKAuTWq3APBcBVr
X-Received: by 2002:a1c:5459:: with SMTP id p25mr2205319wmi.20.1555578428864;
        Thu, 18 Apr 2019 02:07:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578428; cv=none;
        d=google.com; s=arc-20160816;
        b=UK7jGayvBLLixT/opXrz29TFDg1DT9ec9TfsFHsG28tETp+2oNj8rP4A9/Gdm/605r
         SaZ45S5SD3C+jhxqUVw/TSnV2JZiwLPLI6A5HBnGFGXiwsOBBCm9CCahXNx/KudPXSW3
         zxQKZVYHwJB2PRqVkGQGlTDgOoR4q482uEaaQO17yX/ypULdc8lwV84iQPitMi3A9IeG
         c7VhsRi6m2RCTnw/WgKVZ4FwVKPaZWfooqD+erJKE9PyDF+Q+NbFKKlUmj69Pq76y9WY
         YjpGTCsZgnJ8uyhnmuO1aPICkJ2f/NyXZBjOH5O6bGTZTNV/s/baDNeGlY8i+rEVhvmR
         KyoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=XYjtgkQ+gRYguATgChHdH9FUUx591xA2t7TyaZHD9QY=;
        b=yn7r20SIR0tdTUgIxnvNm609XnvGG3OzfXcjmf1dyZZ9gOFZMV6ePMU2V8WwwwnYQo
         iczRcqQcyin8HkmaUq49DfForu34ApY0iF354wVCOwJAxMfFJDSTOUcE+ylPw4A7HQ9G
         Po8KA4o9HCzTh5zCI9+AagGgYRsuVd63hETqE2wLGcwacUfWG6DdOURqXwiVS3EiYb/j
         oG1hfIrTk3XsWR3XyCr5tvrjE+ye5p+5vUZEQyd8XC5qxxielMJCAv/KXxtwz2ZGAs2q
         8l5EqG9wFR0AHwzwKqQZGU0TsJFUj0VCt/aCuLzQ8flg3c2Qk1Z6IPqs8jkrGVg0Xb6N
         C3JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r17si1279230wrq.411.2019.04.18.02.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:07:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30Z-00021L-Q0; Thu, 18 Apr 2019 11:07:04 +0200
Message-Id: <20190418084255.740246383@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:48 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, linux-arch@vger.kernel.org,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>
Subject: [patch V2 29/29] x86/stacktrace: Use common infrastructure
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the stack_trace_save*() functions with the new arch_stack_walk()
interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org
---
 arch/x86/Kconfig             |    1 
 arch/x86/kernel/stacktrace.c |  116 +++++++------------------------------------
 2 files changed, 20 insertions(+), 97 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -74,6 +74,7 @@ config X86
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
+	select ARCH_STACKWALK
 	select ARCH_SUPPORTS_ACPI
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_SUPPORTS_NUMA_BALANCING	if X86_64
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -12,75 +12,31 @@
 #include <asm/stacktrace.h>
 #include <asm/unwind.h>
 
-static int save_stack_address(struct stack_trace *trace, unsigned long addr,
-			      bool nosched)
-{
-	if (nosched && in_sched_functions(addr))
-		return 0;
-
-	if (trace->skip > 0) {
-		trace->skip--;
-		return 0;
-	}
-
-	if (trace->nr_entries >= trace->max_entries)
-		return -1;
-
-	trace->entries[trace->nr_entries++] = addr;
-	return 0;
-}
-
-static void noinline __save_stack_trace(struct stack_trace *trace,
-			       struct task_struct *task, struct pt_regs *regs,
-			       bool nosched)
+void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
+		     struct task_struct *task, struct pt_regs *regs)
 {
 	struct unwind_state state;
 	unsigned long addr;
 
-	if (regs)
-		save_stack_address(trace, regs->ip, nosched);
+	if (regs && !consume_entry(cookie, regs->ip, false))
+		return;
 
 	for (unwind_start(&state, task, regs, NULL); !unwind_done(&state);
 	     unwind_next_frame(&state)) {
 		addr = unwind_get_return_address(&state);
-		if (!addr || save_stack_address(trace, addr, nosched))
+		if (!addr || !consume_entry(cookie, addr, false))
 			break;
 	}
 }
 
 /*
- * Save stack-backtrace addresses into a stack_trace buffer.
+ * This function returns an error if it detects any unreliable features of the
+ * stack.  Otherwise it guarantees that the stack trace is reliable.
+ *
+ * If the task is not 'current', the caller *must* ensure the task is inactive.
  */
-void save_stack_trace(struct stack_trace *trace)
-{
-	trace->skip++;
-	__save_stack_trace(trace, current, NULL, false);
-}
-EXPORT_SYMBOL_GPL(save_stack_trace);
-
-void save_stack_trace_regs(struct pt_regs *regs, struct stack_trace *trace)
-{
-	__save_stack_trace(trace, current, regs, false);
-}
-
-void save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
-{
-	if (!try_get_task_stack(tsk))
-		return;
-
-	if (tsk == current)
-		trace->skip++;
-	__save_stack_trace(trace, tsk, NULL, true);
-
-	put_task_stack(tsk);
-}
-EXPORT_SYMBOL_GPL(save_stack_trace_tsk);
-
-#ifdef CONFIG_HAVE_RELIABLE_STACKTRACE
-
-static int __always_inline
-__save_stack_trace_reliable(struct stack_trace *trace,
-			    struct task_struct *task)
+int arch_stack_walk_reliable(stack_trace_consume_fn consume_entry,
+			     void *cookie, struct task_struct *task)
 {
 	struct unwind_state state;
 	struct pt_regs *regs;
@@ -117,7 +73,7 @@ static int __always_inline
 		if (!addr)
 			return -EINVAL;
 
-		if (save_stack_address(trace, addr, false))
+		if (!consume_entry(cookie, addr, false))
 			return -EINVAL;
 	}
 
@@ -132,32 +88,6 @@ static int __always_inline
 	return 0;
 }
 
-/*
- * This function returns an error if it detects any unreliable features of the
- * stack.  Otherwise it guarantees that the stack trace is reliable.
- *
- * If the task is not 'current', the caller *must* ensure the task is inactive.
- */
-int save_stack_trace_tsk_reliable(struct task_struct *tsk,
-				  struct stack_trace *trace)
-{
-	int ret;
-
-	/*
-	 * If the task doesn't have a stack (e.g., a zombie), the stack is
-	 * "reliably" empty.
-	 */
-	if (!try_get_task_stack(tsk))
-		return 0;
-
-	ret = __save_stack_trace_reliable(trace, tsk);
-
-	put_task_stack(tsk);
-
-	return ret;
-}
-#endif /* CONFIG_HAVE_RELIABLE_STACKTRACE */
-
 /* Userspace stacktrace - based on kernel/trace/trace_sysprof.c */
 
 struct stack_frame_user {
@@ -182,15 +112,15 @@ copy_stack_frame(const void __user *fp,
 	return ret;
 }
 
-static inline void __save_stack_trace_user(struct stack_trace *trace)
+void arch_stack_walk_user(stack_trace_consume_fn consume_entry, void *cookie,
+			  const struct pt_regs *regs)
 {
-	const struct pt_regs *regs = task_pt_regs(current);
 	const void __user *fp = (const void __user *)regs->bp;
 
-	if (trace->nr_entries < trace->max_entries)
-		trace->entries[trace->nr_entries++] = regs->ip;
+	if (!consume_entry(cookie, regs->ip, false))
+		return;
 
-	while (trace->nr_entries < trace->max_entries) {
+	while (1) {
 		struct stack_frame_user frame;
 
 		frame.next_fp = NULL;
@@ -200,8 +130,8 @@ static inline void __save_stack_trace_us
 		if ((unsigned long)fp < regs->sp)
 			break;
 		if (frame.ret_addr) {
-			trace->entries[trace->nr_entries++] =
-				frame.ret_addr;
+			if (!consume_entry(cookie, frame.ret_addr, false))
+				return;
 		}
 		if (fp == frame.next_fp)
 			break;
@@ -209,11 +139,3 @@ static inline void __save_stack_trace_us
 	}
 }
 
-void save_stack_trace_user(struct stack_trace *trace)
-{
-	/*
-	 * Trace user stack if we are not a kernel thread
-	 */
-	if (current->mm)
-		__save_stack_trace_user(trace);
-}


