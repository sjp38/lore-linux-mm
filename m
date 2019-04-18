Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FD6AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 451842183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 451842183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D463D6B0284; Thu, 18 Apr 2019 05:06:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD09A6B0285; Thu, 18 Apr 2019 05:06:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD3F46B0286; Thu, 18 Apr 2019 05:06:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5836B6B0284
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id c8so1527706wru.13
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=lC14wLptSwMX1RfWmgp9otJ/2ZurJIp5t7P26rWm7ME=;
        b=CEPzxhI8RR3IiwMhfHA2aRgKvp1aCocGtgrHOdRtqTUztZB3lnrStEPeWeVy/W5F5C
         73Fjpe8rbDeFFpgyyVTeCiZFTtq6nBqYuOqAfY4NO1QERwGYsZ8EOxoFUmPi/gDCDTuR
         cbjDM5hVDTnIoqxW1EFElezL8+EoCeHB/pLJovTxZnwRuTGxe2brbm+3C+STm12TxiOg
         xu14Y3mZorv10E+Y76uo4ja/s4SQP3oCvQt06KTjl1LFW4JPD1dL7xDxy2gTsuFTsU9o
         XHKHOhXB4N5MSYE4FM8F98GRYDqtgssUxkrpOsxPs6jzhK0UnDGEZ1H7YxvGYYKEzyBf
         fRXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAX9qPcjcvwAruat2IuFeJwtP32XNaEGCf9KjMDC/z45i9pUW6TB
	pUsg/1a6/uL/f3xdjH2C9mJ0uysIFVgjvZlqngPXx6NcMVGquqy23d8jKJKL83H5BH+jdchV1v2
	lUv2FHKdeD85jhV2PINxqcl236l+yK+cAf1lQ4detC6b3mzEYYYNeqTe6lvzG7j4uXQ==
X-Received: by 2002:adf:fa47:: with SMTP id y7mr42802921wrr.27.1555578413789;
        Thu, 18 Apr 2019 02:06:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGkFosDqr4DE+kPsPGvbw/90z+r2rPicUFlanWN1ELw6Mb9wWHpbHrFwSe16MxkOFs7u7T
X-Received: by 2002:adf:fa47:: with SMTP id y7mr42802876wrr.27.1555578412990;
        Thu, 18 Apr 2019 02:06:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578412; cv=none;
        d=google.com; s=arc-20160816;
        b=TgbC+N/xw2njeyujSMcDIFgseHZr+ovhLMHiqjc79EF3zVb3HH5+Jv5/5lbLh+kV1D
         cStDWzbOcd1tg99X/WusW8W1GaeJKzv57JoLfmOrelWJZPmVZnfqHq9WR6MQuXsT9HYz
         7OmaaUcoxQRfEByV2ZhkA/r1/dQWEnsux/URr7ZfIherN6hge2f4B6hC1zFYNHxdw0ks
         7xuMDLQq4ivzCIwJvTqwbrIad31+Np7Cf3O2EDtFaUddWef5J8JqAY/PLEI6goMt10su
         JGS3LQsL3psfrvx5+hK/1VmhS+DtmjBcjPuocro3bcCUvZEe/EnAQ8L24TfdYrmJX5fo
         gbzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=lC14wLptSwMX1RfWmgp9otJ/2ZurJIp5t7P26rWm7ME=;
        b=GBrbYAYwssHCMjpxiIuQfCmxvUyaTCs7+Gv+NvRGTywI0Pm+ifbS5oTNW0lrIxySrt
         nIn3wau2O9D26Zx95Rq0y9fXYmEzxdYpYk8pdyyLmsKMJttYs2Lm/BswE+XCHQuseptb
         0D8PYo5RmI8H+Mc4kjJwRScvTZyGfRAYRSHqEKRvIakoLvpkk8Zwa7Ds0LN28wDKeQYC
         pZMBl/CLLlsuUewWJ0B2DcXLFV9BtvvfNKILBKRtfv2KgqIjsd5iIflkkv+b8OPJA3ts
         76QtCHK23aLhGhV87yfDXZh3F3AzZggrAocpQvaLRblNDmnL3Gp/39FZ6FZLrNKNbZA9
         M/9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y2si1195736wrs.332.2019.04.18.02.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30L-0001w5-1f; Thu, 18 Apr 2019 11:06:49 +0200
Message-Id: <20190418084255.186774860@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:42 +0200
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
Subject: [patch V2 23/29] tracing: Simplify stack trace retrieval
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace by using the storage
array based interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
 kernel/trace/trace.c |   40 +++++++++++++---------------------------
 1 file changed, 13 insertions(+), 27 deletions(-)

--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2774,22 +2774,18 @@ static void __ftrace_trace_stack(struct
 {
 	struct trace_event_call *call = &event_kernel_stack;
 	struct ring_buffer_event *event;
+	unsigned int size, nr_entries;
 	struct ftrace_stack *fstack;
 	struct stack_entry *entry;
-	struct stack_trace trace;
-	int size = FTRACE_KSTACK_ENTRIES;
 	int stackidx;
 
-	trace.nr_entries	= 0;
-	trace.skip		= skip;
-
 	/*
 	 * Add one, for this function and the call to save_stack_trace()
 	 * If regs is set, then these functions will not be in the way.
 	 */
 #ifndef CONFIG_UNWINDER_ORC
 	if (!regs)
-		trace.skip++;
+		skip++;
 #endif
 
 	/*
@@ -2816,28 +2812,24 @@ static void __ftrace_trace_stack(struct
 	barrier();
 
 	fstack = this_cpu_ptr(ftrace_stacks.stacks) + (stackidx - 1);
-	trace.entries		= fstack->calls;
-	trace.max_entries	= FTRACE_KSTACK_ENTRIES;
-
-	if (regs)
-		save_stack_trace_regs(regs, &trace);
-	else
-		save_stack_trace(&trace);
-
-	if (trace.nr_entries > size)
-		size = trace.nr_entries;
+	size = ARRAY_SIZE(fstack->calls);
 
-	size *= sizeof(unsigned long);
+	if (regs) {
+		nr_entries = stack_trace_save_regs(regs, fstack->calls,
+						   size, skip);
+	} else {
+		nr_entries = stack_trace_save(fstack->calls, size, skip);
+	}
 
+	size = nr_entries * sizeof(unsigned long);
 	event = __trace_buffer_lock_reserve(buffer, TRACE_STACK,
 					    sizeof(*entry) + size, flags, pc);
 	if (!event)
 		goto out;
 	entry = ring_buffer_event_data(event);
 
-	memcpy(&entry->caller, trace.entries, size);
-
-	entry->size = trace.nr_entries;
+	memcpy(&entry->caller, fstack->calls, size);
+	entry->size = nr_entries;
 
 	if (!call_filter_check_discard(call, entry, buffer, event))
 		__buffer_unlock_commit(buffer, event);
@@ -2916,7 +2908,6 @@ ftrace_trace_userstack(struct ring_buffe
 	struct trace_event_call *call = &event_user_stack;
 	struct ring_buffer_event *event;
 	struct userstack_entry *entry;
-	struct stack_trace trace;
 
 	if (!(global_trace.trace_flags & TRACE_ITER_USERSTACKTRACE))
 		return;
@@ -2947,12 +2938,7 @@ ftrace_trace_userstack(struct ring_buffe
 	entry->tgid		= current->tgid;
 	memset(&entry->caller, 0, sizeof(entry->caller));
 
-	trace.nr_entries	= 0;
-	trace.max_entries	= FTRACE_STACK_ENTRIES;
-	trace.skip		= 0;
-	trace.entries		= entry->caller;
-
-	save_stack_trace_user(&trace);
+	stack_trace_save_user(entry->caller, FTRACE_STACK_ENTRIES);
 	if (!call_filter_check_discard(call, entry, buffer, event))
 		__buffer_unlock_commit(buffer, event);
 


