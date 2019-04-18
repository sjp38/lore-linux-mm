Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F21C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D5862183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D5862183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 927B26B027B; Thu, 18 Apr 2019 05:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D81F6B027C; Thu, 18 Apr 2019 05:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 704296B027D; Thu, 18 Apr 2019 05:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2E46B027B
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:45 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c8so1527424wru.13
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=rBbw/B8vKuggCTtV3dXjHcZsr7Bz0dXo78wjpzpGLbU=;
        b=PJSOKWmULtJl7zW6xUGwFDCbhYY2BsXF9ouzA9D5NfSzWaAT2XZj4peWDYKzJ4jm2n
         D43+GikEigD44zYU+3LlXuMvfpua0jukzULOacX58vLozZdVKSAnigh3UDNOfua/zHrd
         1bjngggLS7fDlrx3QWQfDycVYmNxKFOPVKBNnRHFrttmeCCa3GdMNcdr+k5KheH/P5DA
         GITcg/go6o4aJr7gcoJoxyla178SrfHdMmDX88Si71JNbRNjMb+Q4kJuUHCOVjjqF+dO
         6g+yfc4Gc510qVq2+VntbY362H3mQXeYtfZxlcoYdwXff7562dpGGjoB5nybe+I1U5J3
         D/9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUD+oaZcpWh9WLxT4eFhbc/HLp3aAGbPemSRCINFwhsNL0NqtcB
	KKG0i5pR4VL061C08rdY6bieTXrlV1/eBz7kXFHpkIhKdRVLg0M4iJ4TUtdS1zu3sXHozwRr2TW
	OF8yxEHGJnT4CqzZ45a9kgOGOBdJYleXzhTjbRex9ZKxxyx3tzLge/YcN0eX4WPqURQ==
X-Received: by 2002:a1c:c504:: with SMTP id v4mr2304875wmf.45.1555578404615;
        Thu, 18 Apr 2019 02:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzT85ANkDDabNj0BL87zPPGuFqg5gsXp+KLsGM+DLcpy9m1Edw+6vqBQLxH0dp/9JU8teDr
X-Received: by 2002:a1c:c504:: with SMTP id v4mr2304773wmf.45.1555578403046;
        Thu, 18 Apr 2019 02:06:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578403; cv=none;
        d=google.com; s=arc-20160816;
        b=d/YM3kYcdEwBOZZc7T8Ww55H7qB7G9qNNUtvZB4A7oi+662DqKzrgjI3dmatVFejiA
         Lw1oTX1Nd8LFzh5LLVsNcEZBwt/M3K33g+3pc1Fn+2gKYiw7aXpHTviwhhwYWFNZxb5K
         fQdHPqciLAauigbK65N/gp6xhpRHV602KeOUm+ZzUH9yL7t7GYtFZO6oh96S9o5PvffF
         RTeGr7Fa2+xS3B8tiqUeMluqFQLUNl/b4clSgLrHRBNPkUfPFfzv8iOXe6YaLbJQC6oC
         A1dX6ROrHnS2CYl99MW1qRho6Ohw87vSD600TUs0bjMhi+1AYUI4lD6qZGNLgxIfwyDv
         Qu5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=rBbw/B8vKuggCTtV3dXjHcZsr7Bz0dXo78wjpzpGLbU=;
        b=J/INp3ATpMxDqLgnXcoEBb4IP3HsZ18YTiFehK9Ol+EBBIw044luHcEQaTmIgwig5G
         lYJEY5bZOgjjOJ0m9nytgXZjT8M72xDFNNCyTalbPMhNbA1UxlWjfrDHbyJUu3ZHBnpk
         9peN0255ve+2/lI6y8upKWlf1mvRrO663NPG3msabQ6o/HM1P6MZOlNmoOZC3LaELR7Z
         3PeaoLOTw6fMpUMWYGAe1wPBUXTxeGOixaWwBXO2+0WNVsPdt20W1BaAMP4dl8k11pNQ
         +mOEyTGotoRS0phCFR92SSHZlcHuYz3pvJ1bdrsVkLp4og3t0vzOyuncepdsyPurAfLm
         DBHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x10si1272799wrp.198.2019.04.18.02.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30B-0001tP-SF; Thu, 18 Apr 2019 11:06:40 +0200
Message-Id: <20190418084254.819500258@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:38 +0200
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
Subject: [patch V2 19/29] lockdep: Simplify stack trace handling
References: <20190418084119.056416939@linutronix.de>
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
---
 include/linux/lockdep.h  |    9 +++++++--
 kernel/locking/lockdep.c |   44 +++++++++++++++++++++++++-------------------
 2 files changed, 32 insertions(+), 21 deletions(-)

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
@@ -2161,9 +2163,9 @@ check_prev_add(struct task_struct *curr,
 	       struct held_lock *next, int distance)
 {
 	struct lock_list *uninitialized_var(target_entry);
-	struct stack_trace trace;
 	struct lock_list *entry;
 	struct lock_list this;
+	struct lock_trace trace;
 	int ret;
 
 	if (!hlock_class(prev)->key || !hlock_class(next)->key) {
@@ -2705,6 +2707,10 @@ static inline int validate_chain(struct
 {
 	return 1;
 }
+
+static void print_lock_trace(struct lock_trace *trace, unsigned int spaces)
+{
+}
 #endif
 
 /*
@@ -2801,7 +2807,7 @@ print_usage_bug(struct task_struct *curr
 	print_lock(this);
 
 	pr_warn("{%s} state was registered at:\n", usage_str[prev_bit]);
-	print_stack_trace(hlock_class(this)->usage_traces + prev_bit, 1);
+	print_lock_trace(hlock_class(this)->usage_traces + prev_bit, 1);
 
 	print_irqtrace_events(curr);
 	pr_warn("\nother info that might help us debug this:\n");


