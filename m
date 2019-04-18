Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78573C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29017218A1
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29017218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D93AE6B0291; Thu, 18 Apr 2019 05:07:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D44BE6B0293; Thu, 18 Apr 2019 05:07:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C335F6B0294; Thu, 18 Apr 2019 05:07:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA156B0291
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:07:07 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id a206so1459436wmh.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:07:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=znZSi+CidEAD+gRTreMBXWZFV8FFXCHidn2vjNkjDi8=;
        b=oy6y2754HHOh8NhtrDq970hwMrhidGv4l9VJVa/l1U3lrNGaZKfXHXE+6Y1K/AU7MF
         X3IAYBvwmyqkeY1nU0h3scrwrgiuYolTl4h4+l8rjcjsLsikpivozM3QWB8ASIkR2ccj
         niBiQy/xZiOwXYnSkT0fh6DmQxb9aWCD4qTN+REG/ojIEAHRZV80ZEjQV0ONw4lzzYtN
         Kc79a0gY34wqmKjZ572dShsf1hoUh1s+HVaiJhXGqR20rVk9VJqsPb4o7L2sx/NPEV7i
         oDmIra4kVssPkW/bWwk8d96SEpjr1unWANudwxpEHy2VUz00NxgoMbu3DkZiFrnaGari
         txmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVv411TQGF8NU+sq+8SDspq3gFQwNOA4XtisoDpLaofQfXsrTfM
	vAu7xPxxLcjauAXTu/QGKGYU96Nso4PUalXicWVbPX6GKzliWJwukYnsJXdW/0K8QDns2dB7WPh
	9x8HJuTfYnXYzIYJRu7R3f32sCY/PFXOAjceWhAnxCUVN5If8rM6kwT6v/qWIcfD4Ww==
X-Received: by 2002:adf:ec0a:: with SMTP id x10mr60169258wrn.193.1555578426940;
        Thu, 18 Apr 2019 02:07:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjiyl907osI3Y/ACe48cly3whHm2x0WohV9yBZB3UKCL0KU/9+IQBh9Hhz7WNZwIxueoCg
X-Received: by 2002:adf:ec0a:: with SMTP id x10mr60169148wrn.193.1555578425295;
        Thu, 18 Apr 2019 02:07:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578425; cv=none;
        d=google.com; s=arc-20160816;
        b=o18jGPpeRRXZQsKzXyEE9V2JQcX68njVHabWS+ydNDNwQs1y0XvkpY3TrlNeKiIswf
         tOJ/AP0j1QTTqedIMx08ddQmpypE5ZPsKOmqnL+/9TbB0JmWfsdFFB/RzIfuG4CiVrWq
         U67JBLCtwIGKKW2xCfeWkOXDH7aR0fhX5eSdaHyH4hdjsGCVe32qHHD6X3NtmmFTtMsn
         9PyHM+NY9fJRT5UsOKx7eaoPSL6Qiq7pT6CWr0CizS6pU80Eg6t/EdhB93Ir0fgMk01W
         we0nyz1gx9MdEo4ia1Me1ivcBDii9Zg1f2y9kTLEzlDOhG5o14VLCTnnzx5M0aHcYrDu
         YEmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=znZSi+CidEAD+gRTreMBXWZFV8FFXCHidn2vjNkjDi8=;
        b=DhhLs2MVUFfXsBrgLutbMZp1ErpLZYShGAT00TNJccSka6F46BZageSaTt/yZykaRK
         s3ZXoxOUzxXerXxGRODZPUFdwIa2A8WchWl9wbRe85qjF0q5Sn5FPRRorKCrcId/H04Q
         g9WO2DOjN0Am2t2AYFLNIFFeTsLHh9QGJaRf1LcF+EfbNZWMrV4IWGSAZEoM6S4WQqgP
         vabKxN+CDsNDU1iI9zkdOnfArBWXn0OFRwNIIFEFguMiW/itsTMzCIWUvXDRCchU3Add
         i+ZFjpSLDV5P4EPQYmueEMnC0rED/yKIJc1tRaMVfE3adu6UR0dtLmEtx5HUHmZ2T+7/
         kpBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l2si1231546wru.10.2019.04.18.02.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:07:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30X-00020X-3n; Thu, 18 Apr 2019 11:07:01 +0200
Message-Id: <20190418084255.652003111@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:47 +0200
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
Subject: [patch V2 28/29] stacktrace: Provide common infrastructure
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All architectures which support stacktrace carry duplicated code and
do the stack storage and filtering at the architecture side.

Provide a consolidated interface with a callback function for consuming the
stack entries provided by the architecture specific stack walker. This
removes lots of duplicated code and allows to implement better filtering
than 'skip number of entries' in the future without touching any
architecture specific code.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org
---
 include/linux/stacktrace.h |   38 +++++++++
 kernel/stacktrace.c        |  173 +++++++++++++++++++++++++++++++++++++++++++++
 lib/Kconfig                |    4 +
 3 files changed, 215 insertions(+)

--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -23,6 +23,43 @@ unsigned int stack_trace_save_regs(struc
 unsigned int stack_trace_save_user(unsigned long *store, unsigned int size);
 
 /* Internal interfaces. Do not use in generic code */
+#ifdef CONFIG_ARCH_STACKWALK
+
+/**
+ * stack_trace_consume_fn - Callback for arch_stack_walk()
+ * @cookie:	Caller supplied pointer handed back by arch_stack_walk()
+ * @addr:	The stack entry address to consume
+ * @reliable:	True when the stack entry is reliable. Required by
+ *		some printk based consumers.
+ *
+ * Returns:	True, if the entry was consumed or skipped
+ *		False, if there is no space left to store
+ */
+typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
+				       bool reliable);
+/**
+ * arch_stack_walk - Architecture specific function to walk the stack
+
+ * @consume_entry:	Callback which is invoked by the architecture code for
+ *			each entry.
+ * @cookie:		Caller supplied pointer which is handed back to
+ *			@consume_entry
+ * @task:		Pointer to a task struct, can be NULL
+ * @regs:		Pointer to registers, can be NULL
+ *
+ * @task	@regs:
+ * NULL		NULL	Stack trace from current
+ * task		NULL	Stack trace from task (can be current)
+ * NULL		regs	Stack trace starting on regs->stackpointer
+ */
+void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
+		     struct task_struct *task, struct pt_regs *regs);
+int arch_stack_walk_reliable(stack_trace_consume_fn consume_entry, void *cookie,
+			     struct task_struct *task);
+void arch_stack_walk_user(stack_trace_consume_fn consume_entry, void *cookie,
+			  const struct pt_regs *regs);
+
+#else /* CONFIG_ARCH_STACKWALK */
 struct stack_trace {
 	unsigned int nr_entries, max_entries;
 	unsigned long *entries;
@@ -37,6 +74,7 @@ extern void save_stack_trace_tsk(struct
 extern int save_stack_trace_tsk_reliable(struct task_struct *tsk,
 					 struct stack_trace *trace);
 extern void save_stack_trace_user(struct stack_trace *trace);
+#endif /* !CONFIG_ARCH_STACKWALK */
 #endif /* CONFIG_STACKTRACE */
 
 #if defined(CONFIG_STACKTRACE) && defined(CONFIG_HAVE_RELIABLE_STACKTRACE)
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -5,6 +5,8 @@
  *
  *  Copyright (C) 2006 Red Hat, Inc., Ingo Molnar <mingo@redhat.com>
  */
+#include <linux/sched/task_stack.h>
+#include <linux/sched/debug.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
 #include <linux/export.h>
@@ -64,6 +66,175 @@ int stack_trace_snprint(char *buf, size_
 }
 EXPORT_SYMBOL_GPL(stack_trace_snprint);
 
+#ifdef CONFIG_ARCH_STACKWALK
+
+struct stacktrace_cookie {
+	unsigned long	*store;
+	unsigned int	size;
+	unsigned int	skip;
+	unsigned int	len;
+};
+
+static bool stack_trace_consume_entry(void *cookie, unsigned long addr,
+				      bool reliable)
+{
+	struct stacktrace_cookie *c = cookie;
+
+	if (c->len >= c->size)
+		return false;
+
+	if (c->skip > 0) {
+		c->skip--;
+		return true;
+	}
+	c->store[c->len++] = addr;
+	return c->len < c->size;
+}
+
+static bool stack_trace_consume_entry_nosched(void *cookie, unsigned long addr,
+					      bool reliable)
+{
+	if (in_sched_functions(addr))
+		return true;
+	return stack_trace_consume_entry(cookie, addr, reliable);
+}
+
+/**
+ * stack_trace_save - Save a stack trace into a storage array
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Returns number of entries stored.
+ */
+unsigned int stack_trace_save(unsigned long *store, unsigned int size,
+			      unsigned int skipnr)
+{
+	stack_trace_consume_fn consume_entry = stack_trace_consume_entry;
+	struct stacktrace_cookie c = {
+		.store	= store,
+		.size	= size,
+		.skip	= skipnr + 1,
+	};
+
+	arch_stack_walk(consume_entry, &c, current, NULL);
+	return c.len;
+}
+EXPORT_SYMBOL_GPL(stack_trace_save);
+
+/**
+ * stack_trace_save_tsk - Save a task stack trace into a storage array
+ * @task:	The task to examine
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Returns number of entries stored.
+ */
+unsigned int stack_trace_save_tsk(struct task_struct *tsk, unsigned long *store,
+				  unsigned int size, unsigned int skipnr)
+{
+	stack_trace_consume_fn consume_entry = stack_trace_consume_entry_nosched;
+	struct stacktrace_cookie c = {
+		.store	= store,
+		.size	= size,
+		.skip	= skipnr + 1,
+	};
+
+	if (!try_get_task_stack(tsk))
+		return 0;
+
+	arch_stack_walk(consume_entry, &c, tsk, NULL);
+	put_task_stack(tsk);
+	return c.len;
+}
+
+/**
+ * stack_trace_save_regs - Save a stack trace based on pt_regs into a storage array
+ * @regs:	Pointer to pt_regs to examine
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Returns number of entries stored.
+ */
+unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
+				   unsigned int size, unsigned int skipnr)
+{
+	stack_trace_consume_fn consume_entry = stack_trace_consume_entry;
+	struct stacktrace_cookie c = {
+		.store	= store,
+		.size	= size,
+		.skip	= skipnr,
+	};
+
+	arch_stack_walk(consume_entry, &c, current, regs);
+	return c.len;
+}
+
+#ifdef CONFIG_HAVE_RELIABLE_STACKTRACE
+/**
+ * stack_trace_save_tsk_reliable - Save task stack with verification
+ * @tsk:	Pointer to the task to examine
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ *
+ * Returns:	An error if it detects any unreliable features of the
+ *		stack. Otherwise it guarantees that the stack trace is
+ *		reliable and returns the number of entries stored.
+ *
+ * If the task is not 'current', the caller *must* ensure the task is inactive.
+ */
+int stack_trace_save_tsk_reliable(struct task_struct *tsk, unsigned long *store,
+				  unsigned int size)
+{
+	stack_trace_consume_fn consume_entry = stack_trace_consume_entry;
+	struct stacktrace_cookie c = {
+		.store	= store,
+		.size	= size,
+	};
+	int ret;
+
+	/*
+	 * If the task doesn't have a stack (e.g., a zombie), the stack is
+	 * "reliably" empty.
+	 */
+	if (!try_get_task_stack(tsk))
+		return 0;
+
+	ret = arch_stack_walk_reliable(consume_entry, &c, tsk);
+	put_task_stack(tsk);
+	return ret;
+}
+#endif
+
+#ifdef CONFIG_USER_STACKTRACE_SUPPORT
+/**
+ * stack_trace_save_user - Save a user space stack trace into a storage array
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ *
+ * Returns number of entries stored.
+ */
+unsigned int stack_trace_save_user(unsigned long *store, unsigned int size)
+{
+	stack_trace_consume_fn consume_entry = stack_trace_consume_entry;
+	struct stacktrace_cookie c = {
+		.store	= store,
+		.size	= size,
+	};
+
+	/* Trace user stack if not a kernel thread */
+	if (!current->mm)
+		return 0;
+
+	arch_stack_walk_user(consume_entry, &c, task_pt_regs(current));
+	return c.len;
+}
+#endif
+
+#else /* CONFIG_ARCH_STACKWALK */
+
 /*
  * Architectures that do not implement save_stack_trace_*()
  * get these weak aliases and once-per-bootup warnings
@@ -193,3 +364,5 @@ unsigned int stack_trace_save_user(unsig
 	return trace.nr_entries;
 }
 #endif /* CONFIG_USER_STACKTRACE_SUPPORT */
+
+#endif /* !CONFIG_ARCH_STACKWALK */
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -597,6 +597,10 @@ config ARCH_HAS_UACCESS_FLUSHCACHE
 config ARCH_HAS_UACCESS_MCSAFE
 	bool
 
+# Temporary. Goes away when all archs are cleaned up
+config ARCH_STACKWALK
+       bool
+
 config STACKDEPOT
 	bool
 	select STACKTRACE


