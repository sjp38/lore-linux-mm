Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 549F7C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 158E02183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 158E02183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 299666B027D; Thu, 18 Apr 2019 05:06:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24A026B027E; Thu, 18 Apr 2019 05:06:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1115C6B027F; Thu, 18 Apr 2019 05:06:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B74436B027E
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e14so1509390wrt.18
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=kxeJpbHI7As6QAtGU1p6Y41OP6F6oIuYF4MIr44OBP4=;
        b=bTveDyMDsoFXEHdWWadzME5owH8X7UK0rKDwiWwKMKmyg1+AgtFYMqZyPISXYMkYAf
         Z3BEvEreGc0mdkb3MJbS90G/Q/lLaudyPWrQdDmesTIoMuvPKv10xdHmIQhRB6FQeXSj
         7Z1J4wt8Z5vkOie50Z+yXOLFjjDeP5WZQ7KETTRA8myT4oWAit0xcpTFUNLir0pRsRGb
         vr9rIS9SBrRYfbf/4iBwKzSCjsJxf0nnRFcOAaE4xs0sAViGX03/iTbGRkLOcycat3xb
         9tm/Co3Bu5fiu1PTegfyK5PL2fA7lMFkQt8b9figHf6Q+EyG2TwoDBGEbIWFQ01LtQXv
         KwTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXajBi9gZXIFXL1ogfRze5YZorvpstKSUrJf4IrbnQtppgFPMCO
	OEKmUTkaAb8Vg/Hb2+mdbnrqY2jAgUektfx+PhUYpbmsOLF+/qWHKHjB19IZ45u7b6cQMQLTKo6
	qZWyCdbaK5wzOm46DQyjRMA16w3b76RcP/XrDrDVFNWfQiM5+cZguZGegp/uy98AszQ==
X-Received: by 2002:a1c:208c:: with SMTP id g134mr2355934wmg.70.1555578406209;
        Thu, 18 Apr 2019 02:06:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzX/du/tYHn3QIrlOyahsSx5/4ID4U03dppyU+Fpght7cHB+ar+wC4PsPpeAfBUxJGSldkQ
X-Received: by 2002:a1c:208c:: with SMTP id g134mr2355879wmg.70.1555578405324;
        Thu, 18 Apr 2019 02:06:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578405; cv=none;
        d=google.com; s=arc-20160816;
        b=i3uK7PAnygSebBz9ln4nWzJybN68gH1lwhYmLyvPpEpkyE5aC65n7bKosz6EzOBmW7
         LV0dYpsJDGovKRV9FSbt1UeXy52CmARyvp2lBBTvQGTgpGxKxCMac6Um3MGkXJOB0WEC
         rAW8Z4xW1uRoDQD8CP53EqWO4bWQiBOFMtzvXA6sC4pS4A7IkfG1if4FWCqueCBWE/W8
         1+e0RMUuhgF6O4RbHmXlJQ3GTW5ORmZtxkfZepcdXegQ+mw1472FyYXXTPbDGJOA1FAu
         9kwi2H7zEepFgTpYPPCUEyr5o+XZF77Z6Ye+beBOVhOKt65ilaid8pQqGShCsHdw1b6T
         nKKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=kxeJpbHI7As6QAtGU1p6Y41OP6F6oIuYF4MIr44OBP4=;
        b=hZL9UWuuqaMj+t3BfQcV8agqcDqhCiaKIKyX3eaIhWLBqzJ2x8IIJDIAB1d86SoXxw
         PoS+SIfcnTuORiP1TxK9zK4Cf6vYpTVdiKjGwio+2Ki99rPc4TBpz+OJ7evJ/CIGY8sN
         3KiMS4HeZ4IlfLi/ZfHFBYdV2Hna1ZI9veQX7Jt8obZ6SEyqRD9qDeF9FTl5xeqxQglj
         tpXcDGcdWhLPTnErsP/HHHzdYrYv0tlQuJUAw1l7Npb735d/U0Mt9LAoZeV0GaZamCFD
         WnIath6G+NU3LZVJObFfNEgYq2/c6fbR0bSvMIzdP6o3lOD5OWVsHTG3isbMXkXJH8KW
         1XyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x129si1154791wmg.27.2019.04.18.02.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH305-0001rb-3d; Thu, 18 Apr 2019 11:06:33 +0200
Message-Id: <20190418084254.549410214@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:35 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
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
 linux-arch@vger.kernel.org
Subject: [patch V2 16/29] drm: Simplify stacktrace handling
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
Cc: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>
Cc: dri-devel@lists.freedesktop.org
Cc: David Airlie <airlied@linux.ie>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Daniel Vetter <daniel@ffwll.ch>
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


