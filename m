Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D42C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D143B21900
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D143B21900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DA116B0010; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B4F36B0269; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 628ED6B026B; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16B446B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v5so8962417wrn.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=SWVpljAJlRyQ2pHyFaFTM+iox7zGbwrS4ZeDsD0I3io=;
        b=ZL9obtIn6YUeObRdRwhGBnGy2NncQGA5DT0aWFkGs3uZ9TTIffpWypB1ANmqjXhrXf
         rQ1ol6s+ZkJQ2naguiQe2wOsNrUeqEpHcufP8um+E5+o4rm7E1Xr8tnCRRNaqga5jGpn
         l6BfuS7TkuqcmiHBGUzfPsDw/ulRiMVB4mVR18hCe+GHHWhmuqXg+qloVELBTThXQRbG
         DctN62q4XJq0K1+/hjMwda/6h9vyE9DjifYKBBrA7+aUYELmqwroXldDj6difZg99kh5
         +odxGptrUALyvFs3oo+HIq2bg5sb173Sfdu3XU0VA5vPkwpe6hGGY+YK/0jThpuhftYP
         zW3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVFKyZfpHi1x5+9LSnYqi5rHhZEzL8JSenydZKtN2vUJyIgTLJX
	MmIR1cAGUpKB0Stu2jjEYXWZW1yZeG/TvVPRp2NnJr6KDGipAX9x40GmRIHYj0T7OQQIIncjorB
	qVwANoSxIYjl9/ei5r+Uu89MXt2LZX4xHZFoh0xRjXj9wSNhfLTGHK+yLATa2qeriXg==
X-Received: by 2002:adf:fc49:: with SMTP id e9mr3375271wrs.269.1556186363592;
        Thu, 25 Apr 2019 02:59:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEMupvkbuHcmSzDr8dpYNQp787ulhyEbeowOEDQ6690XkNIRfbN2JRf4xggMXft4WCRjKd
X-Received: by 2002:adf:fc49:: with SMTP id e9mr3375197wrs.269.1556186362100;
        Thu, 25 Apr 2019 02:59:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186362; cv=none;
        d=google.com; s=arc-20160816;
        b=dqfMrLfdM22gYXqQccKhsgjuon1PesisGt8OGNYR8j+LDfnh1XMxsrdg9nQ3/SYr+o
         SrX9BRahKygl6oVNnFhsUOHZI/6/0PKL5hicKja/7B3uBPXCJaf43UgJzyO5atTWrdze
         1qgp9AfIPAsOLoqy6sylLERRGKzAjrowMGkQ0iLzFT/H3u+kkFj2ASEW1V2gMDx7fLiW
         kJheN3zwkyA7qedfYBbDnX49cXaZfaNgqmjhsExeK2tN39EQ1g45ctCiSs/SMfS0/U+A
         r+V87tg9Wic1O1KztqzjO7l86JDxY/Qhe9omYOUqRjBenW7p2VYaZww9LNs/nIH5owsG
         skvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=SWVpljAJlRyQ2pHyFaFTM+iox7zGbwrS4ZeDsD0I3io=;
        b=UZxyLEzhUJs7dhoe82gVIC1wtRQlBkajUmv8sd2kpthcB31uCY8uDS0nvQqciixdCB
         viYADMwbu3WbqHiT4eMg9jP84eaKvgrDmRsFZYCTPLYLVGYTMA3m2BihxP7DqF3FpUGs
         tYmfxIugfB6zhVfy0v4GYx0gDI4rqXPt8z1G8DODyJKylIehuvBbVdkKTQUlvLbot+w2
         xSBU5hgJ6Qmi9OUd3+GQSTOrldQgDo1PFIR2XasOpeJe49KIrTf3SVJprwnz6VMzrrQk
         1i8S86PsmJxYOQZQZ7DBomNrCLpg0GT5/CHV+9hFT0tPO5DWKcYR0NWTzJxwJ3+Fl93r
         Q3Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r18si16143317wrv.176.2019.04.25.02.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9m-0001qd-PK; Thu, 25 Apr 2019 11:59:06 +0200
Message-Id: <20190425094801.414574828@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:44:56 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Alexander Potapenko <glider@google.com>,
 Steven Rostedt <rostedt@goodmis.org>,
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
Subject: [patch V3 03/29] lib/stackdepot: Provide functions which operate on
 plain storage arrays
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The struct stack_trace indirection in the stack depot functions is a truly
pointless excercise which requires horrible code at the callsites.

Provide interfaces based on plain storage arrays.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Alexander Potapenko <glider@google.com>
---
V3: Fix kernel-doc
---
 include/linux/stackdepot.h |    4 ++
 lib/stackdepot.c           |   70 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 55 insertions(+), 19 deletions(-)

--- a/include/linux/stackdepot.h
+++ b/include/linux/stackdepot.h
@@ -26,7 +26,11 @@ typedef u32 depot_stack_handle_t;
 struct stack_trace;
 
 depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags);
+depot_stack_handle_t stack_depot_save(unsigned long *entries,
+				      unsigned int nr_entries, gfp_t gfp_flags);
 
 void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
+unsigned int stack_depot_fetch(depot_stack_handle_t handle,
+			       unsigned long **entries);
 
 #endif
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -194,40 +194,60 @@ static inline struct stack_record *find_
 	return NULL;
 }
 
-void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
+/**
+ * stack_depot_fetch - Fetch stack entries from a depot
+ *
+ * @handle:		Stack depot handle which was returned from
+ *			stack_depot_save().
+ * @entries:		Pointer to store the entries address
+ *
+ * Return: The number of trace entries for this depot.
+ */
+unsigned int stack_depot_fetch(depot_stack_handle_t handle,
+			       unsigned long **entries)
 {
 	union handle_parts parts = { .handle = handle };
 	void *slab = stack_slabs[parts.slabindex];
 	size_t offset = parts.offset << STACK_ALLOC_ALIGN;
 	struct stack_record *stack = slab + offset;
 
-	trace->nr_entries = trace->max_entries = stack->size;
-	trace->entries = stack->entries;
-	trace->skip = 0;
+	*entries = stack->entries;
+	return stack->size;
+}
+EXPORT_SYMBOL_GPL(stack_depot_fetch);
+
+void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
+{
+	unsigned int nent = stack_depot_fetch(handle, &trace->entries);
+
+	trace->max_entries = trace->nr_entries = nent;
 }
 EXPORT_SYMBOL_GPL(depot_fetch_stack);
 
 /**
- * depot_save_stack - save stack in a stack depot.
- * @trace - the stacktrace to save.
- * @alloc_flags - flags for allocating additional memory if required.
+ * stack_depot_save - Save a stack trace from an array
+ *
+ * @entries:		Pointer to storage array
+ * @nr_entries:		Size of the storage array
+ * @alloc_flags:	Allocation gfp flags
  *
- * Returns the handle of the stack struct stored in depot.
+ * Return: The handle of the stack struct stored in depot
  */
-depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
-				    gfp_t alloc_flags)
+depot_stack_handle_t stack_depot_save(unsigned long *entries,
+				      unsigned int nr_entries,
+				      gfp_t alloc_flags)
 {
-	u32 hash;
-	depot_stack_handle_t retval = 0;
 	struct stack_record *found = NULL, **bucket;
-	unsigned long flags;
+	depot_stack_handle_t retval = 0;
 	struct page *page = NULL;
 	void *prealloc = NULL;
+	unsigned long flags;
+	u32 hash;
 
-	if (unlikely(trace->nr_entries == 0))
+	if (unlikely(nr_entries == 0))
 		goto fast_exit;
 
-	hash = hash_stack(trace->entries, trace->nr_entries);
+	hash = hash_stack(entries, nr_entries);
 	bucket = &stack_table[hash & STACK_HASH_MASK];
 
 	/*
@@ -235,8 +255,8 @@ depot_stack_handle_t depot_save_stack(st
 	 * The smp_load_acquire() here pairs with smp_store_release() to
 	 * |bucket| below.
 	 */
-	found = find_stack(smp_load_acquire(bucket), trace->entries,
-			   trace->nr_entries, hash);
+	found = find_stack(smp_load_acquire(bucket), entries,
+			   nr_entries, hash);
 	if (found)
 		goto exit;
 
@@ -264,10 +284,10 @@ depot_stack_handle_t depot_save_stack(st
 
 	spin_lock_irqsave(&depot_lock, flags);
 
-	found = find_stack(*bucket, trace->entries, trace->nr_entries, hash);
+	found = find_stack(*bucket, entries, nr_entries, hash);
 	if (!found) {
 		struct stack_record *new =
-			depot_alloc_stack(trace->entries, trace->nr_entries,
+			depot_alloc_stack(entries, nr_entries,
 					  hash, &prealloc, alloc_flags);
 		if (new) {
 			new->next = *bucket;
@@ -297,4 +317,16 @@ depot_stack_handle_t depot_save_stack(st
 fast_exit:
 	return retval;
 }
+EXPORT_SYMBOL_GPL(stack_depot_save);
+
+/**
+ * depot_save_stack - save stack in a stack depot.
+ * @trace - the stacktrace to save.
+ * @alloc_flags - flags for allocating additional memory if required.
+ */
+depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
+				      gfp_t alloc_flags)
+{
+	return stack_depot_save(trace->entries, trace->nr_entries, alloc_flags);
+}
 EXPORT_SYMBOL_GPL(depot_save_stack);


