Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5354CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F08C320693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mJoTELo+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F08C320693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8B1C8E0005; Wed, 13 Mar 2019 14:40:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A40508E0001; Wed, 13 Mar 2019 14:40:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 819F68E0005; Wed, 13 Mar 2019 14:40:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 437248E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f12so3209902pgs.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CNCy2SGf01agfPIUoI0mNB3tC3JUsDAW7lCdNygAAfg=;
        b=GAfgxUUn3MY3mjLMtVVZQQmtEPZK//MmTg/N2zy72MvdTgIsUZAOQuInr7KMA6ji6B
         6mYx9+f1goug3eU3Z9hoIBkGxqaOz4zL3nNez8rzNW/+ocCjZp8EhlGT6vuSQdtyYcuz
         aZ+ncV10ce8TTVWKfJZL5D41KN0TwCszHd/JGXmdlRtFTttTn81DJHH373HdjsQDo9HZ
         RDmH9xn+TG2/4HmgcPLtr8KBMkbYchm2bi2GSbHVTjzsETkUmoDehxILmvqRqGjjwWOq
         9YzO3IsD2Cf6rNyPYKuYhiCDR6mPUKu2uc8oUGkAr0OFjxy4TvU207zGB8JSOySfTFI0
         N/+A==
X-Gm-Message-State: APjAAAUE69N4kBGhRChKQA9OCyAisvlAeKxv92dEa6NOOTbzVyJZoqtB
	NLpeCAq656bGNTUvrAAPxR9fzcng1kh1JMpK+pP+rZFKxHPY8owyRqZbjD7s74vB5Njrpx/3PkP
	wnJq3YIIgtcM7p6q3ULFT5Zgxf8t9qOX8zrwkz7IkbEuZFDcZKh45CQmcwESmoVBSylOd7hDzNS
	RDrrEWEGzY4fNHh1/PZsDfQZJs+ijMy0rYn0bI/VfWnCdsBvh72Bmv1POl6mbeHsS810S6PZU7P
	+b3JL5xSk36xcekcu59oayCLjatR0jcgJTtW6gtFqbjIo9g2P1vUfKbS95tJzAOPk4lnWvbMr//
	lamECFs8a7f1NhTOLFlBZ/HaeOxvtdH2kOyh7lI0NV6Ifp7JXGuPxBKoy4LVW15ZDbIVtUza8bk
	q
X-Received: by 2002:a63:204d:: with SMTP id r13mr15642468pgm.63.1552502403916;
        Wed, 13 Mar 2019 11:40:03 -0700 (PDT)
X-Received: by 2002:a63:204d:: with SMTP id r13mr15642379pgm.63.1552502402433;
        Wed, 13 Mar 2019 11:40:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502402; cv=none;
        d=google.com; s=arc-20160816;
        b=kTfMTGjXeD+DN9o63mATU1B1N4rmeTVvLhr/nYGCKr0bDMpRZplIk2xeSZQruehPtX
         /WVSLyifi8Q7hrrm2+lb2V5mxYY6tIrmV3CfG7JmPvvzrLNNNuU5AKycWJCCw2Kd8xyK
         a75aRC0iHx5deQdwXM5p/AdXN1cLlR1GSkHQpelsUhGQVD0MvOxzIx7TxtqIpPmeXb/R
         AqyrT2QKYkSM4eO1uUn8VAcrh3g+IlsCPI1FbNXDY0jBHT+VI14nifsJsLKc5nox5ZpM
         2NSOU9lDTAYIxvfP2E3RAtxjn29Py1cN62zspm1IXd1V/4L6WW0MHJYS01yhtdECnt0H
         ltHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CNCy2SGf01agfPIUoI0mNB3tC3JUsDAW7lCdNygAAfg=;
        b=eI5mn2NzVhpAypM/ibGzS8d59dxKb+pO5VHg0qk6riXxj99UPuTJMDWAnzjCTlNstA
         uROLVYJMNQVvbPPs/BmN7yB045thTQoB8isOJIu5BgAsamXiFAmYhpn6VL0ZFIoqgomJ
         SkIDMXG3rxPcoXn6F7CQ1xFTE0jaFUr/S6qy/wfl58cLatXnQMkYSQza3Ta82RrZii/O
         +Iy/u/wV7mxNsBm2Rlw1Mlh3EvV2mlq9Iu9fryZF1D5GErcYbfRe7mYFXWOF+wNwu3so
         2E806+MKSrEwKNxQUrFFOceTmX37cmh0Jvc9nesqEjVoPz2//JFOtjdPsUgQYAI998z2
         gu6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mJoTELo+;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor19257616pgb.54.2019.03.13.11.40.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mJoTELo+;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=CNCy2SGf01agfPIUoI0mNB3tC3JUsDAW7lCdNygAAfg=;
        b=mJoTELo+iyROS0mFl9JODL/KJs5WbYUC7TBdhw+76tWgqH79EvhDRLhYvM6Sgp0Obr
         IIUaSmjkcLfafkzP8D998BLCCUbn29r22WjbrUISPJU1ke9uqeuNTiUmPf89QONLFc/F
         BFgCqN2hGPSuCMfgkRtu3quhTy0FgEQA/Bw+whplexOU2he9lOsCKsgTzz8JyU37U2Fr
         3xLPXOOOuQi6EopT/hxlDOLaIkbd6SSnjKwDeHptJQg4ChWdB9ombVnwH1nIbrcuuFm1
         3JSvgsQJlzFt90QwHP+m0zCqhkxrBOwdWCFKbCP8vcJM39cCBMgsEHHKjS2SVmTPoFHu
         tBVg==
X-Google-Smtp-Source: APXvYqwOMrYCwRc7DDWC75xLvCPqxE473YDMEyQ6fsG8ge15uJdRhs1wjwu7FSlcZNM3ajMSVef6Ig==
X-Received: by 2002:a65:424d:: with SMTP id d13mr27684845pgq.203.1552502401749;
        Wed, 13 Mar 2019 11:40:01 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.40.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:40:00 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 1/6] mm: prepare to premature release of memcg->vmstats_percpu
Date: Wed, 13 Mar 2019 11:39:48 -0700
Message-Id: <20190313183953.17854-2-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190313183953.17854-1-guro@fb.com>
References: <20190313183953.17854-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Prepare to handle premature release of memcg->vmstats_percpu data.
Currently it's a generic pointer which is expected to be non-NULL
during the whole life time of a memcg. Switch over to the
rcu-protected pointer, and carefully check it for being non-NULL.

This change is a required step towards dynamic premature release
of percpu memcg data.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 40 +++++++++++++++++-------
 mm/memcontrol.c            | 62 +++++++++++++++++++++++++++++---------
 2 files changed, 77 insertions(+), 25 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 534267947664..05ca77767c6a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -274,7 +274,7 @@ struct mem_cgroup {
 	struct task_struct	*move_lock_task;
 
 	/* memory.stat */
-	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
+	struct memcg_vmstats_percpu __rcu /* __percpu */ *vmstats_percpu;
 
 	MEMCG_PADDING(_pad2_);
 
@@ -597,17 +597,26 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
 static inline void __mod_memcg_state(struct mem_cgroup *memcg,
 				     int idx, int val)
 {
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 	long x;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->vmstats[idx]);
-		x = 0;
+	rcu_read_lock();
+	vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
+		rcu_dereference(memcg->vmstats_percpu);
+	if (likely(vmstats_percpu)) {
+		x = val + __this_cpu_read(vmstats_percpu->stat[idx]);
+		if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+			atomic_long_add(x, &memcg->vmstats[idx]);
+			x = 0;
+		}
+		__this_cpu_write(vmstats_percpu->stat[idx], x);
+	} else {
+		atomic_long_add(val, &memcg->vmstats[idx]);
 	}
-	__this_cpu_write(memcg->vmstats_percpu->stat[idx], x);
+	rcu_read_unlock();
 }
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
@@ -740,17 +749,26 @@ static inline void __count_memcg_events(struct mem_cgroup *memcg,
 					enum vm_event_item idx,
 					unsigned long count)
 {
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 	unsigned long x;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
-	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->vmevents[idx]);
-		x = 0;
+	rcu_read_lock();
+	vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
+		rcu_dereference(memcg->vmstats_percpu);
+	if (likely(vmstats_percpu)) {
+		x = count + __this_cpu_read(vmstats_percpu->events[idx]);
+		if (unlikely(x > MEMCG_CHARGE_BATCH)) {
+			atomic_long_add(x, &memcg->vmevents[idx]);
+			x = 0;
+		}
+		__this_cpu_write(vmstats_percpu->events[idx], x);
+	} else {
+		atomic_long_add(count, &memcg->vmevents[idx]);
 	}
-	__this_cpu_write(memcg->vmstats_percpu->events[idx], x);
+	rcu_read_unlock();
 }
 
 static inline void count_memcg_events(struct mem_cgroup *memcg,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c532f8685aa3..803c772f354b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -697,6 +697,8 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 					 struct page *page,
 					 bool compound, int nr_pages)
 {
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
+
 	/*
 	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
 	 * counted as CACHE even if it's on ANON LRU.
@@ -722,7 +724,12 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 		nr_pages = -nr_pages; /* for event */
 	}
 
-	__this_cpu_add(memcg->vmstats_percpu->nr_page_events, nr_pages);
+	rcu_read_lock();
+	vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
+		rcu_dereference(memcg->vmstats_percpu);
+	if (likely(vmstats_percpu))
+		__this_cpu_add(vmstats_percpu->nr_page_events, nr_pages);
+	rcu_read_unlock();
 }
 
 unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
@@ -756,10 +763,18 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 				       enum mem_cgroup_events_target target)
 {
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 	unsigned long val, next;
+	bool ret = false;
 
-	val = __this_cpu_read(memcg->vmstats_percpu->nr_page_events);
-	next = __this_cpu_read(memcg->vmstats_percpu->targets[target]);
+	rcu_read_lock();
+	vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
+		rcu_dereference(memcg->vmstats_percpu);
+	if (!vmstats_percpu)
+		goto out;
+
+	val = __this_cpu_read(vmstats_percpu->nr_page_events);
+	next = __this_cpu_read(vmstats_percpu->targets[target]);
 	/* from time_after() in jiffies.h */
 	if ((long)(next - val) < 0) {
 		switch (target) {
@@ -775,10 +790,12 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		default:
 			break;
 		}
-		__this_cpu_write(memcg->vmstats_percpu->targets[target], next);
-		return true;
+		__this_cpu_write(vmstats_percpu->targets[target], next);
+		ret = true;
 	}
-	return false;
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 /*
@@ -2104,22 +2121,29 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *memcg;
 
 	stock = &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
 
+	rcu_read_lock();
 	for_each_mem_cgroup(memcg) {
 		int i;
 
+		vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
+			rcu_dereference(memcg->vmstats_percpu);
+
 		for (i = 0; i < MEMCG_NR_STAT; i++) {
 			int nid;
 			long x;
 
-			x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
-			if (x)
-				atomic_long_add(x, &memcg->vmstats[i]);
+			if (vmstats_percpu) {
+				x = this_cpu_xchg(vmstats_percpu->stat[i], 0);
+				if (x)
+					atomic_long_add(x, &memcg->vmstats[i]);
+			}
 
 			if (i >= NR_VM_NODE_STAT_ITEMS)
 				continue;
@@ -2137,11 +2161,14 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
 			long x;
 
-			x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
-			if (x)
-				atomic_long_add(x, &memcg->vmevents[i]);
+			if (vmstats_percpu) {
+				x = this_cpu_xchg(vmstats_percpu->events[i], 0);
+				if (x)
+					atomic_long_add(x, &memcg->vmevents[i]);
+			}
 		}
 	}
+	rcu_read_unlock();
 
 	return 0;
 }
@@ -4464,7 +4491,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (memcg->id.id < 0)
 		goto fail;
 
-	memcg->vmstats_percpu = alloc_percpu(struct memcg_vmstats_percpu);
+	rcu_assign_pointer(memcg->vmstats_percpu,
+			   alloc_percpu(struct memcg_vmstats_percpu));
 	if (!memcg->vmstats_percpu)
 		goto fail;
 
@@ -6054,6 +6082,7 @@ static void uncharge_batch(const struct uncharge_gather *ug)
 {
 	unsigned long nr_pages = ug->nr_anon + ug->nr_file + ug->nr_kmem;
 	unsigned long flags;
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 
 	if (!mem_cgroup_is_root(ug->memcg)) {
 		page_counter_uncharge(&ug->memcg->memory, nr_pages);
@@ -6070,7 +6099,12 @@ static void uncharge_batch(const struct uncharge_gather *ug)
 	__mod_memcg_state(ug->memcg, MEMCG_RSS_HUGE, -ug->nr_huge);
 	__mod_memcg_state(ug->memcg, NR_SHMEM, -ug->nr_shmem);
 	__count_memcg_events(ug->memcg, PGPGOUT, ug->pgpgout);
-	__this_cpu_add(ug->memcg->vmstats_percpu->nr_page_events, nr_pages);
+	rcu_read_lock();
+	vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
+		rcu_dereference(ug->memcg->vmstats_percpu);
+	if (likely(vmstats_percpu))
+		__this_cpu_add(vmstats_percpu->nr_page_events, nr_pages);
+	rcu_read_unlock();
 	memcg_check_events(ug->memcg, ug->dummy_page);
 	local_irq_restore(flags);
 
-- 
2.20.1

