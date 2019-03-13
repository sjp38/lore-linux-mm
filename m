Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F1B8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECDCD213A2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hjlmlrqo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECDCD213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB4478E000A; Wed, 13 Mar 2019 14:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A63F88E0001; Wed, 13 Mar 2019 14:40:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 908B98E000A; Wed, 13 Mar 2019 14:40:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 441D48E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c15so3101440pfn.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oYZ0d7IIZA63OVMPtucchTyEwGwVOr51nS/0GcejUsI=;
        b=b38nbgbfxXaOSr/JVFPfgw2IOUzZ62yrrE4jj/0k/3MYWYymL1DvRB/czyOJUAo4Sh
         UJBZR1oK6psCfhy4p8tOogxY3BchcakeGjzpPDmCG5AphKGFLonRRSzosNgsCbpY6rk3
         bRi2oEqKV3yOjrX9LCXzGUU7ZYhipuDXnoKcnga34mHcPerraRrM9IokJWfVKcttARup
         zQPXdQInoWPEclXe/vazpvVBWfRqeid9efzKEXk9afihRHzSDD/zyb1JoX1GKDSzcek0
         L/uDgDH/kK3rH5fG7UNXlEtqmXyYJ4FOCgkQD+hv2vc907mbOxzY5ZV5mYIAwzDmdexK
         e5XA==
X-Gm-Message-State: APjAAAXRC4TBkkxDyiTmKqdPAv4FEwFwCaay55IP39cizaPS13BICzbM
	jLOzJ39UHKHQLMVKRRVCndztLasyK0Fdr2D1yiRqMwcQw3P27GUcmGKboMmD76WIPZ63KIru1qy
	kET0zIUPkmgpl0/9kW6ZN7pd2B7skKkpJn6tPqK8UtJJbKyWz+WMu8J17jRlp1Fi6UKStX3+Do7
	hO0QhD6pd0xOOHRyAVnmwd///zxY1xyQohXkq3pxnma9AU09BP1JNs1jX2eNHA1/VqndiMIq/p7
	Zoz4oH0g7ktwxuMI7/0nxmIas1d+qmen8XaTcAyzv6a38TQodX0f0n8ioU3a9NK8Ge0DJddrqz2
	n2O9RxlkDv9hi+oa6PGhIZv0S0pBFanS5LPsKyPFku4vvKbz+UDGc8k+ALA8Su0Xf5huJWGmsml
	U
X-Received: by 2002:a17:902:8ec1:: with SMTP id x1mr47664438plo.52.1552502410948;
        Wed, 13 Mar 2019 11:40:10 -0700 (PDT)
X-Received: by 2002:a17:902:8ec1:: with SMTP id x1mr47664346plo.52.1552502409493;
        Wed, 13 Mar 2019 11:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502409; cv=none;
        d=google.com; s=arc-20160816;
        b=xiZME+vqJRMokHqbNNlyaIcDPJhB8tUXHm/9r8SdbU+QSg/r1ZWjR3yYOWgqo11USs
         xgkH1T4x+fmTTQyCCsoO9cUvQCqXlvUnuo8R0jobBWj9M0kXHKLzV44nH9UoWmtk6gTS
         v3EpbHeRoDncym87K/bDFe9v886fAjqUFG8GMeS6q9BaEf2ZENWyaCsK7KD3jPTGnpaB
         nxahuwx7OIvMOGdBCZEqRz+NEG4LgodHegX+it4MGuv1ZCD6G7WGkElkm/L8z8X5UmwB
         drvQwa7N1pMxYoVj4Adbi+oqYpG82J6H/VEk3oxwCf2dn6/joa4tsJ8LxGpQg55s09Mg
         7goA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oYZ0d7IIZA63OVMPtucchTyEwGwVOr51nS/0GcejUsI=;
        b=fzWPnzwRuDCf4sss39BZtcDUurPqAKGThQuiNKOpjZOmfccJcJtqwcpOwHgaHxYdCM
         KNsQj1pX7iD/mbmQjBAryNaKPguae8CPTpDPC8GFNCHINTWl2TUuzbf7CZreQYxhE4G+
         86gsPtecxbsBB6NBOshH9GOjj1d1kWvyQUi1y19ei6P7HFU93almQPH8aUQlr68sF0tM
         /ffbMe+Fl6eCOMFp5tidTWqi+x+ncgTgiks6x+5nEwD1n4EDguWicpRzRrmOgceDrmq1
         rYusN3ZUWIu6UiZpk4+KqEuZTpvY8VCCrthIpWvMv9ptH3gCzIjpNOLzHVwcIDhlXaRq
         ignQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hjlmlrqo;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4sor2436157plk.2.2019.03.13.11.40.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hjlmlrqo;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=oYZ0d7IIZA63OVMPtucchTyEwGwVOr51nS/0GcejUsI=;
        b=hjlmlrqoyNqh8ZMDotoW00L/DiwAFvmdzuVBO5qEwnjoMnFwBtqz2v/L+DOuv1yKgE
         iFkL77zGQSG/AZc4wPNOQjIbqLrrRer/ITKaec1ZWBYULuL6i8fvKraEMqTdq1EMsv8o
         AgEdc2tWHxo31TIgegeSeM41gD89bZ7OO0hFTWtANImVHQnQsv00bzuBSO/ER/bycJeG
         ONJlxbJ8bQJwg2DEvUCj8jaI2x5boilM8pqZ2jIfebSy4iE4PwulXoZ7Hnt0r1zGorY4
         BXUk1VJpzHHRIOLVSc1IxnGoKFjConEDOx+EayzAIzbbZPedYCaEE3HhZNC/mu7TT5QH
         Yjpw==
X-Google-Smtp-Source: APXvYqwURWhkADd+qAQLVQN9HsSZU8WAqPGG3lUQMz73aqvzLNksvY2rMWiMAIlB7c+cWIpmfqzD0A==
X-Received: by 2002:a17:902:1621:: with SMTP id g30mr47029359plg.116.1552502408883;
        Wed, 13 Mar 2019 11:40:08 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.40.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:40:07 -0700 (PDT)
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
Subject: [PATCH v3 6/6] mm: refactor memcg_hotplug_cpu_dead() to use memcg_flush_offline_percpu()
Date: Wed, 13 Mar 2019 11:39:53 -0700
Message-Id: <20190313183953.17854-7-guro@fb.com>
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
index 0f18bf2afea8..5b6a2ea66774 100644
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
+		memcg_flush_offline_percpu(memcg, cpumask_of(cpu));
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

