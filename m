Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 943E9C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D822206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D822206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9CBA6B0275; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B816F6B0276; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6E366B0277; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8586B0275
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id w9so2409174wmc.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=vMJ6lIE+mW5bTpuFqwrQHdPM8CwRJaic0N+RE5m4tOc=;
        b=bAkq05bG7Qv1QAJlCJ4Yiez4Rr25r1gfTvufpWsrDjo6ZoN8D3W3RHj90AEgv6IF2E
         c/Y58+wYpx2jrLBUunHHUp++NHkqAhZqs5UnSvDGcDwbRepVAJeDZVKQL5ujXeK7jriP
         XBWCzKKjAVFwT67UAFne6MKABmbMa2NkL8RjkfSSfRWAU/4gq+rfb6VZMtcPW04/4S/6
         0f/Z6eSxE4k0wcU/wtu5v15Y385DCxJSto4tz/fbsYE3RJTjfsJIWuOTqDvTokURR/Xz
         x/+yboEE9/3m2zfcQFEd6aB1vWDrsXws/h3TvHg+rxFSCmcIJs2N3xGxVUWeLMnheuko
         KbrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV9x7ewrl07leANhgH3irvOVJQD+scHRHmR6qEGa3N5Zi/NHLV1
	OtdiLZG8cGXTvVQ9FWoVyB/gy5BBg29VcpTbHrnY4Hpu3bAsaAKPK8Oq6/lvFKeXaSzhuwLAlg3
	fqelklm5JNP9i6nUPPKzMoMCRImT4Fz5V+sh2xLXnxxldUy3azzQ4LIGtUnvpNmNqrg==
X-Received: by 2002:a1c:1903:: with SMTP id 3mr2798396wmz.103.1556186380885;
        Thu, 25 Apr 2019 02:59:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWxpFy3AsLx/y72G3P8vSU57shnLvN98gtGQMGmQwJI6+ZkoFBC9SDBdiFASn3l8XViB/4
X-Received: by 2002:a1c:1903:: with SMTP id 3mr2798336wmz.103.1556186379911;
        Thu, 25 Apr 2019 02:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186379; cv=none;
        d=google.com; s=arc-20160816;
        b=waY0mz2JaCBlskcWgqakysNwxB2kqRvxRoizJlkb0iXwR+abwFhu0Ii6VIYD93uihC
         cUQngwtbBxd9BMCcm92qMcV/YG3Y68WSJ/DgevNjCNOthK60JjIB6DvbEoD7XPspysYn
         DyPfpMU3WTlZjWJ9lPYulIuZiiSMCnB6FlYV1uMKZkQk21eM7VcIjS/PEO9pAuohkJaX
         ChaqNppzWJuapI0JR5+WDioVgv78geXsDnxEEoULf2c34WFuY6mJ3ZNFz15qS3mZzWwm
         yjlASqUiXRrI64pTccfS13QVNVa1yKSWgfDyotJmKe2HfpQ+EaxJICOuEyY+3xJr5KtD
         nJpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=vMJ6lIE+mW5bTpuFqwrQHdPM8CwRJaic0N+RE5m4tOc=;
        b=tjd5A2By8w2IKNwwDsa19kLI+dDgp1jF/+3u7izLfHAY6mD+4PFbm/B1Y/MDnxZiau
         vz5gC4iQn0/uBTMETHrLkzYqG4gtdiRKv5dKY4pALESd3CRapsv5C7F4wLU7cF+IuBQt
         TDLIdnRgtOstOrDKWqDd5g3CfzHlqgv1alOZHHJujkMDjzy794UE9WqjpX91l8M0w1Qd
         pMgHWI8HLTD2CkyC3aIGL9kxPXEEmRPXt1SH3iX2CbdT8/HwZ9wuC2iWwtsVZT2bin1Z
         IvEZkiuLdQ8G2/CozKJrEiwOi/ronlyLDSmQAOKlrlgQEt/xLT7gzDAoCh7KaBtOsG28
         Kr+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x184si14896500wmg.6.2019.04.25.02.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAD-0001wo-Fc; Thu, 25 Apr 2019 11:59:33 +0200
Message-Id: <20190425094803.066064076@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:14 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
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
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 21/29] tracing: Use percpu stack trace buffer more
 intelligently
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The per cpu stack trace buffer usage pattern is odd at best. The buffer has
place for 512 stack trace entries on 64-bit and 1024 on 32-bit. When
interrupts or exceptions nest after the per cpu buffer was acquired the
stacktrace length is hardcoded to 8 entries. 512/1024 stack trace entries
in kernel stacks are unrealistic so the buffer is a complete waste.

Split the buffer into 4 nest levels, which are 128/256 entries per
level. This allows nesting contexts (interrupts, exceptions) to utilize the
cpu buffer for stack retrieval and avoids the fixed length allocation along
with the conditional execution pathes.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
V3: Limit to 4 nest levels and increase size per level.
---
 kernel/trace/trace.c |   77 +++++++++++++++++++++++++--------------------------
 1 file changed, 39 insertions(+), 38 deletions(-)

--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2749,12 +2749,21 @@ trace_function(struct trace_array *tr,
 
 #ifdef CONFIG_STACKTRACE
 
-#define FTRACE_STACK_MAX_ENTRIES (PAGE_SIZE / sizeof(unsigned long))
+/* Allow 4 levels of nesting: normal, softirq, irq, NMI */
+#define FTRACE_KSTACK_NESTING	4
+
+#define FTRACE_KSTACK_ENTRIES	(PAGE_SIZE / FTRACE_KSTACK_NESTING)
+
 struct ftrace_stack {
-	unsigned long		calls[FTRACE_STACK_MAX_ENTRIES];
+	unsigned long		calls[FTRACE_KSTACK_ENTRIES];
+};
+
+
+struct ftrace_stacks {
+	struct ftrace_stack	stacks[FTRACE_KSTACK_NESTING];
 };
 
-static DEFINE_PER_CPU(struct ftrace_stack, ftrace_stack);
+static DEFINE_PER_CPU(struct ftrace_stacks, ftrace_stacks);
 static DEFINE_PER_CPU(int, ftrace_stack_reserve);
 
 static void __ftrace_trace_stack(struct ring_buffer *buffer,
@@ -2763,10 +2772,11 @@ static void __ftrace_trace_stack(struct
 {
 	struct trace_event_call *call = &event_kernel_stack;
 	struct ring_buffer_event *event;
+	struct ftrace_stack *fstack;
 	struct stack_entry *entry;
 	struct stack_trace trace;
-	int use_stack;
-	int size = FTRACE_STACK_ENTRIES;
+	int size = FTRACE_KSTACK_ENTRIES;
+	int stackidx;
 
 	trace.nr_entries	= 0;
 	trace.skip		= skip;
@@ -2788,29 +2798,32 @@ static void __ftrace_trace_stack(struct
 	 */
 	preempt_disable_notrace();
 
-	use_stack = __this_cpu_inc_return(ftrace_stack_reserve);
+	stackidx = __this_cpu_inc_return(ftrace_stack_reserve);
+
+	/* This should never happen. If it does, yell once and skip */
+	if (WARN_ON_ONCE(stackidx >= FTRACE_KSTACK_NESTING))
+		goto out;
+
 	/*
-	 * We don't need any atomic variables, just a barrier.
-	 * If an interrupt comes in, we don't care, because it would
-	 * have exited and put the counter back to what we want.
-	 * We just need a barrier to keep gcc from moving things
-	 * around.
+	 * The above __this_cpu_inc_return() is 'atomic' cpu local. An
+	 * interrupt will either see the value pre increment or post
+	 * increment. If the interrupt happens pre increment it will have
+	 * restored the counter when it returns.  We just need a barrier to
+	 * keep gcc from moving things around.
 	 */
 	barrier();
-	if (use_stack == 1) {
-		trace.entries		= this_cpu_ptr(ftrace_stack.calls);
-		trace.max_entries	= FTRACE_STACK_MAX_ENTRIES;
-
-		if (regs)
-			save_stack_trace_regs(regs, &trace);
-		else
-			save_stack_trace(&trace);
-
-		if (trace.nr_entries > size)
-			size = trace.nr_entries;
-	} else
-		/* From now on, use_stack is a boolean */
-		use_stack = 0;
+
+	fstack = this_cpu_ptr(ftrace_stacks.stacks) + (stackidx - 1);
+	trace.entries		= fstack->calls;
+	trace.max_entries	= FTRACE_KSTACK_ENTRIES;
+
+	if (regs)
+		save_stack_trace_regs(regs, &trace);
+	else
+		save_stack_trace(&trace);
+
+	if (trace.nr_entries > size)
+		size = trace.nr_entries;
 
 	size *= sizeof(unsigned long);
 
@@ -2820,19 +2833,7 @@ static void __ftrace_trace_stack(struct
 		goto out;
 	entry = ring_buffer_event_data(event);
 
-	memset(&entry->caller, 0, size);
-
-	if (use_stack)
-		memcpy(&entry->caller, trace.entries,
-		       trace.nr_entries * sizeof(unsigned long));
-	else {
-		trace.max_entries	= FTRACE_STACK_ENTRIES;
-		trace.entries		= entry->caller;
-		if (regs)
-			save_stack_trace_regs(regs, &trace);
-		else
-			save_stack_trace(&trace);
-	}
+	memcpy(&entry->caller, trace.entries, size);
 
 	entry->size = trace.nr_entries;
 


