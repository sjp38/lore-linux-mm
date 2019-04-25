Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B29F3C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FD032054F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FD032054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796D26B000A; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6777E6B000D; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 540196B000C; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E71966B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q16so20487054wrr.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject;
        bh=x0aLzokmLuHFkgYEpI9soJ/NjAam1o+K4PuCQIcjSLA=;
        b=ctr6wMKDqwYoAHDiQyWyf7Opi+d0fqBl4LlmdbJvu5nAUD6q6UZ8AptfbYd8qyNvrD
         QAoa1Otz6IoPS0gYDz2ZNzORhO9f3JY5c7ej9TYFgXSNrgEk/3P9b+z0OhSyevL8gKHP
         /5gLC8MwqBx0zo00BU5+7WW0l1XYs9MJqVsv5TruM4nrChZ4mDkMh87+6oHd1iWSWW7b
         KWp4ri71MUKbqOoL+6OPRZNXUn+Rswa6qFnblnIwCM6tyh5viTxgyNv8ExYG24HUuMpo
         mU7nEUFmYhSKCbn+2sKCf00bv2GDwDNwlynwuV0xMlanHuIfuONl4F+LR7D8+9QG8CVl
         +Png==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXUo1npU8SxqUXE4cAfJVW6daN7T4u4VZzCoWVw7zgBl2ELYajE
	w2CZ4GT4jHnZwogOY4eh6fUR8Uiqg8cNX3Vfay9229GAPZdEE5+K5ICt7lc6kWlRuq8+9jY0+r9
	FxiZL+KLov9DgdmZ5x+7H2XHGgmUxkSHrEVVnQ5Dj4Xae+dx3+mqI1FRncWYJIu5jkQ==
X-Received: by 2002:adf:dd8e:: with SMTP id x14mr4727879wrl.252.1556186357455;
        Thu, 25 Apr 2019 02:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznTClPPTh34OpwrZlEeOXYu40NnkWnpFWkHBczi1Yyre8ymSmUgjDgU+J/PHsXgMBEdKJE
X-Received: by 2002:adf:dd8e:: with SMTP id x14mr4727809wrl.252.1556186356193;
        Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186356; cv=none;
        d=google.com; s=arc-20160816;
        b=motSKS1wnX3wEYf54lHo24dUzb3C8Ce8OCuskNo/8puiMu0CHinGrwJrPhR050L2PD
         uoC3f0wymTOx+g1DUzsmmwFwbpnP+Ra2+5slPbXvpTJWo2OeqLbIIYPY52h8P1MDRLpZ
         IgoZ0O8F2FOFHrWrkRmW6wDiTkNKZLofT4W6BvECShYQQfRWrPUawxHK9+IuZgHEg/oy
         03iM2VFuwjox335VrQQ3BoJP0K6xw5nMgJmnYrCzzC61+5EME6k9KVD+kMaDfCdeTErD
         gkdgFGMrwmV7gyGjOxV5LB/x+h9hnGQ64HYEuyDfIFnuVD7KOoBQOZPyc5ngfUQZ0L5n
         Nphg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:cc:to:from:date:user-agent:message-id;
        bh=x0aLzokmLuHFkgYEpI9soJ/NjAam1o+K4PuCQIcjSLA=;
        b=NYINZbx7iFqfdIFujgq8a6p7RoPqZcCwYI/u6WTAkQ94LJgwv1mUjmWvaBLq8y8Gsg
         wvaFjJqTZQ3Hf4l1BnGQ/9lHj5EK5m+r4kLJuo60+3wgJtjzc1MTXxQ7XOpQ9KPGOzkc
         73QR5GWkZ0dIzUjEei538sZqy/wkeQkcggF/80aAJ4SAUqKRdukG/aDaR9q/fi+V0UZk
         sVJNSEIgBH/VQsZTqTAetGySDzCcP4FURMKtGJclZLE7SnIzzPU3WJnin9PB3OAV/8ei
         M87sKF4WsYBRfwFCDMWY37oSNPfKPgrYOcz4bRTRwRyPKUWUi5DgDt4ZZ7ub5WdIpE03
         UkWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 96si16584664wrk.397.2019.04.25.02.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9j-0001qT-5s; Thu, 25 Apr 2019 11:59:03 +0200
Message-Id: <20190425094453.875139013@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:44:53 +0200
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
Subject: [patch V3 00/29] stacktrace: Consolidate stack trace usage
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an update to V2 which can be found here:

  https://lkml.kernel.org/r/20190418084119.056416939@linutronix.de

Changes vs. V2:

  - Fixed the kernel-doc issue pointed out by Mike

  - Removed the '-1' oddity from the tracer

  - Restricted the tracer nesting to 4

  - Restored the lockdep magic to prevent redundant stack traces

  - Addressed the small nitpicks here and there

  - Picked up Acked/Reviewed tags

The series is based on:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git core/stacktrace

which contains the removal of the inconsistent and pointless ULONG_MAX
termination of stacktraces.

It's also available from git:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git WIP.core/stacktrace

   up to 5160eb663575 ("x86/stacktrace: Use common infrastructure")

Delta patch vs. v2 below.

Thanks,

	tglx

8<-------------
diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 654949dc1c16..f0cfd12cb45e 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -32,14 +32,13 @@ unsigned int stack_trace_save_user(unsigned long *store, unsigned int size);
  * @reliable:	True when the stack entry is reliable. Required by
  *		some printk based consumers.
  *
- * Returns:	True, if the entry was consumed or skipped
+ * Return:	True, if the entry was consumed or skipped
  *		False, if there is no space left to store
  */
 typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
 				       bool reliable);
 /**
  * arch_stack_walk - Architecture specific function to walk the stack
-
  * @consume_entry:	Callback which is invoked by the architecture code for
  *			each entry.
  * @cookie:		Caller supplied pointer which is handed back to
@@ -47,10 +46,12 @@ typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
  * @task:		Pointer to a task struct, can be NULL
  * @regs:		Pointer to registers, can be NULL
  *
- * @task	@regs:
- * NULL		NULL	Stack trace from current
+ * ============ ======= ============================================
+ * task	        regs
+ * ============ ======= ============================================
  * task		NULL	Stack trace from task (can be current)
- * NULL		regs	Stack trace starting on regs->stackpointer
+ * current	regs	Stack trace starting on regs->stackpointer
+ * ============ ======= ============================================
  */
 void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
 		     struct task_struct *task, struct pt_regs *regs);
diff --git a/kernel/dma/debug.c b/kernel/dma/debug.c
index 1e8e246edaad..badd77670d00 100644
--- a/kernel/dma/debug.c
+++ b/kernel/dma/debug.c
@@ -705,7 +705,8 @@ static struct dma_debug_entry *dma_entry_alloc(void)
 
 #ifdef CONFIG_STACKTRACE
 	entry->stack_len = stack_trace_save(entry->stack_entries,
-					    ARRAY_SIZE(entry->stack_entries), 1);
+					    ARRAY_SIZE(entry->stack_entries),
+					    1);
 #endif
 	return entry;
 }
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 84423f0bb0b0..45bcaf2e4cb6 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2160,12 +2160,11 @@ check_deadlock(struct task_struct *curr, struct held_lock *next,
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance)
+	       struct held_lock *next, int distance, struct lock_trace *trace)
 {
 	struct lock_list *uninitialized_var(target_entry);
 	struct lock_list *entry;
 	struct lock_list this;
-	struct lock_trace trace;
 	int ret;
 
 	if (!hlock_class(prev)->key || !hlock_class(next)->key) {
@@ -2198,8 +2197,17 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	this.class = hlock_class(next);
 	this.parent = NULL;
 	ret = check_noncircular(&this, hlock_class(prev), &target_entry);
-	if (unlikely(!ret))
+	if (unlikely(!ret)) {
+		if (!trace->nr_entries) {
+			/*
+			 * If save_trace fails here, the printing might
+			 * trigger a WARN but because of the !nr_entries it
+			 * should not do bad things.
+			 */
+			save_trace(trace);
+		}
 		return print_circular_bug(&this, target_entry, next, prev);
+	}
 	else if (unlikely(ret < 0))
 		return print_bfs_bug(ret);
 
@@ -2246,7 +2254,7 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 		return print_bfs_bug(ret);
 
 
-	if (!save_trace(&trace))
+	if (!trace->nr_entries && !save_trace(trace))
 		return 0;
 
 	/*
@@ -2255,14 +2263,14 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 	 */
 	ret = add_lock_to_list(hlock_class(next), hlock_class(prev),
 			       &hlock_class(prev)->locks_after,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, trace);
 
 	if (!ret)
 		return 0;
 
 	ret = add_lock_to_list(hlock_class(prev), hlock_class(next),
 			       &hlock_class(next)->locks_before,
-			       next->acquire_ip, distance, &trace);
+			       next->acquire_ip, distance, trace);
 	if (!ret)
 		return 0;
 
@@ -2278,6 +2286,7 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 static int
 check_prevs_add(struct task_struct *curr, struct held_lock *next)
 {
+	struct lock_trace trace = { .nr_entries = 0 };
 	int depth = curr->lockdep_depth;
 	struct held_lock *hlock;
 
@@ -2305,8 +2314,8 @@ check_prevs_add(struct task_struct *curr, struct held_lock *next)
 		 * added:
 		 */
 		if (hlock->read != 2 && hlock->check) {
-			int ret = check_prev_add(curr, hlock, next, distance);
-
+			int ret = check_prev_add(curr, hlock, next, distance,
+						 &trace);
 			if (!ret)
 				return 0;
 
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index 26cc92288cfb..27bafc1e271e 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -39,6 +39,8 @@ EXPORT_SYMBOL_GPL(stack_trace_print);
  * @entries:	Pointer to storage array
  * @nr_entries:	Number of entries in the storage array
  * @spaces:	Number of leading spaces to print
+ *
+ * Return: Number of bytes printed.
  */
 int stack_trace_snprint(char *buf, size_t size, unsigned long *entries,
 			unsigned int nr_entries, int spaces)
@@ -48,7 +50,7 @@ int stack_trace_snprint(char *buf, size_t size, unsigned long *entries,
 	if (WARN_ON(!entries))
 		return 0;
 
-	for (i = 0; i < nr_entries; i++) {
+	for (i = 0; i < nr_entries && size; i++) {
 		generated = snprintf(buf, size, "%*c%pS\n", 1 + spaces, ' ',
 				     (void *)entries[i]);
 
@@ -105,7 +107,7 @@ static bool stack_trace_consume_entry_nosched(void *cookie, unsigned long addr,
  * @size:	Size of the storage array
  * @skipnr:	Number of entries to skip at the start of the stack trace
  *
- * Returns number of entries stored.
+ * Return: Number of trace entries stored.
  */
 unsigned int stack_trace_save(unsigned long *store, unsigned int size,
 			      unsigned int skipnr)
@@ -129,7 +131,7 @@ EXPORT_SYMBOL_GPL(stack_trace_save);
  * @size:	Size of the storage array
  * @skipnr:	Number of entries to skip at the start of the stack trace
  *
- * Returns number of entries stored.
+ * Return: Number of trace entries stored.
  */
 unsigned int stack_trace_save_tsk(struct task_struct *tsk, unsigned long *store,
 				  unsigned int size, unsigned int skipnr)
@@ -156,7 +158,7 @@ unsigned int stack_trace_save_tsk(struct task_struct *tsk, unsigned long *store,
  * @size:	Size of the storage array
  * @skipnr:	Number of entries to skip at the start of the stack trace
  *
- * Returns number of entries stored.
+ * Return: Number of trace entries stored.
  */
 unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
 				   unsigned int size, unsigned int skipnr)
@@ -179,7 +181,7 @@ unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
  *
- * Returns:	An error if it detects any unreliable features of the
+ * Return:	An error if it detects any unreliable features of the
  *		stack. Otherwise it guarantees that the stack trace is
  *		reliable and returns the number of entries stored.
  *
@@ -214,7 +216,7 @@ int stack_trace_save_tsk_reliable(struct task_struct *tsk, unsigned long *store,
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
  *
- * Returns number of entries stored.
+ * Return: Number of trace entries stored.
  */
 unsigned int stack_trace_save_user(unsigned long *store, unsigned int size)
 {
@@ -265,6 +267,8 @@ save_stack_trace_tsk_reliable(struct task_struct *tsk,
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
  * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Return: Number of trace entries stored
  */
 unsigned int stack_trace_save(unsigned long *store, unsigned int size,
 			      unsigned int skipnr)
@@ -286,6 +290,8 @@ EXPORT_SYMBOL_GPL(stack_trace_save);
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
  * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Return: Number of trace entries stored
  */
 unsigned int stack_trace_save_tsk(struct task_struct *task,
 				  unsigned long *store, unsigned int size,
@@ -307,6 +313,8 @@ unsigned int stack_trace_save_tsk(struct task_struct *task,
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
  * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Return: Number of trace entries stored
  */
 unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
 				   unsigned int size, unsigned int skipnr)
@@ -328,7 +336,7 @@ unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
  *
- * Returns:	An error if it detects any unreliable features of the
+ * Return:	An error if it detects any unreliable features of the
  *		stack. Otherwise it guarantees that the stack trace is
  *		reliable and returns the number of entries stored.
  *
@@ -352,6 +360,8 @@ int stack_trace_save_tsk_reliable(struct task_struct *tsk, unsigned long *store,
  * stack_trace_save_user - Save a user space stack trace into a storage array
  * @store:	Pointer to storage array
  * @size:	Size of the storage array
+ *
+ * Return: Number of trace entries stored
  */
 unsigned int stack_trace_save_user(unsigned long *store, unsigned int size)
 {
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 4b6d3e0ebd41..dd00ed3a9473 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2751,15 +2751,15 @@ trace_function(struct trace_array *tr,
 
 #ifdef CONFIG_STACKTRACE
 
-/* 64 entries for kernel stacks are plenty */
-#define FTRACE_KSTACK_ENTRIES	64
+/* Allow 4 levels of nesting: normal, softirq, irq, NMI */
+#define FTRACE_KSTACK_NESTING	4
+
+#define FTRACE_KSTACK_ENTRIES	(PAGE_SIZE / FTRACE_KSTACK_NESTING)
 
 struct ftrace_stack {
 	unsigned long		calls[FTRACE_KSTACK_ENTRIES];
 };
 
-/* This allows 8 level nesting which is plenty */
-#define FTRACE_KSTACK_NESTING	(PAGE_SIZE / sizeof(struct ftrace_stack))
 
 struct ftrace_stacks {
 	struct ftrace_stack	stacks[FTRACE_KSTACK_NESTING];
diff --git a/kernel/trace/trace_stack.c b/kernel/trace/trace_stack.c
index 2fc137f0ee24..031f78b35bae 100644
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -394,7 +394,8 @@ stack_trace_sysctl(struct ctl_table *table, int write,
 		   void __user *buffer, size_t *lenp,
 		   loff_t *ppos)
 {
-	int ret, was_enabled;
+	int was_enabled;
+	int ret;
 
 	mutex_lock(&stack_sysctl_mutex);
 	was_enabled = !!stack_tracer_enabled;
diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index 5936e20cd0a6..605c61f65d94 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -197,7 +197,11 @@ static inline struct stack_record *find_stack(struct stack_record *bucket,
 /**
  * stack_depot_fetch - Fetch stack entries from a depot
  *
+ * @handle:		Stack depot handle which was returned from
+ *			stack_depot_save().
  * @entries:		Pointer to store the entries address
+ *
+ * Return: The number of trace entries for this depot.
  */
 unsigned int stack_depot_fetch(depot_stack_handle_t handle,
 			       unsigned long **entries)
@@ -219,7 +223,7 @@ EXPORT_SYMBOL_GPL(stack_depot_fetch);
  * @nr_entries:		Size of the storage array
  * @alloc_flags:	Allocation gfp flags
  *
- * Returns the handle of the stack struct stored in depot
+ * Return: The handle of the stack struct stored in depot
  */
 depot_stack_handle_t stack_depot_save(unsigned long *entries,
 				      unsigned int nr_entries,

