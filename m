Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB279C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A089206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A089206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ADB06B0277; Thu, 25 Apr 2019 05:59:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2C1D6B0278; Thu, 25 Apr 2019 05:59:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E199F6B0279; Thu, 25 Apr 2019 05:59:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC9D6B0277
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:44 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v5so15998694wru.4
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=iIZ12KmXgTMRqrmPXZq94HRmBBw6/nFl7NjLs7VR6aM=;
        b=KtVKnTzUVhrU7mx0bbJv5nhQwIXkP6VyRhufvZNSojkBIool0Taa9jwPqR7DogSwRb
         GUB7fXQdeqeDs//I50TMvVtM9mGDzbjZpaLNvp5eo8zC8BS+HzoFOyh36fVoV/0dfgyg
         Pw7ZRbJhBT+5/H4JJjw5JaUhFMOCUuJXeIQ1T+9KzZsmD6/tcIzpJkqUOrcwLMX1LYDX
         AmDHZMTK3CJtdhbEfef094PYVtAuX+w4g/KBJLpeoA4wBehH406DvjAqByQEGkR/xH7R
         N3zOuqyZ18/pX2B4S2TH9ifoeSiDjQ4vkmoySR6Zs7GU2sydoqtrSTdAka6U0W/4DRK1
         veVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVHLaGFv7AwunbkbgrYb7i3wLNmO5cAkO1lJWxsmdYTxXPWOdAV
	hKMVn3bm1Br3yieirS0WT/GqVv+1VXxr/4gSWnUvbcARKVEL/UJt7KBGikMUpy+wNy10WB7/1Oc
	niDCM22Vfy+1qAcpihpFNKaNUOWT04avTbBL4YzkU4X5GtkqIfltjLUlVMy3Y/hRoZw==
X-Received: by 2002:a5d:6352:: with SMTP id b18mr10312368wrw.24.1556186384119;
        Thu, 25 Apr 2019 02:59:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNzIQKvx5Wg4AslR95Odf/E5q5/pQyHiOMNJMO4SsLlRLcfU5ow7bY4vT2hgjYr99N63mo
X-Received: by 2002:a5d:6352:: with SMTP id b18mr10312292wrw.24.1556186382786;
        Thu, 25 Apr 2019 02:59:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186382; cv=none;
        d=google.com; s=arc-20160816;
        b=w3nd5d1MyyJgYo8AI5XBLEImMWBuFt6rURXhaw2y+Ido16zVOn6pHm+o1+oE4PbIlS
         zdm0NDK6FGR7JF8+WCCZENei65B5ijzAwRYF9cfDf2zXePA7f4nHPY6Od+mEBhvDYiKo
         9E59/YWpYgtECgSGf7CIW90l3h+XQmhUDMVuQ3yQ/9nrj/vD4oz+s0ZxwHkDPlONaFQj
         uQNbJPvtQ1oLK7dKrVoFwM5eElb4ASStmrs0FE2Whoh3np6bRzDO936H/gNNpItVYE0u
         Nyl+wHaLe5iYcy9atQz5XmM5dQVnIavQDqaL+w9RvwHHgc4RzLWxCy1VSUdEciF9EDLI
         Tzng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=iIZ12KmXgTMRqrmPXZq94HRmBBw6/nFl7NjLs7VR6aM=;
        b=FpQPNYeUVe9pYY6Asq+8M3V1mZQeJbav+H+S4xeZi1Dd4Z4PDk5i1h7OFl5S5Us/fU
         0sMNiIkE6uSm7dWl7W8z7w5uET8usVsDgDkdw2SvHXmbdDBBdjca/mr8/O89fYraugL5
         A4N6E6bMbprcsvSm7NSMFcaJp02YiLThaIiU3debzEe/gyobv/K6fhDD1iet5P7VbuCA
         /ZBze0bo6Pe95DJpU8xwubcDFFjUu/siQposLK+7hG5y3b+WeX2um9O6vwYK10N+PNwT
         juMq9GBZra8PJpxmDHSaTZsrFvaEAoh7UYvIzshxR/pHnztwlFlnPVEmZZtes8PRbewF
         Tl7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a8si798242wrr.413.2019.04.25.02.59.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAI-0001yH-Jz; Thu, 25 Apr 2019 11:59:38 +0200
Message-Id: <20190425094803.340000461@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:17 +0200
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
Subject: [patch V3 24/29] tracing: Remove the last struct stack_trace usage
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Simplify the stack retrieval code by using the storage array based
interface.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
 kernel/trace/trace_stack.c |   37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -23,11 +23,7 @@
 static unsigned long stack_dump_trace[STACK_TRACE_ENTRIES];
 static unsigned stack_trace_index[STACK_TRACE_ENTRIES];
 
-struct stack_trace stack_trace_max = {
-	.max_entries		= STACK_TRACE_ENTRIES,
-	.entries		= &stack_dump_trace[0],
-};
-
+static unsigned int stack_trace_entries;
 static unsigned long stack_trace_max_size;
 static arch_spinlock_t stack_trace_max_lock =
 	(arch_spinlock_t)__ARCH_SPIN_LOCK_UNLOCKED;
@@ -44,10 +40,10 @@ static void print_max_stack(void)
 
 	pr_emerg("        Depth    Size   Location    (%d entries)\n"
 			   "        -----    ----   --------\n",
-			   stack_trace_max.nr_entries);
+			   stack_trace_entries);
 
-	for (i = 0; i < stack_trace_max.nr_entries; i++) {
-		if (i + 1 == stack_trace_max.nr_entries)
+	for (i = 0; i < stack_trace_entries; i++) {
+		if (i + 1 == stack_trace_entries)
 			size = stack_trace_index[i];
 		else
 			size = stack_trace_index[i] - stack_trace_index[i+1];
@@ -93,13 +89,12 @@ static void check_stack(unsigned long ip
 
 	stack_trace_max_size = this_size;
 
-	stack_trace_max.nr_entries = 0;
-	stack_trace_max.skip = 0;
-
-	save_stack_trace(&stack_trace_max);
+	stack_trace_entries = stack_trace_save(stack_dump_trace,
+					       ARRAY_SIZE(stack_dump_trace) - 1,
+					       0);
 
 	/* Skip over the overhead of the stack tracer itself */
-	for (i = 0; i < stack_trace_max.nr_entries; i++) {
+	for (i = 0; i < stack_trace_entries; i++) {
 		if (stack_dump_trace[i] == ip)
 			break;
 	}
@@ -108,7 +103,7 @@ static void check_stack(unsigned long ip
 	 * Some archs may not have the passed in ip in the dump.
 	 * If that happens, we need to show everything.
 	 */
-	if (i == stack_trace_max.nr_entries)
+	if (i == stack_trace_entries)
 		i = 0;
 
 	/*
@@ -126,13 +121,13 @@ static void check_stack(unsigned long ip
 	 * loop will only happen once. This code only takes place
 	 * on a new max, so it is far from a fast path.
 	 */
-	while (i < stack_trace_max.nr_entries) {
+	while (i < stack_trace_entries) {
 		int found = 0;
 
 		stack_trace_index[x] = this_size;
 		p = start;
 
-		for (; p < top && i < stack_trace_max.nr_entries; p++) {
+		for (; p < top && i < stack_trace_entries; p++) {
 			/*
 			 * The READ_ONCE_NOCHECK is used to let KASAN know that
 			 * this is not a stack-out-of-bounds error.
@@ -163,7 +158,7 @@ static void check_stack(unsigned long ip
 			i++;
 	}
 
-	stack_trace_max.nr_entries = x;
+	stack_trace_entries = x;
 
 	if (task_stack_end_corrupted(current)) {
 		print_max_stack();
@@ -265,7 +260,7 @@ static void *
 {
 	long n = *pos - 1;
 
-	if (n >= stack_trace_max.nr_entries)
+	if (n >= stack_trace_entries)
 		return NULL;
 
 	m->private = (void *)n;
@@ -329,7 +324,7 @@ static int t_show(struct seq_file *m, vo
 		seq_printf(m, "        Depth    Size   Location"
 			   "    (%d entries)\n"
 			   "        -----    ----   --------\n",
-			   stack_trace_max.nr_entries);
+			   stack_trace_entries);
 
 		if (!stack_tracer_enabled && !stack_trace_max_size)
 			print_disabled(m);
@@ -339,10 +334,10 @@ static int t_show(struct seq_file *m, vo
 
 	i = *(long *)v;
 
-	if (i >= stack_trace_max.nr_entries)
+	if (i >= stack_trace_entries)
 		return 0;
 
-	if (i + 1 == stack_trace_max.nr_entries)
+	if (i + 1 == stack_trace_entries)
 		size = stack_trace_index[i];
 	else
 		size = stack_trace_index[i] - stack_trace_index[i+1];


