Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AF84C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC1B0206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC1B0206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0869B6B0272; Thu, 25 Apr 2019 05:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E856B0275; Thu, 25 Apr 2019 05:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA4E26B0274; Thu, 25 Apr 2019 05:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE316B0272
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:38 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b133so5296298wmg.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=g7UiZ86l/rpvc7UwmOSqOho8N206ZA+wIfZ1mTqsix4=;
        b=dOwHq/Ccg9D1jAe2JKQYKCXl9ytLgkUC6ynNuz5P+sTwTuyljylFU0Ybq2YoeMQAUR
         v5zFgJGStctT4vZagJydtJTsBw2IIEFdJJcmfr4SPSTifLPsdo1gL/ppNtw4U90VX+Bf
         sHgr29UaiUkv7wYzaf0rQmNogS8l5mzVOZf6CZQFvU+3K5WbZe+HIcc5SnaIcHBen9tZ
         M/a6byxvGZYXzFrjgboTPDkVFzcl/Oni2s3W0vbHiGWpbuuorkTwa9VhCaYgnXX/vvOP
         B0/9HmCHaGljIlU74Jvkc+1G47PW2zYtoS8jkjYBCKU7fq6Yo4dikRMlkM25ObMrITgH
         sczQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAX/xQXwyu9aKkd2TlMK/rKJx56Bh++iU8xnXMw8byYMQOB1i9bN
	XWbpsr4+zaP6It+mZGK+J/iXC3ajj+7SXzALCa5z8OOi+UO4tocIn7aPXNMIgc5vePyWPMqLypf
	9+vXBsLtbsYAg2pkeCbipaKPRVizet9YT9V15a5T2j+6HJUfPkaZGee3GpEkT/bpG+A==
X-Received: by 2002:a5d:6384:: with SMTP id p4mr24440787wru.208.1556186378092;
        Thu, 25 Apr 2019 02:59:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBoX+UE6w+U6YfOoS/P9hvnyB/diAgb6VIObGq3Ucx2u6+kSPrZG7/85h8yHHnMsrLylXI
X-Received: by 2002:a5d:6384:: with SMTP id p4mr24440718wru.208.1556186376584;
        Thu, 25 Apr 2019 02:59:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186376; cv=none;
        d=google.com; s=arc-20160816;
        b=t9tfNhw2YIMA5DsV+Vd7jgAIMikLnLm5GNPTn1FgLi+dyOwaDaRQiV8VtS7mitDcIb
         l70Abz+d7vESl8+n2I3Hw92ShRMpjWfUfpLBO64AGxg53fNKpQIYl9StyHCkCC0SIIHf
         zQn+pKDvIrxYJKzSfXazEJU6wV63TqGBFdkqK1LizwYMatiK6U0DZMIeXBRMGC0UMa0q
         8I4VW4ijMEhusQWv+3NcWcPmjWTGnrDckxhs0cYU4JzyVMV1EVyn0D2/FVhR90V2DrwT
         A/CFLtmHFR/ubworXnclpMbACVFQnP4lzkszPPmpgZhQDovUZr3AiC+j+JXvNYaxZ+VC
         9DHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=g7UiZ86l/rpvc7UwmOSqOho8N206ZA+wIfZ1mTqsix4=;
        b=ti1O/Bq3E4D07/ElCT0uf6zJXQJEQLFzdJxp5xOG/J2a0M2FuZB7VyfRSXN0ZZ+9D3
         qfVyqmwy+OutP4UbEyR+mDUr5Nv74hx2ZiPsDfhLdInoHWAsCz1zs0j+nDFciyMGUqBo
         A76LwDqwSg8MQEDMYUzDwDXF2RurQI6D5P4DRPb5o6+agzjnzpqWBif1HjZPq42+gPfu
         L5atghAlU/AJW7UDWYV5u/fATRrVeYLGxPAIlDtuqwqeKENf6bEL7LMuU1CWtjJkwsSD
         7k098AT4Q9QKqDBi4c51ol6QWO+Uvu+2FNRHLbaG6z3qdbqQQDbvN6dHK8IEAsr0OnlA
         1kSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b15si14162789wrq.75.2019.04.25.02.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA9-0001vH-Ry; Thu, 25 Apr 2019 11:59:30 +0200
Message-Id: <20190425094802.891724020@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:12 +0200
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
Subject: [patch V3 19/29] lockdep: Simplify stack trace handling
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace by using the storage
array based interfaces and storing the information is a small lockdep
specific data structure.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/lockdep.h  |    9 +++++--
 kernel/locking/lockdep.c |   55 +++++++++++++++++++++++------------------------
 2 files changed, 35 insertions(+), 29 deletions(-)

--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -66,6 +66,11 @@ struct lock_class_key {
 
 extern struct lock_class_key __lockdep_no_validate__;
 
+struct lock_trace {
+	unsigned int		nr_entries;
+	unsigned int		offset;
+};
+
 #define LOCKSTAT_POINTS		4
 
 /*
@@ -100,7 +105,7 @@ struct lock_class {
 	 * IRQ/softirq usage tracking bits:
 	 */
 	unsigned long			usage_mask;
-	struct stack_trace		usage_traces[XXX_LOCK_USAGE_STATES];
+	struct lock_trace		usage_traces[XXX_LOCK_USAGE_STATES];
 
 	/*
 	 * Generation counter, when doing certain classes of graph walking,
@@ -188,7 +193,7 @@ struct lock_list {
 	struct list_head		entry;
 	struct lock_class		*class;
 	struct lock_class		*links_to;
-	struct stack_trace		trace;
+	struct lock_trace		trace;
 	int				distance;
 
 	/*
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -434,18 +434,14 @@ static void print_lockdep_off(const char
 #endif
 }
 
-static int save_trace(struct stack_trace *trace)
+static int save_trace(struct lock_trace *trace)
 {
-	trace->nr_entries = 0;
-	trace->max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
-	trace->entries = stack_trace + nr_stack_trace_entries;
-
-	trace->skip = 3;
-
-	save_stack_trace(trace);
-
-	trace->max_entries = trace->nr_entries;
+	unsigned long *entries = stack_trace + nr_stack_trace_entries;
+	unsigned int max_entries;
 
+	trace->offset = nr_stack_trace_entries;
+	max_entries = MAX_STACK_TRACE_ENTRIES - nr_stack_trace_entries;
+	trace->nr_entries = stack_trace_save(entries, max_entries, 3);
 	nr_stack_trace_entries += trace->nr_entries;
 
 	if (nr_stack_trace_entries >= MAX_STACK_TRACE_ENTRIES-1) {
@@ -1196,7 +1192,7 @@ static struct lock_list *alloc_list_entr
 static int add_lock_to_list(struct lock_class *this,
 			    struct lock_class *links_to, struct list_head *head,
 			    unsigned long ip, int distance,
-			    struct stack_trace *trace)
+			    struct lock_trace *trace)
 {
 	struct lock_list *entry;
 	/*
@@ -1415,6 +1411,13 @@ static inline int __bfs_backwards(struct
  * checking.
  */
 
+static void print_lock_trace(struct lock_trace *trace, unsigned int spaces)
+{
+	unsigned long *entries = stack_trace + trace->offset;
+
+	stack_trace_print(entries, trace->nr_entries, spaces);
+}
+
 /*
  * Print a dependency chain entry (this is only done when a deadlock
  * has been detected):
@@ -1427,8 +1430,7 @@ print_circular_bug_entry(struct lock_lis
 	printk("\n-> #%u", depth);
 	print_lock_name(target->class);
 	printk(KERN_CONT ":\n");
-	print_stack_trace(&target->trace, 6);
-
+	print_lock_trace(&target->trace, 6);
 	return 0;
 }
 
@@ -1740,7 +1742,7 @@ static void print_lock_class_header(stru
 
 			len += printk("%*s   %s", depth, "", usage_str[bit]);
 			len += printk(KERN_CONT " at:\n");
-			print_stack_trace(class->usage_traces + bit, len);
+			print_lock_trace(class->usage_traces + bit, len);
 		}
 	}
 	printk("%*s }\n", depth, "");
@@ -1765,7 +1767,7 @@ print_shortest_lock_dependencies(struct
 	do {
 		print_lock_class_header(entry->class, depth);
 		printk("%*s ... acquired at:\n", depth, "");
-		print_stack_trace(&entry->trace, 2);
+		print_lock_trace(&entry->trace, 2);
 		printk("\n");
 
 		if (depth == 0 && (entry != root)) {
@@ -1878,14 +1880,14 @@ print_bad_irq_dependency(struct task_str
 	print_lock_name(backwards_entry->class);
 	pr_warn("\n... which became %s-irq-safe at:\n", irqclass);
 
-	print_stack_trace(backwards_entry->class->usage_traces + bit1, 1);
+	print_lock_trace(backwards_entry->class->usage_traces + bit1, 1);
 
 	pr_warn("\nto a %s-irq-unsafe lock:\n", irqclass);
 	print_lock_name(forwards_entry->class);
 	pr_warn("\n... which became %s-irq-unsafe at:\n", irqclass);
 	pr_warn("...");
 
-	print_stack_trace(forwards_entry->class->usage_traces + bit2, 1);
+	print_lock_trace(forwards_entry->class->usage_traces + bit2, 1);
 
 	pr_warn("\nother info that might help us debug this:\n\n");
 	print_irq_lock_scenario(backwards_entry, forwards_entry,
@@ -2158,7 +2160,7 @@ check_deadlock(struct task_struct *curr,
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance, struct stack_trace *trace)
+	       struct held_lock *next, int distance, struct lock_trace *trace)
 {
 	struct lock_list *uninitialized_var(target_entry);
 	struct lock_list *entry;
@@ -2196,7 +2198,7 @@ check_prev_add(struct task_struct *curr,
 	this.parent = NULL;
 	ret = check_noncircular(&this, hlock_class(prev), &target_entry);
 	if (unlikely(!ret)) {
-		if (!trace->entries) {
+		if (!trace->nr_entries) {
 			/*
 			 * If save_trace fails here, the printing might
 			 * trigger a WARN but because of the !nr_entries it
@@ -2252,7 +2254,7 @@ check_prev_add(struct task_struct *curr,
 		return print_bfs_bug(ret);
 
 
-	if (!trace->entries && !save_trace(trace))
+	if (!trace->nr_entries && !save_trace(trace))
 		return 0;
 
 	/*
@@ -2284,14 +2286,9 @@ check_prev_add(struct task_struct *curr,
 static int
 check_prevs_add(struct task_struct *curr, struct held_lock *next)
 {
+	struct lock_trace trace = { .nr_entries = 0 };
 	int depth = curr->lockdep_depth;
 	struct held_lock *hlock;
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.max_entries = 0,
-		.entries = NULL,
-		.skip = 0,
-	};
 
 	/*
 	 * Debugging checks.
@@ -2719,6 +2716,10 @@ static inline int validate_chain(struct
 {
 	return 1;
 }
+
+static void print_lock_trace(struct lock_trace *trace, unsigned int spaces)
+{
+}
 #endif
 
 /*
@@ -2815,7 +2816,7 @@ print_usage_bug(struct task_struct *curr
 	print_lock(this);
 
 	pr_warn("{%s} state was registered at:\n", usage_str[prev_bit]);
-	print_stack_trace(hlock_class(this)->usage_traces + prev_bit, 1);
+	print_lock_trace(hlock_class(this)->usage_traces + prev_bit, 1);
 
 	print_irqtrace_events(curr);
 	pr_warn("\nother info that might help us debug this:\n");


