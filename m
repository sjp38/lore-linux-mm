Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CD1BC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C318206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C318206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78CA46B0271; Thu, 25 Apr 2019 05:59:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73C206B0272; Thu, 25 Apr 2019 05:59:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B47C6B0273; Thu, 25 Apr 2019 05:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1916B0271
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:36 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b12so5715112wmj.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=a3gSsDswxxkaod1waPwbx4k12fNeIbCoQTluUl86z/c=;
        b=TpveH84JCGnuTxB+qIQVlAxIZfSG83ccXjcGhnqam6j0pJ484hYqeyrJv5kPErPB3C
         z7aNh/i9eVPdZIcQaODBAxxeePWStP3zVJnhdOJciU4Tuvh+SafRVw1q1NYxdJm0JYqo
         BqyP9uKFjhxLqtdAhUMNe+GuPl/bYeiRSU+CZ3BLULwtGM60ttCJtHRYLbSBPBodDkMW
         QitDxQyZYvbruFOQ+ze5skcsNWBxPsg5PaUIDQLGCk/sP4aSqByNb5+xnpac6N2/3X2J
         o9Odz/di4iFj18tm7Xas2MGtfewoHuAdsEnbndG7kB5w1fT/wUxIQD+a8mOhtVH9mvHG
         /raw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWONypdY9IAIeLS2W112/E/Z6JbOTImSgluJqsSaOBCoxJntXPg
	Rn0d0MfiTGf0comsPJ7fQhdtwTIaqxD2roCczlBZ8IwnkvdzceAu1z6lSBdT0Pl6/ofejW5lEPN
	Ck0D4IEfqCTp747BqShmgcxRKJ9nwYFKM1rYoM3jha7qowgnBNv2cHToik4y1L/iKWA==
X-Received: by 2002:a1c:6783:: with SMTP id b125mr2731419wmc.79.1556186375505;
        Thu, 25 Apr 2019 02:59:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUZ2/B/E7lOwVOuLOLIMbPKoWg+vMN88CO3tiG9dSBg5+S7gGDJduEJ54a3HpHzdT8dL4x
X-Received: by 2002:a1c:6783:: with SMTP id b125mr2731334wmc.79.1556186373748;
        Thu, 25 Apr 2019 02:59:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186373; cv=none;
        d=google.com; s=arc-20160816;
        b=dYDyewPZaaxV6KpCkiwfG61GLJCSjWS5TfeNUA2btnAoQBPreowbWyKr755YZU4ZJy
         1AV983uIfbMVqhhdjifYb65uLDlDGsXqDDuJoGPZufKPKtAJ/ltyxkJXfb/06JOrnjKm
         ReXQHstcEjsb/UQ26O1d81KZdc96R/bN4PNGl+o6ZvRHHoTyPW63KH3LwDh1BejrUetq
         vjXT2Uffjjoy5x/R4JyjlGwxf/ZTff3u0R/GJnFylsPhD6Wtv4vhAQZniaAKffmgp5US
         Vul/Od7C9x/38UTKzcD4EFL6IQGjXpg+SfwlFBCHoi7Vwa0+1zORgg51zPgGSIuoHCt9
         lMrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=a3gSsDswxxkaod1waPwbx4k12fNeIbCoQTluUl86z/c=;
        b=eha6Hqi7niguaiRgoJQ6bv3IMNf+Z9XrdQOqpAzuamDj3skBVWUjD6Y21hgVOcw9O2
         n3vKpnxgu5/p9CxaiFn3CkLKXXumqX8vL/5YbwSw+qDMgp3V1U8FfkM6RrLLygPfMXzh
         XDyla/Uxlu2ohmjXACVdgorWS0RiopAaUrEUOn393OR6qQ9wxsfgNvDcot/VLt+Kw/2/
         c6Rctmfw38ZqHZ809FhD8frYe6ypl/kP3KV47yS4PbeKfluMB+OrLzpVWkorX0WJW+FU
         kj+A/xapQ2Ufwip2NjYGVl7xfrDiNNaq8a6pSGxWB4dDp7BPJbaTnV6oKV9vOk0FbmmO
         /cJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r2si10610591wrn.398.2019.04.25.02.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA4-0001to-VQ; Thu, 25 Apr 2019 11:59:25 +0200
Message-Id: <20190425094802.622094226@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:09 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Daniel Vetter <daniel@ffwll.ch>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Steven Rostedt <rostedt@goodmis.org>,
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
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 16/29] drm: Simplify stacktrace handling
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

The original code in all printing functions is really wrong. It allocates a
storage array on stack which is unused because depot_fetch_stack() does not
store anything in it. It overwrites the entries pointer in the stack_trace
struct so it points to the depot storage.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Daniel Vetter <daniel@ffwll.ch>
Cc: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>
Cc: dri-devel@lists.freedesktop.org
Cc: David Airlie <airlied@linux.ie>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
---
 drivers/gpu/drm/drm_mm.c                |   22 +++++++---------------
 drivers/gpu/drm/i915/i915_vma.c         |   11 ++++-------
 drivers/gpu/drm/i915/intel_runtime_pm.c |   21 +++++++--------------
 3 files changed, 18 insertions(+), 36 deletions(-)

--- a/drivers/gpu/drm/drm_mm.c
+++ b/drivers/gpu/drm/drm_mm.c
@@ -106,22 +106,19 @@
 static noinline void save_stack(struct drm_mm_node *node)
 {
 	unsigned long entries[STACKDEPTH];
-	struct stack_trace trace = {
-		.entries = entries,
-		.max_entries = STACKDEPTH,
-		.skip = 1
-	};
+	unsigned int n;
 
-	save_stack_trace(&trace);
+	n = stack_trace_save(entries, ARRAY_SIZE(entries), 1);
 
 	/* May be called under spinlock, so avoid sleeping */
-	node->stack = depot_save_stack(&trace, GFP_NOWAIT);
+	node->stack = stack_depot_save(entries, n, GFP_NOWAIT);
 }
 
 static void show_leaks(struct drm_mm *mm)
 {
 	struct drm_mm_node *node;
-	unsigned long entries[STACKDEPTH];
+	unsigned long *entries;
+	unsigned int nr_entries;
 	char *buf;
 
 	buf = kmalloc(BUFSZ, GFP_KERNEL);
@@ -129,19 +126,14 @@ static void show_leaks(struct drm_mm *mm
 		return;
 
 	list_for_each_entry(node, drm_mm_nodes(mm), node_list) {
-		struct stack_trace trace = {
-			.entries = entries,
-			.max_entries = STACKDEPTH
-		};
-
 		if (!node->stack) {
 			DRM_ERROR("node [%08llx + %08llx]: unknown owner\n",
 				  node->start, node->size);
 			continue;
 		}
 
-		depot_fetch_stack(node->stack, &trace);
-		snprint_stack_trace(buf, BUFSZ, &trace, 0);
+		nr_entries = stack_depot_fetch(node->stack, &entries);
+		stack_trace_snprint(buf, BUFSZ, entries, nr_entries, 0);
 		DRM_ERROR("node [%08llx + %08llx]: inserted at\n%s",
 			  node->start, node->size, buf);
 	}
--- a/drivers/gpu/drm/i915/i915_vma.c
+++ b/drivers/gpu/drm/i915/i915_vma.c
@@ -36,11 +36,8 @@
 
 static void vma_print_allocator(struct i915_vma *vma, const char *reason)
 {
-	unsigned long entries[12];
-	struct stack_trace trace = {
-		.entries = entries,
-		.max_entries = ARRAY_SIZE(entries),
-	};
+	unsigned long *entries;
+	unsigned int nr_entries;
 	char buf[512];
 
 	if (!vma->node.stack) {
@@ -49,8 +46,8 @@ static void vma_print_allocator(struct i
 		return;
 	}
 
-	depot_fetch_stack(vma->node.stack, &trace);
-	snprint_stack_trace(buf, sizeof(buf), &trace, 0);
+	nr_entries = stack_depot_fetch(vma->node.stack, &entries);
+	stack_trace_snprint(buf, sizeof(buf), entries, nr_entries, 0);
 	DRM_DEBUG_DRIVER("vma.node [%08llx + %08llx] %s: inserted at %s\n",
 			 vma->node.start, vma->node.size, reason, buf);
 }
--- a/drivers/gpu/drm/i915/intel_runtime_pm.c
+++ b/drivers/gpu/drm/i915/intel_runtime_pm.c
@@ -60,27 +60,20 @@
 static noinline depot_stack_handle_t __save_depot_stack(void)
 {
 	unsigned long entries[STACKDEPTH];
-	struct stack_trace trace = {
-		.entries = entries,
-		.max_entries = ARRAY_SIZE(entries),
-		.skip = 1,
-	};
+	unsigned int n;
 
-	save_stack_trace(&trace);
-	return depot_save_stack(&trace, GFP_NOWAIT | __GFP_NOWARN);
+	n = stack_trace_save(entries, ARRAY_SIZE(entries), 1);
+	return stack_depot_save(entries, n, GFP_NOWAIT | __GFP_NOWARN);
 }
 
 static void __print_depot_stack(depot_stack_handle_t stack,
 				char *buf, int sz, int indent)
 {
-	unsigned long entries[STACKDEPTH];
-	struct stack_trace trace = {
-		.entries = entries,
-		.max_entries = ARRAY_SIZE(entries),
-	};
+	unsigned long *entries;
+	unsigned int nr_entries;
 
-	depot_fetch_stack(stack, &trace);
-	snprint_stack_trace(buf, sz, &trace, indent);
+	nr_entries = stack_depot_fetch(stack, &entries);
+	stack_trace_snprint(buf, sz, entries, nr_entries, indent);
 }
 
 static void init_intel_runtime_pm_wakeref(struct drm_i915_private *i915)


