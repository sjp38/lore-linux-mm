Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F028C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:09:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4572F21473
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:09:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pTaXTTu2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4572F21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE3CB6B0006; Wed, 22 May 2019 11:09:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B45A66B0007; Wed, 22 May 2019 11:09:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0C306B0008; Wed, 22 May 2019 11:09:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3552A6B0006
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:09:54 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id l17so354280lfp.0
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:09:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=XS/exrL2qtsb1wQlcnKifMlE835u1lj3Ys1udy3P5H4=;
        b=fWV84bh1jSDT569ShOH4+fBo2gLEdpRBBlpePov88NTSIWeFmTbPqlRlm9WT2Eb4g7
         /+ZXOKXq50YyUPp9g7RdhgJgwDLjxbh+grQpxphYXVa6tU4gfLvEGv+Z+xR8p354OeVd
         +6x0O2UfMQsEKoQ53U9dNSf4g5Q2gkqq/dig354vZ2gdCplHpwD7XSMYXHfKOVL8dInC
         Tw2cdmyY8k+g1e9VMmi3uRRy5yPkjNZqnpTF4Ub0fNr8uOlBLnRpEQ2R/vs1PPA3wgQ/
         X9LoMzmQCpujbL3+yipqyUOFZovcm8dKA7PaLhgBOIz56JAyEAnPON/RbU0u5CJGVkek
         WQcA==
X-Gm-Message-State: APjAAAV2EzTceVWEEPX93YE4TB7T5qDid6xXFeXZS/JXJogML/MzcgRd
	U1orHpO6vSAudHACtgYIwfuTA65iVd990gm+aoqSYjv2/qtoPLda/aW9H8VClyUkPoeCUjiAWAv
	PnBOiH5zgS0LzHVecVyibn3lwiH8J2YWBUsZsPIiPIBxLyOeZHQgPyRtPsmEmBa4oWw==
X-Received: by 2002:a19:3f4b:: with SMTP id m72mr43674975lfa.32.1558537793606;
        Wed, 22 May 2019 08:09:53 -0700 (PDT)
X-Received: by 2002:a19:3f4b:: with SMTP id m72mr43674898lfa.32.1558537792100;
        Wed, 22 May 2019 08:09:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558537792; cv=none;
        d=google.com; s=arc-20160816;
        b=0kW9tcZbFgu4DB0ISO4ERzEimmk5pzK1GzyGFzjjlVvAYLTrHwsw9UmD55Qf8RDyb8
         2EIZnSb+cnbPj9a/O/zmR3FfyrfHQ1Z3617yhZGl2bniDWM03L4FNZPUffgn5UJjVNH1
         VgqJnCvkpr+cGKdyW6sPG1RCovF4MDD8EQGEAU8SvX0VGN43Jf1LHVn3TODgYlxScn/6
         cXMgzyiEmV0RD95w/QeclyDcUzQG0jiQSmfc3Egy0WiS3fp5aEhzoee00vR9xxHui7Qn
         FC0ZLtqC42WE3WaVgX0LwYd4rRT7DUYrjv/XqZ+LQeRjMGxmcjqi8wx1jl+HpxryDv1O
         5OLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=XS/exrL2qtsb1wQlcnKifMlE835u1lj3Ys1udy3P5H4=;
        b=IrYpCbh+oGAfakBAPBaFCSj8ysBRiqeC8JGRKLETVOgzxIBx90Dtz/730d/W1bwxQo
         VAdFQFl5x0eT6vW7exQBbsiOgLlo7ddqPK1tNfu1O4JKNHMafT525sRiW/avrxZhlY38
         hXG8nFYmGYF6OdPSvVrZ5X5XtyD1W8/iYqwUOlafeS0/QSPr/j5eNsdBv9zMWSgQLSyr
         ZlKA/75bgA2Vnrv4CuIMzbetqeBRJNShWAciw8K3O/xk4RgwlHLuYHogRDAwz6tPMzA1
         jXwl52qu3AM9P2NycnKN2m0OjU8e5tbtihC1SBv6KyK1uXK8EYRvIEyfCTwfZmBhxU6W
         CfDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pTaXTTu2;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10sor6913729lfn.19.2019.05.22.08.09.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:09:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pTaXTTu2;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=XS/exrL2qtsb1wQlcnKifMlE835u1lj3Ys1udy3P5H4=;
        b=pTaXTTu2glGWzCtLk76Cl7B6tZw4mic9YljjZTNWqawSe1IdcLFtJdXry3pTReF+XP
         jS2hGtc7XmDPY/jxLfqgB2oopz2zMYo1t5ATW0D/YM6xBHS3X1ptj9Atx/I5rdJ6rLAa
         1LGecflzmrOTWL7czlq9qcASE9EbnmfDcTVqqQh2vv5J+rcWAkTmlX2bdylKxCRVPqk4
         QzOm6Eg6M/ZYU8xeGmcD/JHLadKWQeIu6aySuhyGBXUXFwuGj/nH7Peu3UnfPgs80Xax
         rSDrs1IFJINGs0egfYiEhho7OP6+0AxPZdIY/2d/E69jBS0ptLrfxDtUWaDRPHfkW1Q2
         OmYg==
X-Google-Smtp-Source: APXvYqw+RiBtacL9aZIC5RAbtHUdu2UF9erfKWA6sEHVLiTrV/brXIweM3I0dA9/b8+ynfOjSkNLVg==
X-Received: by 2002:ac2:4a6e:: with SMTP id q14mr7392786lfp.46.1558537791665;
        Wed, 22 May 2019 08:09:51 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t22sm5303615lje.58.2019.05.22.08.09.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:09:51 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/4] mm/vmap: preload a CPU with one object for split purpose
Date: Wed, 22 May 2019 17:09:37 +0200
Message-Id: <20190522150939.24605-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190522150939.24605-1-urezki@gmail.com>
References: <20190522150939.24605-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce ne_fit_preload()/ne_fit_preload_end() functions
for preloading one extra vmap_area object to ensure that
we have it available when fit type is NE_FIT_TYPE.

The preload is done per CPU and with GFP_KERNEL permissive
allocation masks, which allow to be more stable under low
memory condition and high memory pressure.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 78 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ea1b65fac599..5302e1b79c7b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -364,6 +364,13 @@ static LIST_HEAD(free_vmap_area_list);
  */
 static struct rb_root free_vmap_area_root = RB_ROOT;
 
+/*
+ * Preload a CPU with one object for "no edge" split case. The
+ * aim is to get rid of allocations from the atomic context, thus
+ * to use more permissive allocation masks.
+ */
+static DEFINE_PER_CPU(struct vmap_area *, ne_fit_preload_node);
+
 static __always_inline unsigned long
 va_size(struct vmap_area *va)
 {
@@ -950,9 +957,24 @@ adjust_va_to_fit_type(struct vmap_area *va,
 		 *   L V  NVA  V R
 		 * |---|-------|---|
 		 */
-		lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
-		if (unlikely(!lva))
-			return -1;
+		lva = __this_cpu_xchg(ne_fit_preload_node, NULL);
+		if (unlikely(!lva)) {
+			/*
+			 * For percpu allocator we do not do any pre-allocation
+			 * and leave it as it is. The reason is it most likely
+			 * never ends up with NE_FIT_TYPE splitting. In case of
+			 * percpu allocations offsets and sizes are aligned to
+			 * fixed align request, i.e. RE_FIT_TYPE and FL_FIT_TYPE
+			 * are its main fitting cases.
+			 *
+			 * There are few exceptions though, as en example it is
+			 * a first allocation(early boot up) when we have "one"
+			 * big free space that has to be split.
+			 */
+			lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
+			if (!lva)
+				return -1;
+		}
 
 		/*
 		 * Build the remainder.
@@ -1023,6 +1045,50 @@ __alloc_vmap_area(unsigned long size, unsigned long align,
 }
 
 /*
+ * Preload this CPU with one extra vmap_area object to ensure
+ * that we have it available when fit type of free area is
+ * NE_FIT_TYPE.
+ *
+ * The preload is done in non-atomic context thus, it allows us
+ * to use more permissive allocation masks, therefore to be more
+ * stable under low memory condition and high memory pressure.
+ *
+ * If success, it returns zero with preemption disabled. In case
+ * of error, (-ENOMEM) is returned with preemption not disabled.
+ * Note it has to be paired with alloc_vmap_area_preload_end().
+ */
+static void
+ne_fit_preload(int *preloaded)
+{
+	preempt_disable();
+
+	if (!__this_cpu_read(ne_fit_preload_node)) {
+		struct vmap_area *node;
+
+		preempt_enable();
+		node = kmem_cache_alloc(vmap_area_cachep, GFP_KERNEL);
+		if (node == NULL) {
+			*preloaded = 0;
+			return;
+		}
+
+		preempt_disable();
+
+		if (__this_cpu_cmpxchg(ne_fit_preload_node, NULL, node))
+			kmem_cache_free(vmap_area_cachep, node);
+	}
+
+	*preloaded = 1;
+}
+
+static void
+ne_fit_preload_end(int preloaded)
+{
+	if (preloaded)
+		preempt_enable();
+}
+
+/*
  * Allocate a region of KVA of the specified size and alignment, within the
  * vstart and vend.
  */
@@ -1034,6 +1100,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	struct vmap_area *va;
 	unsigned long addr;
 	int purged = 0;
+	int preloaded;
 
 	BUG_ON(!size);
 	BUG_ON(offset_in_page(size));
@@ -1056,6 +1123,12 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
 
 retry:
+	/*
+	 * Even if it fails we do not really care about that.
+	 * Just proceed as it is. "overflow" path will refill
+	 * the cache we allocate from.
+	 */
+	ne_fit_preload(&preloaded);
 	spin_lock(&vmap_area_lock);
 
 	/*
@@ -1063,6 +1136,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * returned. Therefore trigger the overflow path.
 	 */
 	addr = __alloc_vmap_area(size, align, vstart, vend);
+	ne_fit_preload_end(preloaded);
+
 	if (unlikely(addr == vend))
 		goto overflow;
 
-- 
2.11.0

