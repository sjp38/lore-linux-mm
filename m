Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF87EC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AA13206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AA13206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 644166B0280; Thu, 18 Apr 2019 05:06:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B0D56B0281; Thu, 18 Apr 2019 05:06:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 496A86B0282; Thu, 18 Apr 2019 05:06:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E684B6B0280
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so1512006wrs.16
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=Rfp/Jdoj6ynanVHeLJoJ4T7lo4WNyNtoC/3T8RdTRFY=;
        b=QfQ4+24BHKAG5SejbkisrwXMdKKxmNpPGiTjoEh7M1xOy9VmVJBVEG9G9y/iUG0IcK
         vbmWtjGsiVQKWuaXZBGVSQGznQmULTJ0dxevqJpW4uL+G41ThpJ5JtvwtelvB39BWaJs
         kijYOu5d0Zry1rCneV4wwPJK3xpqfXEjcyq+69EVOdRwLNwOLrOWe5bNQfOF/h4jHMza
         9Rm9V/Q3KSlf2NcQBp73uNA44PH5LRkMdri9x8jv98ptGJDvPUFEJc6oJttoSW0fyhdX
         Ict5ITsDLXyPpksgUfHZpUlUPKjpTtqKuXqrxZ5v2a57ZBgX3cSzhgVp1SOwPCm8WM8J
         xDqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVer0jEysQkGw7+qbsodiMAG93b+MRQfHrV/XfdnKooiFAuwrl6
	hngqyzZ/EDkWM+6y5z9ziPMHkTVF07WPkAIQOYvw12XtWGZwMIKIv7UaR2cGTbkeCvlyE/M/Pdw
	MKZEx2HO+5W4IbyhB/hZvTJGFmcj4K+r8UudqRCgfBmqMQdnSFGJPcSqhxIuVYfw22Q==
X-Received: by 2002:a05:600c:24f:: with SMTP id 15mr2131799wmj.48.1555578409429;
        Thu, 18 Apr 2019 02:06:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTY/Uje/Z68lhJp2jw5wPTAHqFg1HqSYzD9QchHqmcjdLzp5+tgcpUJZntfRBjqxPC5dwe
X-Received: by 2002:a05:600c:24f:: with SMTP id 15mr2131750wmj.48.1555578408413;
        Thu, 18 Apr 2019 02:06:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578408; cv=none;
        d=google.com; s=arc-20160816;
        b=ePMGmSKlQSOWIMCEuxSFoq4vO7llOfnR9kO76qQRzt8YoXZV3ib0kz2WNE7zLyCU9v
         ftx7hZKbtxIai1gvr7PKLfRyHI66VxslpP7GfitgJVzBA7q+5m2ABd8NuSZd5RsfR9ml
         H2oIwhhjwUYMsbNyoL1hufod6AyjFJl1X71W/Yj+QUp2243M64md5boVmYx/W80Wvnws
         gZIHGB7is8djwq6V8FK5UBmY3i9wiKOMYY0IAMCnLpqlrENfFiB2S1KDJ1lv5ay7VSXh
         jQuY6CnxtRda9HstusFSUCwR+Gdu9++Q286QGXC700ZpeCwm9UXU+F4CAis0L+6vUiRW
         +8yQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=Rfp/Jdoj6ynanVHeLJoJ4T7lo4WNyNtoC/3T8RdTRFY=;
        b=VqjL1fz7d8YQC/6qc6NE1cX8kh9aoatB93Jxh049qHqrXasY+VeVJjTsGps4VCmWdN
         T4J1z3MfW8vlHZL2pyBGSaSMsD+DbyC+QHAGMlBmTZhnwoMCAeYF0Fdff6yfQIeELT0j
         /HIuk1oxT6HOpiak7y48pz98mHj2itqsod+DlA9o6p/4beI5AhVuhfNOpIKiCnLTGWHz
         lfUYCTjh41OglfCT73wUi9VLavX93LQgZ+lGx+V5L8mxburazn8yZFC0JDwX9L0cBfUy
         xCfOnKIcoAuHy3S2NTtalt3j2OqbRZH32X421oK0fU/l0SgzlXm/BrO3ut4Go3YYGeNs
         V6XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e5si1071172wmh.91.2019.04.18.02.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30G-0001uJ-9j; Thu, 18 Apr 2019 11:06:44 +0200
Message-Id: <20190418084254.999521114@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:40 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
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
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 21/29] tracing: Use percpu stack trace buffer more
 intelligently
References: <20190418084119.056416939@linutronix.de>
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

Split the buffer into chunks of 64 stack entries which is plenty. This
allows nesting contexts (interrupts, exceptions) to utilize the cpu buffer
for stack retrieval and avoids the fixed length allocation along with the
conditional execution pathes.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
 kernel/trace/trace.c |   77 +++++++++++++++++++++++++--------------------------
 1 file changed, 39 insertions(+), 38 deletions(-)

--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2749,12 +2749,21 @@ trace_function(struct trace_array *tr,
 
 #ifdef CONFIG_STACKTRACE
 
-#define FTRACE_STACK_MAX_ENTRIES (PAGE_SIZE / sizeof(unsigned long))
+/* 64 entries for kernel stacks are plenty */
+#define FTRACE_KSTACK_ENTRIES	64
+
 struct ftrace_stack {
-	unsigned long		calls[FTRACE_STACK_MAX_ENTRIES];
+	unsigned long		calls[FTRACE_KSTACK_ENTRIES];
 };
 
-static DEFINE_PER_CPU(struct ftrace_stack, ftrace_stack);
+/* This allows 8 level nesting which is plenty */
+#define FTRACE_KSTACK_NESTING	(PAGE_SIZE / sizeof(struct ftrace_stack))
+
+struct ftrace_stacks {
+	struct ftrace_stack	stacks[FTRACE_KSTACK_NESTING];
+};
+
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
 


