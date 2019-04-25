Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B8A9C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:01:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCBEB218FE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:01:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCBEB218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBC506B027C; Thu, 25 Apr 2019 05:59:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6AD26B027D; Thu, 25 Apr 2019 05:59:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B59E46B027E; Thu, 25 Apr 2019 05:59:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6511B6B027C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:54 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u18so8588276wrq.2
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=XYjtgkQ+gRYguATgChHdH9FUUx591xA2t7TyaZHD9QY=;
        b=H9s7hDqgjY0zavmFN3p5MWezgcQfHhihtoqqvzbdUiRkv1Jw6k1RM7wDrRJ7maSwJ4
         zkRLm2LiuQ7h+rvysh9ScsiPq7mwXfV9VMhood558ZYqQnykDwno3zq5r24HtALLmIHt
         PvK7E+fD0BGH0340FQdKYlr0W8/L01bxo43ACRv5JW9KLtgvgsnY49j09mW7c96uIgwz
         DvBvkMCCcIpJQIUYMJwQBofnzEDKlINKxLDtpYexwnDAtVJ3bOvHXOm+tZ80MgO/MG0q
         EnwOep44GYqr08FiibNjJotZlILTERtFcrplBwnNv96FT0q4Mwb2UEfeEj0KfTDSZz8q
         /tPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXfBi35D6iVqV0GeEBt/HanoBrXX/djQTLpLGBP6UxXY0lxMuWZ
	zVSngLnvLK1l5p7ctlAZt01dn4YVL1VyZkeZnxO/SqungqRvad5agXvTBPhwTwPwGS6kGTb2USg
	g8qVGmLShpyvzCUqM8XPyj/545mCduA24Wd5XqebLqtxllL48g3AvL9tIrz+C7NJ7Kg==
X-Received: by 2002:adf:c002:: with SMTP id z2mr26160124wre.177.1556186393937;
        Thu, 25 Apr 2019 02:59:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgssI0YM3P9mNxtsk+0TMqofQzix8pDLZDxdTTpHDNoYPBzqYvIo7/PwoCoPdEv/wuS0Nj
X-Received: by 2002:adf:c002:: with SMTP id z2mr26160016wre.177.1556186392173;
        Thu, 25 Apr 2019 02:59:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186392; cv=none;
        d=google.com; s=arc-20160816;
        b=AaON6M82y1o8HKA7fbnAX22nyzrU1OGsQ1XbXGdvCIban+5x930W4Hw+qqwohvIsPy
         g2xyIdZI6Z2frayWz8Rm5NcmXJ8uFWIgVQ/Iv4+VC84+zsbBx5vEKD7oKF443p36JbHc
         wzU29de0WOsx5NGmxZgctKi8/FMoC19F5dHuf0fp06eSexZH95RZnLOf9kmfMEiZCw76
         DSfv/1XrZ3XMYx5O9WDdLr4dxmgLvQreLdshccAOEpZGbtxxVhMI49Eeo8WXBguutyb1
         UXhnwUuJZNPK/qa5CL6HeXfLZG9ga+ZDIi/BlIKYMLFIoBSQSsYmA3W2RuwonhV82s0C
         LpQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=XYjtgkQ+gRYguATgChHdH9FUUx591xA2t7TyaZHD9QY=;
        b=vXcY0/m91lp4oC/l2PlIesi1asbKNKflvb0JOo4cmAhl3Pzpalp4Wzjp77AElyH5/F
         p9XFqf/wr1Ub4k9xbthKHz5aQwlUWlF4UJKrj/ovXrPZMlhBIvloJ9cBBPveb/xJZsPZ
         YmWtROV+LX1nMCwh1Yi/u8fSBrHH4yb9LvyD2TBQ5WjQ+sdurdsvBiZ8wNbGfjfotHzK
         z+XSAc5H+EeBB2lCgeJNj46erFOBpejVCc4PNCa4UObBAG2yyqW9KPN6F1kjS7mQqfrP
         Fl0G7Z8otdWyIrF6BlcllrnDTTX46CMx8U+chXIebli4TJ7JfV9u0eVqS8r3JYwS/sB+
         T2Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q13si16412095wrf.218.2019.04.25.02.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAR-00021P-Dx; Thu, 25 Apr 2019 11:59:47 +0200
Message-Id: <20190425094803.816485461@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:22 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, linux-arch@vger.kernel.org,
 Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, Christoph Hellwig <hch@lst.de>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>
Subject: [patch V3 29/29] x86/stacktrace: Use common infrastructure
References: <20190425094453.875139013@linutronix.de>
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


