Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE265C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70E782077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jrtS3ovn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70E782077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34F5C8E0011; Tue, 12 Mar 2019 18:34:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2373D8E0002; Tue, 12 Mar 2019 18:34:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB78F8E0011; Tue, 12 Mar 2019 18:34:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A83608E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id m10so4708840pfj.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZKgL4zeK+z0St01hNMYKSt6dKMvw92MkjAHduvDs3M4=;
        b=EpssZ/ABixEePqNf0mAttQvDUFYopscv4NGHaBAjHVP64nOcJN/v+aKRygKQtm2vHb
         QMDpvgcxTrDSHxPsPW1oLvDsRJfGk7L/R7xTNS8I4E6HrozIlQ6QIa2/65zFUMmzV5Ih
         ck3FaIh3FvVPUI9l6dOxJHfdzdtb73smNHGuvBbUbUTS8lmlBZ2FBva9QZsduNDfjeoa
         FWootkH5oTHt++SI5ug35rHT2U0yGhu13g0UvQV9GKnVkQWyoRwjZsGy95X5z1G5jtBv
         ZcK/nLMd+8JMLRSalEALM1OSqB2ewAexa2XQ4RjUuk5fT+Fko6Lm0M1ZLE+hr77llEiL
         Ou6w==
X-Gm-Message-State: APjAAAWnw7+kHk5gZRixE3VEBdG1dMl1bpb9zB5QLHjn8Z00RUTE1+nZ
	tClR3N7GRdeup3VSF7EW0wMQM7QLMdglmtSUwCxcselJOPH1EOCbu0SfzjV14vPpUzhuXjZlyu5
	uSk3Jk6aS60uTbKrnf2f+KS+KkO/QH9jLBQVt696vNhvnjVso2uQig6lzEllI/f9yts/1BMpAgW
	s/QX9L07venv/ptiDToSaHVkISzl9+nYoNXFFxowB9GegwbxaJmPRdqF/YPlM0K4Tn8b6DfSGVw
	rOp1WrXphUJiNHvwescbYk52s99oIKVpqM5xfcznO1h1Vo+dFetr5mG+ToTM90c5oRDF5RBTaAG
	rO59aEeFiDcZ7K+La0YBaZJV6k8JpOqqV6kkC1etabjzLobYf8neh947R+QbctRrjAmTTr8ftDX
	P
X-Received: by 2002:a62:1d8c:: with SMTP id d134mr1634666pfd.185.1552430055342;
        Tue, 12 Mar 2019 15:34:15 -0700 (PDT)
X-Received: by 2002:a62:1d8c:: with SMTP id d134mr1634579pfd.185.1552430053923;
        Tue, 12 Mar 2019 15:34:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430053; cv=none;
        d=google.com; s=arc-20160816;
        b=x6e+GEbGo5UYqb/DsEsXxOBkJUjLuoESruHpnMJi2/MBJ1F/1tpPYjPhP2LHSK8z3G
         tPRRFn/KudGOtNxp4tnJ9aLFOtBhLEV2NxDFlaLzkh87JVtUeUfRo7tvwPm9A2gGDPqr
         auB4OfOSm1CvpTkcQtHw3qvqRYQlQTcZ9oI3M4seeRCyJ5CS38nbRyOetSDS97Vhx96V
         rxJrwBunENoXK6EyODvFqqb/hIqZiF1ev2wlIoBOvs0TAnFloXFLGDPjQkg+cpNkvkng
         W5GSi5sNKixa4m5l3M8K7zI6pROQOQEjvvJR8Gio6+AoxJwlwhzNXZE8ESig1YH5UhvU
         /vBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZKgL4zeK+z0St01hNMYKSt6dKMvw92MkjAHduvDs3M4=;
        b=pwgQMc1kn92N6/KH7eb6eVYPUEWV2rI7NuMWavGrF0uALqVF+BpOfGUnO37mEX7/ri
         k6K6sIqGNBV6WR5gH4HNZfC8p+r9X+9mrlY7IdyTgR5FL3eJnk3WTaLvDEjN59B3fO7V
         rB2oKLkkTn4MQf7H7iAevM3epTYb1bm88H6iixwWzHOv7tWh8QPitinoX/dBKvJcPr+J
         BCwXpOj2FybNa+9e2itWevpgdJvz1LIeyzWRy3t5BxXp31Vy0PQRTHpTpIs4s7wxBYLZ
         LkZ0V3cocez6q65GIUrJxfgS7qxV8up0Uwninln+oXuepnQJTWQYr03WvIhb7ROFb9oZ
         NqzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jrtS3ovn;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g14sor15781213pgn.40.2019.03.12.15.34.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jrtS3ovn;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZKgL4zeK+z0St01hNMYKSt6dKMvw92MkjAHduvDs3M4=;
        b=jrtS3ovnWaLclOmLoRw34CUAd+9ENpw1XWtfnLUP1GL2O+JypA4+PCOxzdusoMOk42
         MwG2QHBlvBDAahr7Py5iS1cPYcTR4sq6AHI1i7JxSrfe4Z193iZBEtTWyzzO5M/qeVh8
         y/5CRZ5bEQz7MH/ith0ogencVWwi/1sVtcswJ1X1i7uv6w689GJCGWNslFK0fan/knST
         Evo9ANJxmGdHkfNod5kaooDNe8L3Wnrvb215MwDQyPp9a6tvADnANRyz4q1sEuM5r9Gt
         Xmd1TzZfc/2bDNGBzFEqgP3VGvUWq+PFL50UCQgdo9wcjoPw7/LplLb/nOt9Xy/gnxY3
         svCA==
X-Google-Smtp-Source: APXvYqyS8FSfyNNo22nCX4/AyHeBT/RRTO7S/phayDoBXXlEplUx4YCEb0YjtOc8QhTdvGHx5uHWwg==
X-Received: by 2002:a63:6193:: with SMTP id v141mr8446168pgb.392.1552430053392;
        Tue, 12 Mar 2019 15:34:13 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:12 -0700 (PDT)
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
Subject: [PATCH v2 4/6] mm: release per-node memcg percpu data prematurely
Date: Tue, 12 Mar 2019 15:34:01 -0700
Message-Id: <20190312223404.28665-5-guro@fb.com>
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

Similar to memcg-level statistics, per-node data isn't expected
to be hot after cgroup removal. Switching over to atomics and
prematurely releasing percpu data helps to reduce the memory
footprint of dying cgroups.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 24 +++++++++++++++++++++++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 569337514230..f296693d102b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -127,6 +127,7 @@ struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 
 	struct lruvec_stat __rcu /* __percpu */ *lruvec_stat_cpu;
+	struct lruvec_stat __percpu *lruvec_stat_cpu_offlined;
 	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
 
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index efd5bc131a38..1b5fe826d6d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4460,7 +4460,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return;
 
-	free_percpu(pn->lruvec_stat_cpu);
+	WARN_ON_ONCE(pn->lruvec_stat_cpu != NULL);
 	kfree(pn);
 }
 
@@ -4616,7 +4616,17 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 static void percpu_rcu_free(struct rcu_head *rcu)
 {
 	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
+	int node;
+
+	for_each_node(node) {
+		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 
+		if (!pn)
+			continue;
+
+		free_percpu(pn->lruvec_stat_cpu_offlined);
+		WARN_ON_ONCE(pn->lruvec_stat_cpu != NULL);
+	}
 	free_percpu(memcg->vmstats_percpu_offlined);
 	WARN_ON_ONCE(memcg->vmstats_percpu);
 
@@ -4625,6 +4635,18 @@ static void percpu_rcu_free(struct rcu_head *rcu)
 
 static void mem_cgroup_offline_percpu(struct mem_cgroup *memcg)
 {
+	int node;
+
+	for_each_node(node) {
+		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
+
+		if (!pn)
+			continue;
+
+		pn->lruvec_stat_cpu_offlined = (struct lruvec_stat __percpu *)
+			rcu_dereference(pn->lruvec_stat_cpu);
+		rcu_assign_pointer(pn->lruvec_stat_cpu, NULL);
+	}
 	memcg->vmstats_percpu_offlined = (struct memcg_vmstats_percpu __percpu*)
 		rcu_dereference(memcg->vmstats_percpu);
 	rcu_assign_pointer(memcg->vmstats_percpu, NULL);
-- 
2.20.1

