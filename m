Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AECE6C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A930222A9
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A930222A9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE0EE6B0282; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B69866B0283; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E43F6B0284; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 486466B0282
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u14so1206317wrr.9
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:06:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=4nz2/nz5lM3gNQrCI/sdcKPH5OkOjIS+6H6wEUVkeFU=;
        b=ZzQI3U8Ehm+S6bTtDz0tt35rSuMJoS+mlVxxYEXki+EHZT2hBQdhL8PRrTLVmVV7R1
         pTQ5tW2Jaxn7c5K7lyVRzo3ACnWUNrqJCD1rH1E5mxb7hxSi3fW1EhjumW8kceC96Fbx
         hhhUuWCPujC3Ajinp9Ou5hjgQzZNogTVwAP65hqvrZgTwDAc7LgnubhRsvXZDCA9iFKX
         jhJ2umkqjtubRKb2fCxNN+RlCH+/FeKJ5HgkqLTocsRkomzC6pAY7OQ0+p8rbgU/pDVa
         YTQfGTBfmHnqFvjehGLyyEEF133Bvm0ZFoqexXHh6uDJuR7Pakl+m0UC8Lj1HMHoxCtj
         lNqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUOxShj1ZbvyZdnPdbNATS/NWWR+bIAQ17R0eKVv7Wf6fzeTWGf
	I5TnT+cINgBeK+sTJ51p4d182Myw3SgwBg6ViDmCBZ+heB47smpQjoKgTOQEBfJFlwawswPLliE
	/Gz3XOIIjLMZMQg/UmYtfPRHuwuDbkMBPr5ePBHCeMKvCifDqWJYsEjZHojTpb5tRAw==
X-Received: by 2002:adf:fc47:: with SMTP id e7mr21864021wrs.100.1554894367793;
        Wed, 10 Apr 2019 04:06:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRf3dvGaFpZ2uNTae/WlE4nBlFet/1F0DcpSe8uFWhotqNYUUV9bLneWQIeOlYABB44giN
X-Received: by 2002:adf:fc47:: with SMTP id e7mr21863943wrs.100.1554894366837;
        Wed, 10 Apr 2019 04:06:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894366; cv=none;
        d=google.com; s=arc-20160816;
        b=dEXEewH5An7KfNPSNZBhJbEA34SZJkaCZldX+KqDlYzgE2qsZI+0UbGn0HcpnIeFFS
         Viqb3dlg/WSGjJ2xKObY1SDnOfdp2XlJVxaapwA5TJ8AdKWGNDAZ3RZyuiNQHQpqnAod
         AW+JIpZy35s3nd/sOQcH/1osz6PnByhtz1iRlLR1Gc359Ex0yuy2Mm/wgOWgVPTGGjO4
         rSuyowO3g9QZdA5rsJnEjBATMoguBBPKpi2J8srel1mFafH+m8niiit1BPMzJPI5Bl95
         hWv0R9TaOFjeLrj1UxsmEOAxWUpLoBESSEG5IXc1fY+x+6UJde3ktlGrueLFLYTKurHj
         i1EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=4nz2/nz5lM3gNQrCI/sdcKPH5OkOjIS+6H6wEUVkeFU=;
        b=tt78K493IV/zZ0yVK/o8y/y4aZA+WPyCMPbaFZBKmh5HfmOvueRJLR1eE349lYrO/Y
         VSjuzinqknf33QZBCdlYGimQH8jiQM0pzN6cT8QkqGP7GiTzRleFsobHq7a1/rSlfaYi
         Zd3I0lVHEdC+oCCQZ2LgUYJw9/b4aa6ncxVGqr2aRKLaqSVQkrn6YhYO+Rn/UsE3XyW9
         70qOFANOchFxGeGmJAXm4G95WgqYy2YAiZBBqiOXYCEofIKc9CnDOtX/1IIxGKPq7bvj
         GPem8f0CxCi8nvixtabHihAS9XY4sZrBT3vjWDPJwq6d5+oys/qd5dHFW0Z8TnDvY8Ot
         eIcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j5si1198746wme.179.2019.04.10.04.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:06:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB3J-0005Ae-7e; Wed, 10 Apr 2019 13:06:01 +0200
Message-Id: <20190410103645.951691679@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:20 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, linux-mm@kvack.org,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 David Rientjes <rientjes@google.com>,
 Andrew Morton <akpm@linux-foundation.org>
Subject: [RFC patch 26/41] mm/page_owner: Simplify stack trace handling
References: <20190410102754.387743324@linutronix.de>
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
+	unsigned int nent;
 
-	dummy.nr_entries = 0;
-	dummy.max_entries = ARRAY_SIZE(entries);
-	dummy.entries = &entries[0];
-	dummy.skip = 0;
-
-	save_stack_trace(&dummy);
-	return depot_save_stack(&dummy, GFP_KERNEL);
+	nent = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
+	return stack_depot_save(entries, nent, GFP_KERNEL);
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
+	unsigned int nent;
 
-	save_stack_trace(&trace);
+	nent = stack_trace_save(entries, ARRAY_SIZE(entries), 2);
 
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
+	if (check_recursive_alloc(entries, nent, _RET_IP_))
 		return dummy_handle;
 
-	handle = depot_save_stack(&trace, flags);
+	handle = stack_depot_save(entries, nent, flags);
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
+	unsigned int nent;
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
+	nent = stack_depot_fetch(handle, &entries);
+	ret += stack_trace_snprint(kbuf + ret, count - ret, entries, nent, 0);
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
+	unsigned int nent;
 	gfp_t gfp_mask;
 	int mt;
 
@@ -438,10 +415,10 @@ void __dump_page_owner(struct page *page
 		return;
 	}
 
-	depot_fetch_stack(handle, &trace);
+	nent = stack_depot_fetch(handle, &entries);
 	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
 		 page_owner->order, migratetype_names[mt], gfp_mask, &gfp_mask);
-	print_stack_trace(&trace, 0);
+	stack_trace_print(entries, nent, 0);
 
 	if (page_owner->last_migrate_reason != -1)
 		pr_alert("page has been migrated, last migrate reason: %s\n",


