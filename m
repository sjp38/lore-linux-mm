Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B74B9C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66484206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66484206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 283796B027B; Thu, 25 Apr 2019 05:59:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 232036B027C; Thu, 25 Apr 2019 05:59:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1216F6B027D; Thu, 25 Apr 2019 05:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B128F6B027B
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:52 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j5so6771314wrw.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=ByC7dXta38CLHUD8h1047Y83UVgHTC0qMNuuteVS9Z4=;
        b=Lms2pvyxF7iizTQCZTjFCAbd/+xV5pyhoVY7arq+tnc0Y70WHa9N7wkvbfD9REYRe+
         Pq2ypTQ/BSontdPAl03QCugv0x6fo55315VR/MrnCMsJAeSb0tuA13DU4WtItBuEV361
         KzXMh/AxTR7Q/46HiRiQoy8DTVOwwtxvg4e+FB3M6cPGcO6aKSX0a9ww9WEr1EaL2TD9
         OeLc3f46elpX1CsjFJKOJZcpyMlNKhlCd8LxxUjUfXqdRfA8q6+TRtcRN6DQEoRcW4HT
         gBLMuJ1IiwdjKd9XaF17in4xXJkiLsOhIZ7DjpGwOmtb21Fzn+dk32AekKn+fTVsjZYD
         1e0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVjOikihVzNLIBaLjfzJmXKVVPmFyCFUP2n6zz3sy6dYYN+3DPw
	L5tnH8kW5+nHWZOJBRvUjItrKf7e+euOWxs2MqMElULLTgvke0ciqOEuaJL3yq1siQaUG7QvS7P
	K0TOED0dVaGdggYEzu0sYgpe/OXz9+WhfV3WzLEvCMtS801e58aZjmfNkzdGnk5GN0w==
X-Received: by 2002:a05:600c:21d3:: with SMTP id x19mr2825726wmj.2.1556186392209;
        Thu, 25 Apr 2019 02:59:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD/vTx7MKhnpiB4NQGgaFnXQV9+nKWOEr9fHPQwx00sfJ4WFgtSUMzb+GK+Nk2UBPOQhCg
X-Received: by 2002:a05:600c:21d3:: with SMTP id x19mr2825640wmj.2.1556186390609;
        Thu, 25 Apr 2019 02:59:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186390; cv=none;
        d=google.com; s=arc-20160816;
        b=wEEFLP71rIROsMkJm2RTDEkwpUeyvJzmJOtpVboEJM0W39yvirdMNiBRwTFn7C5rdl
         dZaiHV8g2VuctJ/kKSBi4aLxmNGZJv1yk9oS321cLXwG68IwyHPXjqTOfsQtztMW0DOx
         RTSdOeMRbYRxfdFtxZpNmvrnObf4UXFWLv9TH585fLACcb4ugAlT5sfcZL5ZSkjk6kpo
         xESIGw7j0K7zU/noyNaQuivAwHOGOgB5POzwpEf1Qxozjds2KCgvQkQjAh7lX7vk5D7/
         zu0EZbiWKFPoCr0WcayEaJ9AqzySWx3vKYKpJxwOkmA42Ac9BhCf2IJILTFhiE8UU63P
         11hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=ByC7dXta38CLHUD8h1047Y83UVgHTC0qMNuuteVS9Z4=;
        b=nAh2HFLwTjVEBymzYhuwaYIRT8DUAZkztXixgQWhOZkU9HX/Y0de8KS7F5g7tngoNd
         qfny5AKIBeOSjSfm7tpfOFu1g7GnYyb6WfyqmLsZAhwgbiygQD9+wBr5cuwoPW4Y2KBj
         uIuC8IhI9ICoH5wjKssO2xZy3juFD0w5yeT9O0DS0yclZPnRI4RlJT58M8KrlB07HbIO
         +3Kg4w8VQ4CWMsleYPT7+Ss8mMvXyZ4nlSOTl2hdjehUv4i7h2KSYZqggyIKeeD+yXcj
         2FoV9+oAh0vD1WS+/XiTEy4b7Kqk49DaSz8t3mXW2l8cIt8f1jALz15UDuOqHH4GpNpX
         vPOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z17si8177561wrw.327.2019.04.25.02.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAP-00020j-QB; Thu, 25 Apr 2019 11:59:46 +0200
Message-Id: <20190425094803.713568606@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:21 +0200
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
Subject: [patch V3 28/29] stacktrace: Provide common infrastructure
References: <20190425094453.875139013@linutronix.de>
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
V3: Fix kernel doc
---
 include/linux/stacktrace.h |   39 ++++++++++
 kernel/stacktrace.c        |  173 +++++++++++++++++++++++++++++++++++++++++++++
 lib/Kconfig                |    4 +
 3 files changed, 216 insertions(+)

--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -23,6 +23,44 @@ unsigned int stack_trace_save_regs(struc
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
+ * Return:	True, if the entry was consumed or skipped
+ *		False, if there is no space left to store
+ */
+typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
+				       bool reliable);
+/**
+ * arch_stack_walk - Architecture specific function to walk the stack
+ * @consume_entry:	Callback which is invoked by the architecture code for
+ *			each entry.
+ * @cookie:		Caller supplied pointer which is handed back to
+ *			@consume_entry
+ * @task:		Pointer to a task struct, can be NULL
+ * @regs:		Pointer to registers, can be NULL
+ *
+ * ============ ======= ============================================
+ * task	        regs
+ * ============ ======= ============================================
+ * task		NULL	Stack trace from task (can be current)
+ * current	regs	Stack trace starting on regs->stackpointer
+ * ============ ======= ============================================
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
@@ -37,6 +75,7 @@ extern void save_stack_trace_tsk(struct
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
@@ -66,6 +68,175 @@ int stack_trace_snprint(char *buf, size_
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
+ * Return: Number of trace entries stored.
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
+ * Return: Number of trace entries stored.
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
+ * Return: Number of trace entries stored.
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
+ * Return:	An error if it detects any unreliable features of the
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
+ * Return: Number of trace entries stored.
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
@@ -203,3 +374,5 @@ unsigned int stack_trace_save_user(unsig
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


