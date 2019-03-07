Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F5DC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9935520840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xm1kKMC9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9935520840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2978E0007; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1A748E0002; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB7C38E0009; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6604F8E0007
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d5so19636665pfo.5
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:00:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JZX5VXWRV31e/dorMIyOAZjwZx1Lnus1V/4dOHz/P7o=;
        b=sKVHQ8P2PD1QG3uvp/Agrcv5Ef8alVxF3XuIhVlC+Z5S2coqtWAasX6VJOkFUOH48d
         E0qATS+6blzW58bX6zUXLGLs7Ov+6LnzZjk1XG3AoVKaQA3xYyE3zA5vLwswgJW2QHjM
         BF/He5Y0WbzjohcQpwDWZ8SpvRVgG10/rpX1bGK+3sF0im/gu3sd0aoLDJHxV+mYpIYD
         NSLNXahBeDrcziZXUDIq4B2HfEsPyzfc543LakooAvqlasYRo3irK8V1VUSOP86aLyCe
         bZp2bxwGZaDUcMtdpXBhGJKcBunqvbXu1cRj2/cZTLWDvJ87gI6m2SlpoYmySj31ZZXP
         8vmA==
X-Gm-Message-State: APjAAAXZpU9qcKnRpctE6qdE+45xBzCNBHg5dQsybEMxBDVFO0A94RP4
	Ez2ctld4eit0VSu5PqdOAk5z3AfuDHYDrV98soat00cVrkJSre2npj12opz0Wqj1GOwPbomdCzc
	Y1+EToCTzDFK6NtXwZQYwjFNUIuuv3Nfm8y7QBjr0kw1+k0fs3lIXl3ZRP8S90Lm/MCO2y31cTm
	vKbjuHz5EZ+owBojRKu9a466gXNqMFigzrXGefCCe2/RINGOGbXDfKo25HGf3+TaV7bM08QRsB9
	r41RIZWktNA89J4xS5yG3yLXAiI9rdVblBZ2n+vZ8ENDJCYtM4CBxx+AnCLS3pImBvEJY7GD3zH
	O1D3LrJyINV/f4B6eoaETTgaK83TP2DeDSjrlwpXf6WUBFbrprW5lYYn3gK+StmVZJxN3VsU9ZY
	k
X-Received: by 2002:a62:f20d:: with SMTP id m13mr15051947pfh.174.1551999644982;
        Thu, 07 Mar 2019 15:00:44 -0800 (PST)
X-Received: by 2002:a62:f20d:: with SMTP id m13mr15051816pfh.174.1551999643345;
        Thu, 07 Mar 2019 15:00:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551999643; cv=none;
        d=google.com; s=arc-20160816;
        b=SP/er3PRydp0E5l+z9LTKXlZM0KDimOMufn+WCbCBd4B0aRvYm2AI1aUe+4nmsmoEe
         DmxW5JXpUg9KMvEw6xdfiqh/nmHoa7REGhmDXlF58hQyMkwsnsIKA5YHgv5AHtGp6233
         T8IciBaek01sNSPXYvW1FFCVtLmGoxyEB9mRkZKRuU/XD4lnozeifcUEhqDL0/2x5VIF
         w4yw2nmbMsWZKB3NGZlYG5OOA6kUQrHMTpaIBSBXXj1RF4lbMj+QsNZuHvnPJx/kjSB4
         K6LlzzKlSPJlUDVtetbSKqqZAvY/18v+4frwHmrT2ma7R3dVPzXAXQnzZO+7cZecfX6s
         iQ4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JZX5VXWRV31e/dorMIyOAZjwZx1Lnus1V/4dOHz/P7o=;
        b=uaoA5jlut1xLs+c6LAarnXKbGzm+UiCrUZ2YtFC+wxVIkbElbulzXrxBZ5mjkJeZq7
         4vBO0Yw44KkME1AZvdPp0rj5o2IlpVucuAnZyNvKzsM0iQjwIB58IdAqZXRdSXvDzrSu
         cs/D8UHBbz07Wqp/4TQNOpMuhzO1PlWGEpogLqk4DsWQKNxB8uSHad+veUVHja0AgvZm
         35P73fgk0Hssu/KagW/xMbE5XcVX/BwfTs28cG5nPuhhucj2H/IkjKdxvb+7jn5R9Iqi
         hFbRPwv8dHIATnheHafnTHZ7tX4CenQL/asnnP8lx5ojOI/SbeTSdKtx+J/rGZ0nGSEv
         1xtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xm1kKMC9;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10sor9528123pgt.24.2019.03.07.15.00.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 15:00:43 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xm1kKMC9;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JZX5VXWRV31e/dorMIyOAZjwZx1Lnus1V/4dOHz/P7o=;
        b=Xm1kKMC9B2w4t88wFEbcqoH6e3UjYFTd0TJSqsFikzco+7ogxo96EX0nP16sMJbA/D
         LLSVBZJBDEz2s/pXjjVn9UsVgWRbZVxLUbIf2ptRACQNUAGqUprEX6a1DRinHKw5cqeA
         saSPrh0ac7GIbDXM2tqBY5JabMVeKZK5pq2AM6gHHd2NgUEUM5jV35C6N+sm6BhlMSik
         OrbKHp1PzKc/8Lqk+TeUJEZBxlxgSWd6IjScBzR+zqvggjmPRH3lsIVbl0hk5XRSCeMU
         7HEsMpuv84maXQ4wCXQUhIkvGmgg1GgNgoeCuvcEah9F6lF2KaEUozcRhvJrkXRIRfs3
         bBLQ==
X-Google-Smtp-Source: APXvYqyQ0WlWO2ShjokCb1rn3KTI4g8tpX1+qir97KWkQkaWwmJJtvRCFS7kkyFXX+SvJ87Cs4JUAQ==
X-Received: by 2002:a63:8b42:: with SMTP id j63mr13351207pge.79.1551999642755;
        Thu, 07 Mar 2019 15:00:42 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d18b])
        by smtp.gmail.com with ESMTPSA id i126sm11864806pfb.15.2019.03.07.15.00.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 15:00:42 -0800 (PST)
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
Subject: [PATCH 5/5] mm: spill memcg percpu stats and events before releasing
Date: Thu,  7 Mar 2019 15:00:33 -0800
Message-Id: <20190307230033.31975-6-guro@fb.com>
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

Spill percpu stats and events data to corresponding before releasing
percpu memory.

Although per-cpu stats are never exactly precise, dropping them on
floor regularly may lead to an accumulation of an error. So, it's
safer to sync them before releasing.

To minimize the number of atomic updates, let's sum all stats/events
on all cpus locally, and then make a single update per entry.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/memcontrol.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18e863890392..b7eb6fac735e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4612,11 +4612,63 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
+/*
+ * Spill all per-cpu stats and events into atomics.
+ * Try to minimize the number of atomic writes by gathering data from
+ * all cpus locally, and then make one atomic update.
+ * No locking is required, because no one has an access to
+ * the offlined percpu data.
+ */
+static void mem_cgroup_spill_offlined_percpu(struct mem_cgroup *memcg)
+{
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
+	struct mem_cgroup_per_node *pn;
+	int cpu, i;
+	long x;
+
+	vmstats_percpu = memcg->vmstats_percpu_offlined;
+
+	for (i = 0; i < MEMCG_NR_STAT; i++) {
+		int nid;
+
+		x = 0;
+		for_each_possible_cpu(cpu)
+			x += per_cpu(vmstats_percpu->stat[i], cpu);
+		if (x)
+			atomic_long_add(x, &memcg->vmstats[i]);
+
+		if (i >= NR_VM_NODE_STAT_ITEMS)
+			continue;
+
+		for_each_node(nid) {
+			pn = mem_cgroup_nodeinfo(memcg, nid);
+			lruvec_stat_cpu = pn->lruvec_stat_cpu_offlined;
+
+			x = 0;
+			for_each_possible_cpu(cpu)
+				x += per_cpu(lruvec_stat_cpu->count[i], cpu);
+			if (x)
+				atomic_long_add(x, &pn->lruvec_stat[i]);
+		}
+	}
+
+	for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
+		x = 0;
+		for_each_possible_cpu(cpu)
+			x += per_cpu(vmstats_percpu->events[i], cpu);
+		if (x)
+			atomic_long_add(x, &memcg->vmevents[i]);
+	}
+}
+
 static void mem_cgroup_free_percpu(struct rcu_head *rcu)
 {
 	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
 	int node;
 
+	mem_cgroup_spill_offlined_percpu(memcg);
+
 	for_each_node(node) {
 		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 
-- 
2.20.1

