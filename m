Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6A14C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93A3C218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A3C218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 481366B000E; Thu, 25 Apr 2019 05:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435696B0266; Thu, 25 Apr 2019 05:59:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FC876B000E; Thu, 25 Apr 2019 05:59:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7BE16B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:22 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t9so20481402wrs.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=qnhBsTZhFAarvtIna8uPcw7wy2NCTXLowgukOB6j3ZA=;
        b=GP27ChaGFh8DSu8BXOu212Us5kZlWwMzP9JbnQ777r/FAYqjOwZc9RVUjlZLr/UtF7
         NSoG2xeS9oyQcu3Vx+UgvPNqQmS172U+p+QRhwaPWQW+o5xXo+llEypDXkBjRRLdk/ns
         7m8Lds0bqvFQx1OL9zvnPXwQoyVLOK2HQstT/nWyCSDpEp+9M6wfX5bOnahMrizACMYk
         TJNwzeREbUxFc2wslQR0JVy7d2J1zp9EvG4kEHLWZZQ2l0HYgqJGj6UXQpPmoDMZu0jP
         Z0COc9aMmfyELP25ns6uBKc4GD7XYNvGQxqG4pYFX8XPde+JFW9U1gJMgyL6kFnAxX/7
         LJjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWLeowqYI8iiGp/UahSHXS3qCePcvL4w66wZovfX4Mq9YYjmkLK
	1MTUZi6Lm5ZG1egwsDDBVausNw0SuIqMkmaS/8lBnHdOY1uukrAfmKT1NwDiDWCLql5uWKsgfiW
	rHpQVwZC46ptPAimEMCoKNC2fYLlVu/lYs2JqcRoFFf/PyQ3s/CPXRB+ChredejHtNw==
X-Received: by 2002:adf:eb44:: with SMTP id u4mr12112010wrn.83.1556186362188;
        Thu, 25 Apr 2019 02:59:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxCbpFNPcd2pGB9twG6IwG6oQSx3RfHb0lLox3UO3JCjIY/j0zboBtX6uxJ1bbYFy7hUGY
X-Received: by 2002:adf:eb44:: with SMTP id u4mr12111948wrn.83.1556186360993;
        Thu, 25 Apr 2019 02:59:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186360; cv=none;
        d=google.com; s=arc-20160816;
        b=vx+JISlYZo5kZFePe+UdatRTTe/Zc34TcQNTSsQeBR/PBhiXj7FNDRin9Gkqk/AOVe
         pQSmxxRyeEnFnlCM3+Gad7hI3qGOeGpCNbh2qYJXTB5wAHDO3VfhaW2oyDZ8FieL6kT6
         YZSxy50sUPJEf3Y5H4uqMXAQFVpZiE9v0CuA8rM722gqxsniezopMxR6D9hjzjd/K9wg
         g1CRsYmctgCwdHyBuq+hRIGzuCOXEL6u3Fxde6fDmZPTkg1dlxez9YYwqwxk4a+BzdHy
         9vv4dLlYocaNsBmmiD3myirksOY6dBgBBGGPBcteWyeObG3Z/4VofPHTxE4S0jaKwfXv
         QM6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=qnhBsTZhFAarvtIna8uPcw7wy2NCTXLowgukOB6j3ZA=;
        b=SNwCoyxDXbDQ8OXSe7Fg2feUX0CHkZfCGCwWPF2uIqAZtzAZ7k/u4HSMZrpwFYEbIt
         3MEbYT6vhRZNO/+jKWlZjbNae7/yNto6dyMvS+SBjriZI+Cfgp57jVl7h/h6ajY4LrbF
         z7tGHP5WBjIi/MxR6aK0wLHnWjYRUiIGRUgDp5dHqyCx3IWlKXNUMKG/Kgmf2abIkQjm
         oKRn4/Jrw9EEJ++AzAWl9+fjIve/bDDfHigpH5sJrj5FOKT4GKMQMscNwpe/0hKGvZTx
         gUwRFPyqQPS9ldoHHH/qFwFSZC/7nXvOwERurs42MJ+K4V07EJS4vTIQIY8O6k1NOkvy
         yRmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q124si751090wme.156.2019.04.25.02.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9l-0001qa-F3; Thu, 25 Apr 2019 11:59:05 +0200
Message-Id: <20190425094801.324810708@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:44:55 +0200
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
Subject: [patch V3 02/29] stacktrace: Provide helpers for common stack trace
 operations
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All operations with stack traces are based on struct stack_trace. That's a
horrible construct as the struct is a kitchen sink for input and
output. Quite some usage sites embed it into their own data structures
which creates weird indirections.

There is absolutely no point in doing so. For all use cases a storage array
and the number of valid stack trace entries in the array is sufficient.

Provide helper functions which avoid the struct stack_trace indirection so
the usage sites can be cleaned up.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
V3: Fix kernel doc.
---
 include/linux/stacktrace.h |   27 +++++++
 kernel/stacktrace.c        |  170 +++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 182 insertions(+), 15 deletions(-)

--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -3,11 +3,26 @@
 #define __LINUX_STACKTRACE_H
 
 #include <linux/types.h>
+#include <asm/errno.h>
 
 struct task_struct;
 struct pt_regs;
 
 #ifdef CONFIG_STACKTRACE
+void stack_trace_print(unsigned long *trace, unsigned int nr_entries,
+		       int spaces);
+int stack_trace_snprint(char *buf, size_t size, unsigned long *entries,
+			unsigned int nr_entries, int spaces);
+unsigned int stack_trace_save(unsigned long *store, unsigned int size,
+			      unsigned int skipnr);
+unsigned int stack_trace_save_tsk(struct task_struct *task,
+				  unsigned long *store, unsigned int size,
+				  unsigned int skipnr);
+unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
+				   unsigned int size, unsigned int skipnr);
+unsigned int stack_trace_save_user(unsigned long *store, unsigned int size);
+
+/* Internal interfaces. Do not use in generic code */
 struct stack_trace {
 	unsigned int nr_entries, max_entries;
 	unsigned long *entries;
@@ -41,4 +56,16 @@ extern void save_stack_trace_user(struct
 # define save_stack_trace_tsk_reliable(tsk, trace)	({ -ENOSYS; })
 #endif /* CONFIG_STACKTRACE */
 
+#if defined(CONFIG_STACKTRACE) && defined(CONFIG_HAVE_RELIABLE_STACKTRACE)
+int stack_trace_save_tsk_reliable(struct task_struct *tsk, unsigned long *store,
+				  unsigned int size);
+#else
+static inline int stack_trace_save_tsk_reliable(struct task_struct *tsk,
+						unsigned long *store,
+						unsigned int size)
+{
+	return -ENOSYS;
+}
+#endif
+
 #endif /* __LINUX_STACKTRACE_H */
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -11,35 +11,54 @@
 #include <linux/kallsyms.h>
 #include <linux/stacktrace.h>
 
-void print_stack_trace(struct stack_trace *trace, int spaces)
+/**
+ * stack_trace_print - Print the entries in the stack trace
+ * @entries:	Pointer to storage array
+ * @nr_entries:	Number of entries in the storage array
+ * @spaces:	Number of leading spaces to print
+ */
+void stack_trace_print(unsigned long *entries, unsigned int nr_entries,
+		       int spaces)
 {
-	int i;
+	unsigned int i;
 
-	if (WARN_ON(!trace->entries))
+	if (WARN_ON(!entries))
 		return;
 
-	for (i = 0; i < trace->nr_entries; i++)
-		printk("%*c%pS\n", 1 + spaces, ' ', (void *)trace->entries[i]);
+	for (i = 0; i < nr_entries; i++)
+		printk("%*c%pS\n", 1 + spaces, ' ', (void *)entries[i]);
+}
+EXPORT_SYMBOL_GPL(stack_trace_print);
+
+void print_stack_trace(struct stack_trace *trace, int spaces)
+{
+	stack_trace_print(trace->entries, trace->nr_entries, spaces);
 }
 EXPORT_SYMBOL_GPL(print_stack_trace);
 
-int snprint_stack_trace(char *buf, size_t size,
-			struct stack_trace *trace, int spaces)
+/**
+ * stack_trace_snprint - Print the entries in the stack trace into a buffer
+ * @buf:	Pointer to the print buffer
+ * @size:	Size of the print buffer
+ * @entries:	Pointer to storage array
+ * @nr_entries:	Number of entries in the storage array
+ * @spaces:	Number of leading spaces to print
+ *
+ * Return: Number of bytes printed.
+ */
+int stack_trace_snprint(char *buf, size_t size, unsigned long *entries,
+			unsigned int nr_entries, int spaces)
 {
-	int i;
-	int generated;
-	int total = 0;
+	unsigned int generated, i, total = 0;
 
-	if (WARN_ON(!trace->entries))
+	if (WARN_ON(!entries))
 		return 0;
 
-	for (i = 0; i < trace->nr_entries; i++) {
+	for (i = 0; i < nr_entries && size; i++) {
 		generated = snprintf(buf, size, "%*c%pS\n", 1 + spaces, ' ',
-				     (void *)trace->entries[i]);
+				     (void *)entries[i]);
 
 		total += generated;
-
-		/* Assume that generated isn't a negative number */
 		if (generated >= size) {
 			buf += size;
 			size = 0;
@@ -51,6 +70,14 @@ int snprint_stack_trace(char *buf, size_
 
 	return total;
 }
+EXPORT_SYMBOL_GPL(stack_trace_snprint);
+
+int snprint_stack_trace(char *buf, size_t size,
+			struct stack_trace *trace, int spaces)
+{
+	return stack_trace_snprint(buf, size, trace->entries,
+				   trace->nr_entries, spaces);
+}
 EXPORT_SYMBOL_GPL(snprint_stack_trace);
 
 /*
@@ -77,3 +104,116 @@ save_stack_trace_tsk_reliable(struct tas
 	WARN_ONCE(1, KERN_INFO "save_stack_tsk_reliable() not implemented yet.\n");
 	return -ENOSYS;
 }
+
+/**
+ * stack_trace_save - Save a stack trace into a storage array
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Return: Number of trace entries stored
+ */
+unsigned int stack_trace_save(unsigned long *store, unsigned int size,
+			      unsigned int skipnr)
+{
+	struct stack_trace trace = {
+		.entries	= store,
+		.max_entries	= size,
+		.skip		= skipnr + 1,
+	};
+
+	save_stack_trace(&trace);
+	return trace.nr_entries;
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
+ * Return: Number of trace entries stored
+ */
+unsigned int stack_trace_save_tsk(struct task_struct *task,
+				  unsigned long *store, unsigned int size,
+				  unsigned int skipnr)
+{
+	struct stack_trace trace = {
+		.entries	= store,
+		.max_entries	= size,
+		.skip		= skipnr + 1,
+	};
+
+	save_stack_trace_tsk(task, &trace);
+	return trace.nr_entries;
+}
+
+/**
+ * stack_trace_save_regs - Save a stack trace based on pt_regs into a storage array
+ * @regs:	Pointer to pt_regs to examine
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ * @skipnr:	Number of entries to skip at the start of the stack trace
+ *
+ * Return: Number of trace entries stored
+ */
+unsigned int stack_trace_save_regs(struct pt_regs *regs, unsigned long *store,
+				   unsigned int size, unsigned int skipnr)
+{
+	struct stack_trace trace = {
+		.entries	= store,
+		.max_entries	= size,
+		.skip		= skipnr,
+	};
+
+	save_stack_trace_regs(regs, &trace);
+	return trace.nr_entries;
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
+	struct stack_trace trace = {
+		.entries	= store,
+		.max_entries	= size,
+	};
+	int ret = save_stack_trace_tsk_reliable(tsk, &trace);
+
+	return ret ? ret : trace.nr_entries;
+}
+#endif
+
+#ifdef CONFIG_USER_STACKTRACE_SUPPORT
+/**
+ * stack_trace_save_user - Save a user space stack trace into a storage array
+ * @store:	Pointer to storage array
+ * @size:	Size of the storage array
+ *
+ * Return: Number of trace entries stored
+ */
+unsigned int stack_trace_save_user(unsigned long *store, unsigned int size)
+{
+	struct stack_trace trace = {
+		.entries	= store,
+		.max_entries	= size,
+	};
+
+	save_stack_trace_user(&trace);
+	return trace.nr_entries;
+}
+#endif /* CONFIG_USER_STACKTRACE_SUPPORT */


