Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AED9C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37FEA206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37FEA206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF8336B0276; Thu, 25 Apr 2019 05:59:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA8B26B0277; Thu, 25 Apr 2019 05:59:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A715D6B0278; Thu, 25 Apr 2019 05:59:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 567876B0276
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:43 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id x9so20463951wrw.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=fAbXkfpdfdNbQ6xUI1nmmQHB0FsWJN2R/uu7ZoH1zKs=;
        b=HvAin2WfFi6+pTYxr+rFkFFFekDiNlfePFJKmAYpUAC17tfo7VnawVFmoVKJfr1Yh/
         XLAvWzyP7Ja9fkH4EoQtDU9xvbPnjUeGiaEGdh/zIZdGbEZ5WllkxMsSsW7fMqwjMVcX
         o0vuA0QvkOJWmDX0M+sgMa+M6syYYPDqPPPOi2K6g6UGAdpEpTzVsdfmgXvI27CPdVed
         AMZxbNxnp5TNriwbHftIm6sedZ67U/hzAuzRX5QI/v5QXzWPVYo7Wet8Rh31O1curG8Q
         8lM+sFwM9vnq+SAcw/ArBLGznIxXctQJ1srLmzS+vkpe5CDsesZESJxcOI7g5wUfHMrr
         wbDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVKzxdKdikJ6PM/LWrypw67SSwKluTbby8bRWBGnuYksP7y5+iO
	o16SzHROaRsqsqFuWJIDSL9oYw2oFK3SMRbFZggMvhfFiLki4LXNNkvq0JqSl8rKlKO6CEj1ln6
	rq9lseKtU85tdsywQHsR57mbt2yESiLRLqw4nuzcBXhqz4LC4YOVQiO4J+yxrCIoPMA==
X-Received: by 2002:a1c:20c1:: with SMTP id g184mr2921965wmg.137.1556186382896;
        Thu, 25 Apr 2019 02:59:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrmk6QkOl8a1haNOV1lLySM6J0WMDERFp/dcAvLNeUYbWo6KGZKlnsMqC/Idi/oF2zRtri
X-Received: by 2002:a1c:20c1:: with SMTP id g184mr2921904wmg.137.1556186381726;
        Thu, 25 Apr 2019 02:59:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186381; cv=none;
        d=google.com; s=arc-20160816;
        b=S8DuZ7SkJHK7CiLIJ8LJbj3BNa9AZvwUgVv7Ec+FtcgZVpB9gPh3m5D5yzFn0705p0
         5vnFXj0WM6Zj/IpyrW2oN2WZi8f3FPfixzo8Q151qoa14CeQd7nXcXXzGbp7cNxYo/Kq
         DKRNaseyXbv8pGE4KkWnhGMR6rKFYzDKHK6ynl87ecljWreqLEPJAxGOjAnW9twKN3TR
         MoCxkb9wYSkwSilMJnFQK7Jr4kJyhrQD53ofw0fWhvzsHOQxajyMndxW4Dk33OK8GW1e
         szQVWcOAE1luB8mnnrNAS926NzOH2j7vOZbsW8ohy5P2gh79JWTeBMnmeCvzBvI1ebhq
         jHkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=fAbXkfpdfdNbQ6xUI1nmmQHB0FsWJN2R/uu7ZoH1zKs=;
        b=FwrtBadm5bnknFsCKkNIijlJKlTlI5A5so7YBNR7F8FRHoiQTvVlW1yPvp8+riFkKH
         PIMAhPnuZBcyD00piSr79+bCj/qlHHU/O1d6ECUYY0QAuTejSOwNBefBvxA2yTxOrJJU
         y5qfYyqsLONOMYeBlPEA6evtlgPj60FCCtzNND0pYRv6p10mIW0lF03NXuhFXKAdxL8f
         zmoEmk2zbYT4DgO40Z2Et4max7QXHWv2dmhCiiMjjim8qFWNgMegiqDaoxKLswZa+ezG
         C8NJ8Tmqz9vNQ90gz8EC319RYPbqFGExDUCH0Y7rGwebSqy5Z9J6brzFinIwuRfRO84B
         yyLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s5si10175807wru.317.2019.04.25.02.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAG-0001xi-T6; Thu, 25 Apr 2019 11:59:37 +0200
Message-Id: <20190425094803.248604594@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:16 +0200
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
Subject: [patch V3 23/29] tracing: Simplify stack trace retrieval
References: <20190425094453.875139013@linutronix.de>
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
Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
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
 


