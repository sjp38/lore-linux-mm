Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F169BC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94FD021902
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94FD021902
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E1226B026D; Thu, 18 Apr 2019 05:06:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48FDC6B026E; Thu, 18 Apr 2019 05:06:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E9236B026F; Thu, 18 Apr 2019 05:06:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C08C56B026E
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:21 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f16so1526177wrs.6
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=0y/QyUdaOvECJaR4ueRYQdFEB+ebIhDutCtUQ6iFeT4=;
        b=BsE7fwIJaoA1I80TNJJfYHrx3GSLDO1SKI4hvdppazbP8Noj5rxpKB/3gxqxZZ4eZL
         XJHt8B0A7zOhJJxxxo9bXKaIDmnQVglFOnt7lN15xW1dpyB8l3TzIsLYYVQshADb4oTR
         2iHe2c2L5KOFz1MdbFH2V72QMnomzgBT4i0Dnj3iuafU2RDbEGhwmXSGlkSb+OUsf4sT
         WXVY0JivLsmX+mn+TLTZ9RoN7KcWo5Kk8L0W/vIRXZAmX+4/eV4N7JjLuLliKBnqcjYk
         4VPFC0GXl1/6Nd4CWCJ9enxGaSTL7Zc9WIWY47LmLYOEhDJR44Ma3oYQsnF7A6nQVNOT
         MmsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUIZehqqg/LYSocHV+59C1WJyD/d18y/0lcz/9atQ2Ge9Ltb6zo
	24XG0RvlsIT/vDvSv4iZmAEYvDFJSA419NmAlFTuW5T2UMxGtiu+7yqlcmdfpx7LGhDgp1iht5P
	af39YNDS7l8tpgoSdROJRRhWhkdBz9LiTJAuyoH62vmccmztRWYOyqQvNcI1pVcicag==
X-Received: by 2002:adf:f309:: with SMTP id i9mr37465632wro.258.1555578381282;
        Thu, 18 Apr 2019 02:06:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjZRtYrYU9Zptp+vKB3+H+mz3rtEnvvwla/XPgRc3Y92xmlojerDNPxz73lXw1J4ikGkIj
X-Received: by 2002:adf:f309:: with SMTP id i9mr37465580wro.258.1555578380416;
        Thu, 18 Apr 2019 02:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578380; cv=none;
        d=google.com; s=arc-20160816;
        b=UEGDuw1eGtudmV7NEvYv8TV9HenvfSrwWAyZck6d2GMZE1TW3L11NxD5/laT89o1hO
         hoWB9tbgiUqo1WSJVTW1mCpEw7ooQauWKePH1MIPFXac0vleFaO+sNNrHOPdBQ8UMaHW
         WbvclVeip7+JxiSWDD0fhN5doN1qEYVRoRuvY+1bH5loMEshSXX7a5JBMAe1WavSthqr
         uKpXKiQAOLvp+ThEGALAJ+7XcVZVktO00RkNV/61r21LsnVXJLE22LCHsUfg+Sgk4X7L
         M2oLbmkP50M9ReGVr6HdyYBVFbD6IQTbi2x+6z/ZATyJOmXJ0CcE0YKo1Rp3BGrpI+Cp
         coFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=0y/QyUdaOvECJaR4ueRYQdFEB+ebIhDutCtUQ6iFeT4=;
        b=DKFnvRIj+7LHy3LHb2NvwSeltu6tIUS+Wx1fqVEYuvP6PHc2FQtIOPxHWQDCHFWrpb
         Wgb4Cw2s6nqDF19e3oEaJ3+5Hvm9ETncfPXa+oawxZiWHddh9cpltZshUsZju8aSMMRt
         Jb5mvUq0t8xyyH9GalOtd/HFVXSBClPdGlXtz6K4BVOJAFDLgB33USzJ6Tk9JaDvEV6h
         /0mY+M+pzQdwqAM4GkvHkeqQXDW7KiQdHbZLyAKmc3ItjPRe/naVKEQXc9MWwEv9qrT+
         fOnReELGAMPlEknzr3Ct7L8Vby9/m10b0GNvSaYSrC7xyBoIwyssCzhJp9QL3KB5mVmf
         4LCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f199si1155963wmf.58.2019.04.18.02.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zr-0001oP-DR; Thu, 18 Apr 2019 11:06:19 +0200
Message-Id: <20190418084253.991328385@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:29 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, linux-mm@kvack.org,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 David Rientjes <rientjes@google.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexey Dobriyan <adobriyan@gmail.com>, Pekka Enberg <penberg@kernel.org>,
 Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
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
Subject: [patch V2 10/29] mm/page_owner: Simplify stack trace handling
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

The original code in all printing functions is really wrong. It allocates a
storage array on stack which is unused because depot_fetch_stack() does not
store anything in it. It overwrites the entries pointer in the stack_trace
struct so it points to the depot storage.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_owner.c |   79 +++++++++++++++++++-------------------------------------
 1 file changed, 28 insertions(+), 51 deletions(-)

--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -58,15 +58,10 @@ static bool need_page_owner(void)
 static __always_inline depot_stack_handle_t create_dummy_stack(void)
 {
 	unsigned long entries[4];
-	struct stack_trace dummy;
+	unsigned int nr_entries;
 
-	dummy.nr_entries = 0;
-	dummy.max_entries = ARRAY_SIZE(entries);
-	dummy.entries = &entries[0];
-	dummy.skip = 0;
-
-	save_stack_trace(&dummy);
-	return depot_save_stack(&dummy, GFP_KERNEL);
+	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
+	return stack_depot_save(entries, nr_entries, GFP_KERNEL);
 }
 
 static noinline void register_dummy_stack(void)
@@ -120,46 +115,39 @@ void __reset_page_owner(struct page *pag
 	}
 }
 
-static inline bool check_recursive_alloc(struct stack_trace *trace,
-					unsigned long ip)
+static inline bool check_recursive_alloc(unsigned long *entries,
+					 unsigned int nr_entries,
+					 unsigned long ip)
 {
-	int i;
+	unsigned int i;
 
-	if (!trace->nr_entries)
-		return false;
-
-	for (i = 0; i < trace->nr_entries; i++) {
-		if (trace->entries[i] == ip)
+	for (i = 0; i < nr_entries; i++) {
+		if (entries[i] == ip)
 			return true;
 	}
-
 	return false;
 }
 
 static noinline depot_stack_handle_t save_stack(gfp_t flags)
 {
 	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.entries = entries,
-		.max_entries = PAGE_OWNER_STACK_DEPTH,
-		.skip = 2
-	};
 	depot_stack_handle_t handle;
+	unsigned int nr_entries;
 
-	save_stack_trace(&trace);
+	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 2);
 
 	/*
-	 * We need to check recursion here because our request to stackdepot
-	 * could trigger memory allocation to save new entry. New memory
-	 * allocation would reach here and call depot_save_stack() again
-	 * if we don't catch it. There is still not enough memory in stackdepot
-	 * so it would try to allocate memory again and loop forever.
+	 * We need to check recursion here because our request to
+	 * stackdepot could trigger memory allocation to save new
+	 * entry. New memory allocation would reach here and call
+	 * stack_depot_save_entries() again if we don't catch it. There is
+	 * still not enough memory in stackdepot so it would try to
+	 * allocate memory again and loop forever.
 	 */
-	if (check_recursive_alloc(&trace, _RET_IP_))
+	if (check_recursive_alloc(entries, nr_entries, _RET_IP_))
 		return dummy_handle;
 
-	handle = depot_save_stack(&trace, flags);
+	handle = stack_depot_save(entries, nr_entries, flags);
 	if (!handle)
 		handle = failure_handle;
 
@@ -337,16 +325,10 @@ print_page_owner(char __user *buf, size_
 		struct page *page, struct page_owner *page_owner,
 		depot_stack_handle_t handle)
 {
-	int ret;
-	int pageblock_mt, page_mt;
+	int ret, pageblock_mt, page_mt;
+	unsigned long *entries;
+	unsigned int nr_entries;
 	char *kbuf;
-	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.entries = entries,
-		.max_entries = PAGE_OWNER_STACK_DEPTH,
-		.skip = 0
-	};
 
 	count = min_t(size_t, count, PAGE_SIZE);
 	kbuf = kmalloc(count, GFP_KERNEL);
@@ -375,8 +357,8 @@ print_page_owner(char __user *buf, size_
 	if (ret >= count)
 		goto err;
 
-	depot_fetch_stack(handle, &trace);
-	ret += snprint_stack_trace(kbuf + ret, count - ret, &trace, 0);
+	nr_entries = stack_depot_fetch(handle, &entries);
+	ret += stack_trace_snprint(kbuf + ret, count - ret, entries, nr_entries, 0);
 	if (ret >= count)
 		goto err;
 
@@ -407,14 +389,9 @@ void __dump_page_owner(struct page *page
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
 	struct page_owner *page_owner;
-	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.entries = entries,
-		.max_entries = PAGE_OWNER_STACK_DEPTH,
-		.skip = 0
-	};
 	depot_stack_handle_t handle;
+	unsigned long *entries;
+	unsigned int nr_entries;
 	gfp_t gfp_mask;
 	int mt;
 
@@ -438,10 +415,10 @@ void __dump_page_owner(struct page *page
 		return;
 	}
 
-	depot_fetch_stack(handle, &trace);
+	nr_entries = stack_depot_fetch(handle, &entries);
 	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
 		 page_owner->order, migratetype_names[mt], gfp_mask, &gfp_mask);
-	print_stack_trace(&trace, 0);
+	stack_trace_print(entries, nr_entries, 0);
 
 	if (page_owner->last_migrate_reason != -1)
 		pr_alert("page has been migrated, last migrate reason: %s\n",


