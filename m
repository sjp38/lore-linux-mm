Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41D73C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF56E206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF56E206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5A146B0286; Thu, 18 Apr 2019 05:06:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0CB36B0288; Thu, 18 Apr 2019 05:06:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B21EB6B0289; Thu, 18 Apr 2019 05:06:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66DB46B0286
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s1so1515110wrv.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=DRtEoftaP1MWkVAJr4a/HUTjOvVz6lcHG5vvvFjDf40=;
        b=aKzj0TcBAmT0rAt0NhZ/zdNKgcPw1e4wZcuEML3PXdVX4NJ6vnXFJSCRkNgKrIt3JS
         uxjM0hV2ijVPQ8q4NoUPMUFzDF07vFGF9Bw4YbYKmO96DAbD/2/CEtabdmTV46mnbss5
         VqmCzodvlBElnctxcduOtf6En1xeIysh7KIe5hI07nPJ5G9H2sq5EEihADgfNLOHgcfS
         qWHTRl7+7qXiOHv91pkkHGI46V6wk5aIWlPeZK48x0tDCFz3PmpWY2O1mWUPg9jxTfm0
         hLxsEBZ02Ir2QIu39WYstGP9c7ASy5jiNXrHV91FYKo387okJSC349RfvcPPwIESUzUZ
         /G5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAU6BiFQLOoOsLmI6vMu3WYUvLJPkDqVV029SuYhkPH9McMsaDPK
	xnFiKLVQLGdJZb5cQSCw7SqhEOo9HSpWvCf6fZiMjwz3EpTvHfLe2J2v8bsZIDgSRRUG3Q+jUtX
	5gP+xZLFR4NmF8PzNc898Ws0RGL09S57kh5lZ0G9AcDZ+yPRiXDcpLP+QSKDNIh+9NQ==
X-Received: by 2002:a5d:400c:: with SMTP id n12mr23121663wrp.31.1555578415960;
        Thu, 18 Apr 2019 02:06:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6XgwQNgoFeljioqdvoqIANL4JFxyNglLa2wMSdScEBv339rc7ByZZSzTO16AKygLtpx33
X-Received: by 2002:a5d:400c:: with SMTP id n12mr23121607wrp.31.1555578415069;
        Thu, 18 Apr 2019 02:06:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578415; cv=none;
        d=google.com; s=arc-20160816;
        b=pwGAGMOzX1sGal4zAY7A3FTB2igKgY6K2qwxFR8dDJjlTm6lKE3UaOaCq128ffeNPE
         nbqxRSWEF3hWMKjKrKAjWTsuJPIbhOOlMhlE8OSZPTXlja2ni+VA3y7mm73fmzIKZ9ri
         v/4r2iSToLfuJhlbouR6D8FhtiUCNRltyjEL9IQKoknIn9XBPf4IXN35IajF2vSn3A64
         i/WK12vQ+kKPZg14IQmhNUiYE3bxcDvVTPQobuo6cwkKCfHiXaH8RElQov0pEIdHQ485
         UCXTdp14iZ8lz1r9ZH5WdiNZqhg5il2I4/Nh/P//I0veXlifZAAitR3iZQFieOgfkKIT
         fZXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=DRtEoftaP1MWkVAJr4a/HUTjOvVz6lcHG5vvvFjDf40=;
        b=L6a4CB4UPtroh90t+7C2/8uW6hR5Y+01SbwQ6EG27gAxbRyKtJ5ThO84rGMcRi/cTi
         HozMAHc7/NOgoJ+cbJLzEGVrKOfuc47UabVLPAgPNWFwuxReqArVNmZBVqpfrq95VkE9
         pOeWwCbvApDhYt8FSMdk36to4HXdEbbk0YdV0kPRtyl2S78v48br8udvE39QduNzLd8h
         WJcFAW8RYFtwdlZNeKHsyIt6gRVh34NHP7YuyQKmVtuLPevgQ3NHRlYoV9p5X5RWd5rh
         JMO+MMzFqAK6B1ose1Zn6T0ue3DRD5ImOmlGTJRTr7GUhkzo6JvAJCvDsurt4GUF/Xj8
         RnMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z77si1130941wmc.179.2019.04.18.02.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30N-0001wk-9B; Thu, 18 Apr 2019 11:06:51 +0200
Message-Id: <20190418084255.275696472@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:43 +0200
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
Subject: [patch V2 24/29] tracing: Remove the last struct stack_trace usage
References: <20190418084119.056416939@linutronix.de>
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
---
 kernel/trace/trace_stack.c |   42 ++++++++++++++++--------------------------
 1 file changed, 16 insertions(+), 26 deletions(-)

--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -23,16 +23,7 @@
 static unsigned long stack_dump_trace[STACK_TRACE_ENTRIES];
 static unsigned stack_trace_index[STACK_TRACE_ENTRIES];
 
-/*
- * Reserve one entry for the passed in ip. This will allow
- * us to remove most or all of the stack size overhead
- * added by the stack tracer itself.
- */
-struct stack_trace stack_trace_max = {
-	.max_entries		= STACK_TRACE_ENTRIES - 1,
-	.entries		= &stack_dump_trace[0],
-};
-
+static unsigned int stack_trace_entries;
 static unsigned long stack_trace_max_size;
 static arch_spinlock_t stack_trace_max_lock =
 	(arch_spinlock_t)__ARCH_SPIN_LOCK_UNLOCKED;
@@ -49,10 +40,10 @@ static void print_max_stack(void)
 
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
@@ -98,13 +89,12 @@ static void check_stack(unsigned long ip
 
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
@@ -113,7 +103,7 @@ static void check_stack(unsigned long ip
 	 * Some archs may not have the passed in ip in the dump.
 	 * If that happens, we need to show everything.
 	 */
-	if (i == stack_trace_max.nr_entries)
+	if (i == stack_trace_entries)
 		i = 0;
 
 	/*
@@ -131,13 +121,13 @@ static void check_stack(unsigned long ip
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
@@ -168,7 +158,7 @@ static void check_stack(unsigned long ip
 			i++;
 	}
 
-	stack_trace_max.nr_entries = x;
+	stack_trace_entries = x;
 
 	if (task_stack_end_corrupted(current)) {
 		print_max_stack();
@@ -270,7 +260,7 @@ static void *
 {
 	long n = *pos - 1;
 
-	if (n >= stack_trace_max.nr_entries)
+	if (n >= stack_trace_entries)
 		return NULL;
 
 	m->private = (void *)n;
@@ -334,7 +324,7 @@ static int t_show(struct seq_file *m, vo
 		seq_printf(m, "        Depth    Size   Location"
 			   "    (%d entries)\n"
 			   "        -----    ----   --------\n",
-			   stack_trace_max.nr_entries);
+			   stack_trace_entries);
 
 		if (!stack_tracer_enabled && !stack_trace_max_size)
 			print_disabled(m);
@@ -344,10 +334,10 @@ static int t_show(struct seq_file *m, vo
 
 	i = *(long *)v;
 
-	if (i >= stack_trace_max.nr_entries)
+	if (i >= stack_trace_entries)
 		return 0;
 
-	if (i + 1 == stack_trace_max.nr_entries)
+	if (i + 1 == stack_trace_entries)
 		size = stack_trace_index[i];
 	else
 		size = stack_trace_index[i] - stack_trace_index[i+1];


