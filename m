Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49DDAC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 071A2206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 071A2206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA8896B000A; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94BE76B0010; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3576B6B000A; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1DD46B000D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n5so500478wrv.10
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=XKNHsKVL53fEymf/PDnpaEhKhMIAQzy9pwzTM1OgbZg=;
        b=gjTspitdp4GS0aZ28IZ+OIJY+wtFK5FFDCZWdKedafvQvD33SN+o88OHR4kwKZqnqJ
         +wzDet/oZzxJUYuC8Midsxz+TGB6VK1hqWLtN9w6rqsuZ+l7oEqV5VrX96sG2cTix2wK
         tyPsU6h6V9Rre7MiRWkFSHg8JGbVUCCQOIj7kZ6Mwt7qJGctMi9gDF4y3IkpeQWExU7E
         NQ7l22cAUteDp4zN5T2S46bTwlq1O+HQkT0HcwQUs8Ck0s8AZ5yaPx/dc9+Zb+qTYVKN
         +qcNqkpmpGhextk/UyyvdpGbIiy3eRbTlmz/g18LK8MpDftNpFLGpcyJ8gH5CQGnpWZn
         srkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXM86ayfBXZhPmMG8iAXbty4pYkp2UKgtCEmavif/PvQPT2bNoD
	LWfEO3Y5rluOQOP4W+n6WXrNBx/PlX9mgeptipltSf+4W4N9q1K2NLFuNgiOoAaXPY58fQhKmVK
	5QMBFHYs1MViUEs5216ey0Q3fMS2tXUVBAmavosH0sPBvdxjm+NSUieQm3p3xSQHvNQ==
X-Received: by 2002:adf:f147:: with SMTP id y7mr59660684wro.102.1555578371221;
        Thu, 18 Apr 2019 02:06:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA2FGGcKYpZdQ0lPzP7IUtZmc+6Tp/A+g7EWW7PTEc0+Re2RPqM2WNpSQ4PKwl4vu+uuL2
X-Received: by 2002:adf:f147:: with SMTP id y7mr59660575wro.102.1555578369800;
        Thu, 18 Apr 2019 02:06:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578369; cv=none;
        d=google.com; s=arc-20160816;
        b=h6hdR69OBk9Z1HMuqh242YF1XOvr76XFMvo4q7fnHdfjhCnDqLrem1YtPpQScZj1ww
         wDAUC2DE4lO86vtrDUoUkmECiK8hZ2HLx6QMYqLUvY5aWDasE/uI+NkxUJXJ/AXFDtWu
         VSCdK/SE3s8ED4GQ2LYdb4WCMzwpJkRhnGLV9DDGvWb72vRQXHKn76MZkUp9tVKZO8/O
         RuPxpCfUZvToF4M7ynx+4o/ZTdTVKVa8lBCS8fn229BSK98JKvCp1n+bdhZW+zAJ5wQd
         F/qEnZKGcv7NQRNDoTAgte940dReCkQybz3LGuWniTB7FSCAb2LFCDEyhuDbQ/5T/l3d
         1Pgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=XKNHsKVL53fEymf/PDnpaEhKhMIAQzy9pwzTM1OgbZg=;
        b=byi3Od7rSyDQPwhlZMMyB9W+fr5RdenGDmgYK1wbg1VoKJKTL1Oq5977vBcmpDsRzT
         y0GDQ+2ZiutPRPnFdduuQbEfYwFVL9mc7KeiGtHjhmoUBMcc7OL0ad/1CVNFrUboLycE
         IvAbss1iZ3614pyKVQrh8/6s72u3cQijhzhRMZgL82IM2vOYZaGfdECQjRCq+LlI5+yj
         tBs2zAsyWDdUmI6WGhXlTzs0kO4bPvtwrkVEeEOIKcFqBX1O4kTyv4ZqB3fx53r5aBsG
         qgl5ik/u7Mdwc8bxWRzkLQKQRh0igAgqe8q/quGMXIYsKCGu2y2Opv/K/D3R2tTeGZ78
         7geA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f25si1090350wml.78.2019.04.18.02.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zc-0001m4-W3; Thu, 18 Apr 2019 11:06:05 +0200
Message-Id: <20190418084253.337266121@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:22 +0200
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
Subject: [patch V2 03/29] lib/stackdepot: Provide functions which operate on
 plain storage arrays
References: <20190418084119.056416939@linutronix.de>
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
 include/linux/stackdepot.h |    4 ++
 lib/stackdepot.c           |   66 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 51 insertions(+), 19 deletions(-)

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
@@ -194,40 +194,56 @@ static inline struct stack_record *find_
 	return NULL;
 }
 
-void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
+/**
+ * stack_depot_fetch - Fetch stack entries from a depot
+ *
+ * @entries:		Pointer to store the entries address
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
  *
- * Returns the handle of the stack struct stored in depot.
+ * @entries:		Pointer to storage array
+ * @nr_entries:		Size of the storage array
+ * @alloc_flags:	Allocation gfp flags
+ *
+ * Returns the handle of the stack struct stored in depot
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
@@ -235,8 +251,8 @@ depot_stack_handle_t depot_save_stack(st
 	 * The smp_load_acquire() here pairs with smp_store_release() to
 	 * |bucket| below.
 	 */
-	found = find_stack(smp_load_acquire(bucket), trace->entries,
-			   trace->nr_entries, hash);
+	found = find_stack(smp_load_acquire(bucket), entries,
+			   nr_entries, hash);
 	if (found)
 		goto exit;
 
@@ -264,10 +280,10 @@ depot_stack_handle_t depot_save_stack(st
 
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
@@ -297,4 +313,16 @@ depot_stack_handle_t depot_save_stack(st
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


