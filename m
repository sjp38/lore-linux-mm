Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93A72C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34B1A20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V2nhvsUU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34B1A20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D52E28E0004; Thu,  7 Mar 2019 18:00:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDBAF8E0002; Thu,  7 Mar 2019 18:00:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B075F8E0004; Thu,  7 Mar 2019 18:00:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6550B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:00:40 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f6so17929987pgo.15
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:00:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2zD5nbQljCuVZEpjxLRZoYsTQjqMS5l1KBU8Q+Sdfe8=;
        b=r0P5tS96oy57mHdytocBnlPVNR93IeULEgneezapjFsXMGrSK2gJ9kCjkLq9VBi0LY
         l40DP9k1ecpqbC3Yma2UjDEC3cqWKNZV9OskQBHy//E1h3IMrno2f2fqAjVUSJFUMO+u
         6QWePw6iMosHLHTSKm7qGfS8qtvML8mPa3kJ20FRvQreEnVQocMpuaCuGZBHQqDKguQl
         KgF5jGSuyUQ++I9AFKNWfGOgHbBfH/hezA+5xN6MagDOMk7eteT0nssrGghEodKZ4iyV
         VgyuIrYdoW5pACD8moKof3kXja8ExYsHyf0tWBTAQw0FT1IvsG02PNUq698MFTrmG3Q6
         WKmw==
X-Gm-Message-State: APjAAAVGbZHLfYixtoAv03MZNr2fimTMaSXQVsIZZZzSAFuhz0wEAW+P
	Gkuz27Vu+XQvp6MBsjPQIYOyRWDlb6DdoW+rIfHS9YBfwVdzlG+57NdpPX1TGnjb5e3qqM1x9a2
	LG6FMxgbyscnmqLsz8BGCPqkrifhfMBlUe1avbqaWhUYg7nSfUeRUu/+UP9fo8ZElfJWNv2AZ9Q
	MYR3yMMqybTlQg4AfCDM2uT6EQWi0VW65sAbCIhfr8lD5dawt1JmXVkGTWX4zi5j/mE32R7vA9q
	3BbI1ussZx0vrjjGh3145nDX9Kc/StU3MWlM2rTfu+GKRMfw/wai2MSDg8poSCDhiy/qxFLKO/d
	RiiLNzUph/oIDIpsJ0m9pc4RXibGC1mypUX1ZeNEDpQzuMl27YIIfRWVy7abIJOZDtZYQ3LXYvq
	Z
X-Received: by 2002:a63:f648:: with SMTP id u8mr13374540pgj.91.1551999639933;
        Thu, 07 Mar 2019 15:00:39 -0800 (PST)
X-Received: by 2002:a63:f648:: with SMTP id u8mr13374459pgj.91.1551999638738;
        Thu, 07 Mar 2019 15:00:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551999638; cv=none;
        d=google.com; s=arc-20160816;
        b=ua/QYeMTpjRpo59WBV6qL3nwU21quhQwxg9lkd9KBEIdv38nxMLuHkaiFCVJ9YLxSV
         j7JFJxlQZe0uP9OO62ySeX5Oj856m5ki3vgLJRAwroe5/VMx6uYZs3YSUPv36x+ZOPxH
         ank5HkVhd/JhhMaUaEWiOLH1c+6kh0MFVwY+cby2N3UiRoYuEpTVRE0/hfOHbB4o10Y0
         YdnTjBxeODh01Eovr2t1v1Aeoc2UjuvI52+48lQeC3YfQgXq+fxJF/13H32IlBsf4IFH
         cMwhjTB30xNSxwL2xjU61kc1SCT/mLlf+wRYJRbcTF1xJYbrJUPiwDk5ExWv/F+SGMcu
         CUBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2zD5nbQljCuVZEpjxLRZoYsTQjqMS5l1KBU8Q+Sdfe8=;
        b=embJrdm32xNs9YieZdeMWJbg7lPPDXUZ1OthwKmlLa3aItcqVl85QHBckuzlNFjLQX
         4ys1A5hMVHKnWBGjVJWr1gZjXL1pcmUyW9HiAyOVcHEGZ8usnt7ZOCVMhGdlAfzwNfmk
         E4s0XhdIi5deMuFP6B8kaQL6EgWLphhk0AD5B/AC+89NH/OeLGJpB67TkM87FF2izOwl
         p05gPZpLhhFyNrlWqiLL4hx3wSMeXx36HAHwULVTbi4qYPEHzA3YtVqHbSKvEKvKF5D3
         d72QbTA28MER1IppGi2C4A65NYx9d6oOkNCdCFQj5UdDN7Pqp2KOyl8IGYW5m62GkhYi
         R8KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=V2nhvsUU;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k190sor10086711pgc.32.2019.03.07.15.00.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 15:00:38 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=V2nhvsUU;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2zD5nbQljCuVZEpjxLRZoYsTQjqMS5l1KBU8Q+Sdfe8=;
        b=V2nhvsUUyX9TXoESjQOB5eMsm4xQAzZMmf0SgpDQU7WMnu5kBdLHv4JgEV90jf5GaP
         uLrVJnKQZ8gCQy3lXQGbFxG1kH6Z73WBa/x9i686DxKP3jrlEbvTTwherxEuLZByWTzX
         nadisGvGx7A5xom2xCSmhRoOfxmH8wlh5mbXW6Hg3mlOTrGa45fdNr1Ippn1B2ZD2QpU
         VC0ELQPKCVT6Wan0Qj5xK8EZevASG2q8+5N/HDZ8/O6H7arZTtoWzTyiGhyBwggpbdid
         /n/RTPzgam2gKExM2V7cwQSMLg41yt45EO4w/irg/VubtzXAhB5+O97LteDwWzCzNe9A
         WVTg==
X-Google-Smtp-Source: APXvYqx/NgILDTTJRVUsh55o+xNSO6KhGs1zskXimET2dZyUOOxDdBosr71+ch0fXmf8EM8Wuep8xA==
X-Received: by 2002:a65:4243:: with SMTP id d3mr13633502pgq.56.1551999638120;
        Thu, 07 Mar 2019 15:00:38 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d18b])
        by smtp.gmail.com with ESMTPSA id i126sm11864806pfb.15.2019.03.07.15.00.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 15:00:37 -0800 (PST)
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
Subject: [PATCH 1/5] mm: prepare to premature release of memcg->vmstats_percpu
Date: Thu,  7 Mar 2019 15:00:29 -0800
Message-Id: <20190307230033.31975-2-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190307230033.31975-1-guro@fb.com>
References: <20190307230033.31975-1-guro@fb.com>
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

