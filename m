Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B089C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DA862077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k7QPsFLm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DA862077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65DC68E0018; Tue, 12 Mar 2019 18:34:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7FD8E0002; Tue, 12 Mar 2019 18:34:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47F4B8E0018; Tue, 12 Mar 2019 18:34:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9C28E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p9so4687176pfn.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PLL/4LfAnZv9OSID2l2Kyrqdn4GFKp657vXZGXPSxO0=;
        b=D7JGwKTNj3fn9QInxKQqxGgYxjcpXw2MXba85R6sp6oQqwsmZ7wNaBVTALNM7h0HL0
         y5WHPfNACdPNpqD7JnMfTorbSgHKCmB3v0hyU7pmEL64IBNGRFn0l1Gd2rCxS56izYm4
         cVwaiVxUTCOdAjdwTHwcX5Q6XSAnRj1JCxjDZQkGuKOtydwqjjUBlxa2mR6exAuqZ1wJ
         0TsTr9ir4m7tnfmIcvCouQm0dfSjJbN1zT+rVVjD2zvsDer5OXACg4yDilAGv27E3ntR
         lCJ/xkNwiH/VKToAg5QjSjTofUDP0qubW/UbWk0GF4jqda7cqfm3t+z9Q836rs6eBj4S
         IVlA==
X-Gm-Message-State: APjAAAXRVyy6X1kT777fg2EmbtmeCDnBKSQQRI+JtO0POm2TlDVzfeOJ
	JwrdZaSWErOBZt0Sa6ZAaLjGKvX8g6BttwTiQCIa7i8ETEVFt/BhA0Pqu6+aEjpTqWSI+aTzvb0
	TnFHBX0IoUzQ5SCXy+tcgouoTlPU7oKOiA6tCEN609kI6FaLCRNlcskgzcrNQAqAT7zzgeWjvq/
	LKJe0xvMujqmfky1rilKF3Ke6+4zxDeuDpKR/0ppJcKwR2XRvlIHsTgCjse2gujvgcR8zOPVg50
	MMwuKoTuDMW6gg0PU3tnzgBXbvQJM9LlS4xTSV0AP5+kpdhFC9KWNxrHPjVJWnP31sfyX1xmqq4
	z7EFw0byyY9GNEZIkNu30QcpYWOeAtruCuvVXNsGdhf7wPgbAqDQ2np6wvS3DRvTaup4ODQKEvy
	L
X-Received: by 2002:a63:d502:: with SMTP id c2mr15712735pgg.290.1552430058172;
        Tue, 12 Mar 2019 15:34:18 -0700 (PDT)
X-Received: by 2002:a63:d502:: with SMTP id c2mr15712679pgg.290.1552430057163;
        Tue, 12 Mar 2019 15:34:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430057; cv=none;
        d=google.com; s=arc-20160816;
        b=RcZzHLF15K6/au67z9UUX3orPYmI/bHddpwAs+dEaRL117rFgagGkZs9L4z7RTk5Ii
         f+pdg62oGuJ7N13jbGQpFpIsNhlkxcMXbBcyfrXdBkv4N8WENpgskmig4MM2QcKPmwIQ
         G8oZo/E1Zwr1uchr3uVgP7WcNm5EMmCxVNr+Ghjru5k+3QEpgH2QFt24fWTZwu7TmU5W
         1lPlqvqcHYbK1G/mgShxY8f/iPE7gi9zUQJtBuOB0icJwOHDWYMHguXkqArq9rPoTyys
         GBfSKwI9F4FXoBSoeq/RqXZ+s4ic0BNjd7l0ScYX4diJ20/jlMApX2uSLCy6nHI3bTTi
         qlTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PLL/4LfAnZv9OSID2l2Kyrqdn4GFKp657vXZGXPSxO0=;
        b=tPJ11AJ59SzZxKjqZFVLGfx+N2M6jtU/oThAw7naI0EICj6jC6d/VQm+QfqqHCe9RO
         4wkSpVvydS4EeJr0gbdSF42u2FauotiBRxvehF4QjrldCa3KXyB8Y/KUVH+QO7KhJS++
         6GtyQJkAQUInTM/3z5pWkXvwUnyEc85cVVV6Y1Q+bLaefCW6wCGTzCFl/jri6ADvGNJr
         e1UregSXIuep8xNEQbSzsurJ6v69SiXGkFjJO7SLa7MzcRfn3jWx5L0DHSfqhC9NHaCK
         QfyXjZSwSp6TWJfRpyD7XSRWLeyonz7FsDlo1rNW+scEa+0Pm1r7wAPKOQfbTpRWT3Fw
         GPhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k7QPsFLm;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id be3sor15229860plb.25.2019.03.12.15.34.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k7QPsFLm;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PLL/4LfAnZv9OSID2l2Kyrqdn4GFKp657vXZGXPSxO0=;
        b=k7QPsFLmc+eBwxBeIp3C8Q/G3nJeZYxu7XnCay7LwQzvYDlcex8ZmzvLEALm8Ne5rw
         SLlbWdGCJNNNylqAovxOpBlwHo49mZQmWXeGGDXwyl+jLrKRlypwlZLICtOsya6U8/88
         ks2uXUfUmxVwbCUqjNelbhwLdaTnFwnlcnHLdIhCFHmh3+XU5EdrQpfzjqb28c/31aEh
         MWgHKZOniE/gg/g/aN3rT2rpFpy6or34LenQ6dTPqDklOxnQM6FsOdnsHRZ5GK6LSJxr
         VikGyXRKTXAJblZ/1TJmD13Dvb2uX0PrEt3TBBMrq/zR0FyJPp5nDwvQQHtrumlswmgj
         UotQ==
X-Google-Smtp-Source: APXvYqzMJr1pK4nMS01UgtE1/G7AaJ3jZ+2slx1gvSttry8dUdcDTbmwyNqFCWr4j4KvJIjGUZ1mbQ==
X-Received: by 2002:a17:902:2bc7:: with SMTP id l65mr42472606plb.79.1552430056682;
        Tue, 12 Mar 2019 15:34:16 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:16 -0700 (PDT)
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
Subject: [PATCH v2 6/6] mm: refactor memcg_hotplug_cpu_dead() to use memcg_flush_offline_percpu()
Date: Tue, 12 Mar 2019 15:34:04 -0700
Message-Id: <20190312223404.28665-8-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190312223404.28665-1-guro@fb.com>
References: <20190312223404.28665-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It's possible to remove a big chunk of the redundant code by making
memcg_flush_offline_percpu() to take cpumask as an argument and flush
percpu data on all cpus belonging to the mask instead of all possible cpus.

Then memcg_hotplug_cpu_dead() can call it with a single CPU bit set.

This approach allows to remove all duplicated code, but safe the
performance optimization made in memcg_flush_offline_percpu():
only one atomic operation per data entry.

for_each_data_entry()
	for_each_cpu(cpu. cpumask)
		sum_events()
	flush()

Otherwise it would be one atomic operation per data entry per cpu:
for_each_cpu(cpu)
	for_each_data_entry()
		flush()

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/memcontrol.c | 61 ++++++++-----------------------------------------
 1 file changed, 9 insertions(+), 52 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0f18bf2afea8..92c80275d5eb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2122,11 +2122,12 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 /*
  * Flush all per-cpu stats and events into atomics.
  * Try to minimize the number of atomic writes by gathering data from
- * all cpus locally, and then make one atomic update.
+ * all cpus in cpumask locally, and then make one atomic update.
  * No locking is required, because no one has an access to
  * the offlined percpu data.
  */
-static void memcg_flush_offline_percpu(struct mem_cgroup *memcg)
+static void memcg_flush_offline_percpu(struct mem_cgroup *memcg,
+				       const struct cpumask *cpumask)
 {
 	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 	struct lruvec_stat __percpu *lruvec_stat_cpu;
@@ -2140,7 +2141,7 @@ static void memcg_flush_offline_percpu(struct mem_cgroup *memcg)
 		int nid;
 
 		x = 0;
-		for_each_possible_cpu(cpu)
+		for_each_cpu(cpu, cpumask)
 			x += per_cpu(vmstats_percpu->stat[i], cpu);
 		if (x)
 			atomic_long_add(x, &memcg->vmstats[i]);
@@ -2153,7 +2154,7 @@ static void memcg_flush_offline_percpu(struct mem_cgroup *memcg)
 			lruvec_stat_cpu = pn->lruvec_stat_cpu_offlined;
 
 			x = 0;
-			for_each_possible_cpu(cpu)
+			for_each_cpu(cpu, cpumask)
 				x += per_cpu(lruvec_stat_cpu->count[i], cpu);
 			if (x)
 				atomic_long_add(x, &pn->lruvec_stat[i]);
@@ -2162,7 +2163,7 @@ static void memcg_flush_offline_percpu(struct mem_cgroup *memcg)
 
 	for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
 		x = 0;
-		for_each_possible_cpu(cpu)
+		for_each_cpu(cpu, cpumask)
 			x += per_cpu(vmstats_percpu->events[i], cpu);
 		if (x)
 			atomic_long_add(x, &memcg->vmevents[i]);
@@ -2171,8 +2172,6 @@ static void memcg_flush_offline_percpu(struct mem_cgroup *memcg)
 
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
-	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
-	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *memcg;
 
@@ -2180,50 +2179,8 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 	drain_stock(stock);
 
 	rcu_read_lock();
-	for_each_mem_cgroup(memcg) {
-		int i;
-
-		vmstats_percpu = (struct memcg_vmstats_percpu __percpu *)
-			rcu_dereference(memcg->vmstats_percpu);
-
-		for (i = 0; i < MEMCG_NR_STAT; i++) {
-			int nid;
-			long x;
-
-			if (vmstats_percpu) {
-				x = this_cpu_xchg(vmstats_percpu->stat[i], 0);
-				if (x)
-					atomic_long_add(x, &memcg->vmstats[i]);
-			}
-
-			if (i >= NR_VM_NODE_STAT_ITEMS)
-				continue;
-
-			for_each_node(nid) {
-				struct mem_cgroup_per_node *pn;
-
-				pn = mem_cgroup_nodeinfo(memcg, nid);
-
-				lruvec_stat_cpu = (struct lruvec_stat __percpu*)
-					rcu_dereference(pn->lruvec_stat_cpu);
-				if (!lruvec_stat_cpu)
-					continue;
-				x = this_cpu_xchg(lruvec_stat_cpu->count[i], 0);
-				if (x)
-					atomic_long_add(x, &pn->lruvec_stat[i]);
-			}
-		}
-
-		for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
-			long x;
-
-			if (vmstats_percpu) {
-				x = this_cpu_xchg(vmstats_percpu->events[i], 0);
-				if (x)
-					atomic_long_add(x, &memcg->vmevents[i]);
-			}
-		}
-	}
+	for_each_mem_cgroup(memcg)
+		memcg_flush_offline_percpu(memcg, get_cpu_mask(cpu));
 	rcu_read_unlock();
 
 	return 0;
@@ -4668,7 +4625,7 @@ static void percpu_rcu_free(struct rcu_head *rcu)
 	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
 	int node;
 
-	memcg_flush_offline_percpu(memcg);
+	memcg_flush_offline_percpu(memcg, cpu_possible_mask);
 
 	for_each_node(node) {
 		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
-- 
2.20.1

