Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E0D8C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBD4720840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cOsHXC8q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBD4720840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195378E0005; Thu,  7 Mar 2019 18:00:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F5DD8E0002; Thu,  7 Mar 2019 18:00:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7A958E0005; Thu,  7 Mar 2019 18:00:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 951438E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:00:42 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o4so450014pgl.6
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:00:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XVAzLd6hdIPZj35NxoEZAwxg04Tr002qNrQDR1YF6Fc=;
        b=IaNMktEbM53lYajwIkJoEdFjgOFhVRENbH/3nL3COr7c9PKYhyeDLSHmdAap1rNs3q
         LiNYEF73FlEoGuTVKJeYjFoqDGLnY9788xru9a6OpQjX4M04YYxqdn4sIZAOgcncMrXb
         L8OV+NwJYCMWXqexipEKA1q9g8h8pT4I6V8k713/R1O+lZEkDMYTMUWqh3Mbdpfa8z05
         5KIbJC5zo76+gNtMAhmlKeMQnFVFSX3Wem/yHSPT4ZTLWNtN5FOFCsrVm5JXjjYVPG+p
         Nu0shKfCH9E9Ijm5lmNtumSWTGNiUxbmQU6ii92s1AW7ijTjn9XYnzRPt0YRLiDbDFrn
         /UGw==
X-Gm-Message-State: APjAAAV4j9YRu9KBP0YT2o6VujfK1kj6sYXLXXYKNbfha6KQSga3uPcB
	+HPuabq9JWsrWj7abJij8y5xIWlgukcwrNZpoYxuaWkuWW2Pi7nw+DK6pwmd8vyUsPj9WBEslBp
	TA+bFvqGufQMqUDi4t/r5Oqep7f0uBWYjqT+khfPcqqbrAtXK28dWrQFXZmAXO1rBjDR+m1d8TI
	d5dFWGnDxpaADB1VTcdvcGR3ja9C9GIifcx0mAPSg0B4sJ6yso2Brw7YslrLLmeDOFkndG9CYsS
	t/f7HOijrk7bv9u8KQPsRH+tblivWTEs5guZXz9bJp8KQZNXORLsMSDz3/f3K80a7B6xCopZ55y
	DPWjGUFW00cCgciPYOfzMyZVcn8dQePaaHGwx154golFh7KiTVaMl6xculCwzWJqmO7RJgEnEZD
	1
X-Received: by 2002:a17:902:b493:: with SMTP id y19mr15773222plr.9.1551999641962;
        Thu, 07 Mar 2019 15:00:41 -0800 (PST)
X-Received: by 2002:a17:902:b493:: with SMTP id y19mr15773054plr.9.1551999640273;
        Thu, 07 Mar 2019 15:00:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551999640; cv=none;
        d=google.com; s=arc-20160816;
        b=tFFi9uF3ExeZP8XCbOehNZ/Hj26WdOR5/BjCuKHe9emOWDkoWNJ685f/eRZir2xcLg
         /qtOIEPp9uILHDxon2+iRMUpp689W8gXBuDAH/WfRl1A8z+n8c2/N0UGHQbEfx7aY71S
         qL3WNlzgM3tQ8rMatCH1VX4sVFco3tzEzZYMTJ+hnUanN83IWwRO3HQXZ+qyveb2Axwy
         WzGIZ+2ZZ8R5lEw5lS1WEXsmrS+3CEoT7tfxpZkjrZH5M1PLpzsgL5qQ7AhhMnf1c/9T
         XvgHG5r8FiwLAeU5Azy5TwI1R1uB9OxORAA1tUd4iXNaXRLehUX3CtL9WA3N27+zCiCW
         TSoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XVAzLd6hdIPZj35NxoEZAwxg04Tr002qNrQDR1YF6Fc=;
        b=zG+4bBnZ5X1eM8OnowMyI6IkrHlLycsYwf8ZfInCdj5b7kXttwGsrWQLWIv2I/5hse
         cSiL+BjhWTGcUndBtYI19pbHoQ5UmKh8TSpuj4S0Lf16UhMvJWfCVvlIL1fKzpwBPNxK
         KYx78Ls9jIF3NIkiT4vWsg6z2TmhQwozOlIaVLCTPNVih9uN3pD5epLZXEqbMXAvzMhp
         7OilehA2MCW7+9cBqTsKeLP6MDo3BH7u7gohvpCmLKkJ5wzyivxyN+8gcu9m5jO0J3CJ
         FNpRn4JFiPalrZSXZPJywPrfR5NizvKDpggOpScDwWeKxQatIiqd6HbPpt5HNatYPJ+U
         mNlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cOsHXC8q;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4sor10087520pgr.3.2019.03.07.15.00.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 15:00:40 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cOsHXC8q;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XVAzLd6hdIPZj35NxoEZAwxg04Tr002qNrQDR1YF6Fc=;
        b=cOsHXC8q1NlpYG2/9ohgQ48P9MJVgooAsBgk28QQbidN3suqAiF/mMOKqLcnQisWny
         D5RakrhfayswSpAIWwziHUMt52tfLfZKPBc/1xsRfVDrRIrqSdV++twQXPUiCwW8KvDa
         FfffGsXE2gkHQZPwi+1Kh3E4yORU25DiUZHtZhxNTkIiBGwmPNH38R/SFQP7Uv+ZDNiI
         45Ptn3Amz54/mVGvbfQduB5lcVD8Qx9kFvrx+5XPyFShwlyP/VnzRKGtbQyUG9wbXLUs
         MPg4Z5uW7sOdJbJRFNjVgdZM99iSdhB3P6zXS1sDD9weT3lXJBR5Q956ZiY+/TEWY2nQ
         YCAg==
X-Google-Smtp-Source: APXvYqzIHdXQsfrnBx1c44K71SD+IKizHnfv93In7LvP+Dos1vMHhkeSszM33wViMkWYf7DfSWojFQ==
X-Received: by 2002:a63:6ecb:: with SMTP id j194mr14086143pgc.250.1551999639357;
        Thu, 07 Mar 2019 15:00:39 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d18b])
        by smtp.gmail.com with ESMTPSA id i126sm11864806pfb.15.2019.03.07.15.00.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 15:00:38 -0800 (PST)
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
Subject: [PATCH 2/5] mm: prepare to premature release of per-node lruvec_stat_cpu
Date: Thu,  7 Mar 2019 15:00:30 -0800
Message-Id: <20190307230033.31975-3-guro@fb.com>
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

Similar to the memcg's vmstats_percpu, per-memcg per-node stats
consists of percpu- and atomic counterparts, and we do expect
that both coexist during the whole life-cycle of the memcg.

To prepare for a premature release of percpu per-node data,
let's pretend that lruvec_stat_cpu is a rcu-protected pointer,
which can be NULL. This patch adds corresponding checks whenever
required.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 21 +++++++++++++++------
 mm/memcontrol.c            | 11 +++++++++--
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 05ca77767c6a..8ac04632002a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -126,7 +126,7 @@ struct memcg_shrinker_map {
 struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 
-	struct lruvec_stat __percpu *lruvec_stat_cpu;
+	struct lruvec_stat __rcu /* __percpu */ *lruvec_stat_cpu;
 	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
 
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
@@ -682,6 +682,7 @@ static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
 static inline void __mod_lruvec_state(struct lruvec *lruvec,
 				      enum node_stat_item idx, int val)
 {
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct mem_cgroup_per_node *pn;
 	long x;
 
@@ -697,12 +698,20 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
 	__mod_memcg_state(pn->memcg, idx, val);
 
 	/* Update lruvec */
-	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &pn->lruvec_stat[idx]);
-		x = 0;
+	rcu_read_lock();
+	lruvec_stat_cpu = (struct lruvec_stat __percpu *)
+		rcu_dereference(pn->lruvec_stat_cpu);
+	if (likely(lruvec_stat_cpu)) {
+		x = val + __this_cpu_read(lruvec_stat_cpu->count[idx]);
+		if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+			atomic_long_add(x, &pn->lruvec_stat[idx]);
+			x = 0;
+		}
+		__this_cpu_write(lruvec_stat_cpu->count[idx], x);
+	} else {
+		atomic_long_add(val, &pn->lruvec_stat[idx]);
 	}
-	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
+	rcu_read_unlock();
 }
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 803c772f354b..8f3cac02221a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2122,6 +2122,7 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
 	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *memcg;
 
@@ -2152,7 +2153,12 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 				struct mem_cgroup_per_node *pn;
 
 				pn = mem_cgroup_nodeinfo(memcg, nid);
-				x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
+
+				lruvec_stat_cpu = (struct lruvec_stat __percpu*)
+					rcu_dereference(pn->lruvec_stat_cpu);
+				if (!lruvec_stat_cpu)
+					continue;
+				x = this_cpu_xchg(lruvec_stat_cpu->count[i], 0);
 				if (x)
 					atomic_long_add(x, &pn->lruvec_stat[i]);
 			}
@@ -4430,7 +4436,8 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return 1;
 
-	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
+	rcu_assign_pointer(pn->lruvec_stat_cpu,
+			   alloc_percpu(struct lruvec_stat));
 	if (!pn->lruvec_stat_cpu) {
 		kfree(pn);
 		return 1;
-- 
2.20.1

