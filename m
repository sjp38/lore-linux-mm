Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E932BC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AE942077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LXstkKlU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AE942077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 545A68E0007; Tue, 12 Mar 2019 18:34:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CC4D8E0002; Tue, 12 Mar 2019 18:34:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3491D8E0007; Tue, 12 Mar 2019 18:34:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD7FB8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d5so4712331pfo.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oz/TqQdvSWg5Jr50nmxxA8VLsKG86DG+TYlsVRNN9G4=;
        b=MSP8bjw9NJS60OA/OWQjFoIzCPeQR6xJad9pTRpmmlB76at90onUSayfJb9xJNRM92
         H1BeLcEYfwqtsP4UfXDMorK28V8CnwxCClgH3pnkwSmZ9zhYWWq6A27oOFAEFtxm20pv
         KzqjT2QalS6Aa5c2ef0N+vagjc3mVrhPsPDDa+WZBIYPKb5HunYJL4+U9rj39JNvyAby
         uR0hweunGMJ4yhJZia4pG7CRuVw7caD9u8avO1s5zM5pZUyxepC7/kSUGQliRiDgXOAY
         ennP2/L2grBFxRLc8n/5j2lAGWWP7flGWUZLGpQDq3YxA33+JMBLqStrM0t42O/v+JFx
         elmA==
X-Gm-Message-State: APjAAAWF9vXCm20/yRhIJv40lS+pHX/BZzSIsw3Q26CHjStRhaUdMf/D
	eAPe7zIwKwSrfkE139ImXlzcY416bHj2c/H+XtLBgaqmxZSswi0Nd2hgQQCDnqvpQKC34bgGVRE
	OBYFTprmwYI6E6RqthpBSoyYhmpAmHSHNsu/IBAdOBao6yvu9fpidg7M8mldGeI9PqLYTJDFr9e
	t5FevklZTrm49yakSnCf8dB30nGJVty8TjivBj6xNtAHQoMC+Z1n4TEWWwuwwBSOJ0IxaY74OuE
	+j2jolGzlKJZVaeZD1Z4D+Um/Dx2S0qWS8QB7YoLMa8oBXmAf8Q+idwnfmkcSrPX0hNP1i+Wm+j
	5D51Z7QQ4VgXTfb59Ic9pgbesieoWpbys8xd2vL7wWm6bXOoMTQe0t5ewuhtagJyc6rI/KFvQBd
	Y
X-Received: by 2002:a65:4542:: with SMTP id x2mr22231750pgr.65.1552430052574;
        Tue, 12 Mar 2019 15:34:12 -0700 (PDT)
X-Received: by 2002:a65:4542:: with SMTP id x2mr22231663pgr.65.1552430051044;
        Tue, 12 Mar 2019 15:34:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430051; cv=none;
        d=google.com; s=arc-20160816;
        b=DcU9bbcgT8LAY5JLtvkZ1oBqzwYbkYMn9Yw3CLXaKai2qzdYbLaisJhWXDNOB51xbN
         3FQo28GczOIH5jLhwh2dJzA1YqQpHzuys44kNfkOreMMJVMa00Ti9toPplrAD6Nt4YEF
         ZbgzRu3WCYf6sEYmSnZWc8eNnroz4KGvItAqeOnc6kMUeJhF0kEpxhi4Qoer643LlTDF
         8O9dvR1jghLlphnrvKRhcSt5pbpbaL1Y/IyE75NyjlwBbhcHgdFvsRmWgjw9MjeyKMp8
         2/pil9QgWXFZnXridbpb0R5Jm0i/aAnS81owDohk5Pq0F1GP+W2vNAkSPsr/NzhjLkMu
         yz2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oz/TqQdvSWg5Jr50nmxxA8VLsKG86DG+TYlsVRNN9G4=;
        b=KViXYDbj3qDRIKvMn0/HPI1z0kV8nBnwP5AiWXwriPDl2bM+2DE9Q/8gx4Q1m8x1CT
         r+wUVtocLSQzZS/LsP+vvPfsKK3HcaG4tnbBk4PEV7y3rFyCvg/FuVJ61TvEAy7zbc7q
         EXx6JvzoStZ6flLQxSKRjW954ayPDeTilanAJgWUuhzesrVCcBp6z/6YK8KEtg7BIdJx
         n2PoHewpK3pNbnD+BpKiMSjtNdwpZ4UDLX4lD4geO7fok1B2CRliFI08i/QqK4I+/QwJ
         kqTWtfT1rt6CK+Ob2VxMSwfHRLFCUdQWO+/Y2Rl+E8CbRQwImnQsfpCBib9GsncoWY9l
         k30w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LXstkKlU;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor15900074pgh.60.2019.03.12.15.34.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LXstkKlU;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=oz/TqQdvSWg5Jr50nmxxA8VLsKG86DG+TYlsVRNN9G4=;
        b=LXstkKlUo0CnIa3Kc9zF+D4gAlOlVCACVZQL55UAPdMLJPpES1HylsZEk9D3A62uSi
         fdBXQCsgnT34wO+Y3YeEVDZDz8SkhJqKZzNp1SLlupnP8AMhk6eQJq0gJEcndGpfsCyy
         gICdN5uWruLEXqIic9Da9FeFoaleFCceVwVaTlcBB5XxD0QQ9PtvlAWeqrQSIQVAEdW8
         NwRAy+W1N0D9imr2hWnXWox7pYqy0heUoeImh6pY8pQi5y3XmlcbCifj9BumcodY0pl9
         dhp6sT026DZ5kN93hNlwp4Tt1mOJtPMBEgrfBmcNZ3FLzMxDcbFGfjwXQtA/lQ6FqUiF
         1WCw==
X-Google-Smtp-Source: APXvYqxaTl30AAKSU0hP96o65+VdoqQtZLA+IvuzkQRRVNKj8cm5sDUVP3whhZO805D+hSJdmfCc0A==
X-Received: by 2002:a63:3541:: with SMTP id c62mr36759041pga.157.1552430050528;
        Tue, 12 Mar 2019 15:34:10 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:09 -0700 (PDT)
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
Subject: [PATCH v2 2/6] mm: prepare to premature release of per-node lruvec_stat_cpu
Date: Tue, 12 Mar 2019 15:33:59 -0700
Message-Id: <20190312223404.28665-3-guro@fb.com>
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

Similar to the memcg's vmstats_percpu, per-memcg per-node stats
consists of percpu- and atomic counterparts, and we do expect
that both coexist during the whole life-cycle of the memcg.

To prepare for a premature release of percpu per-node data,
let's pretend that lruvec_stat_cpu is a rcu-protected pointer,
which can be NULL. This patch adds corresponding checks whenever
required.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 21 +++++++++++++++------
 mm/memcontrol.c            | 14 +++++++++++---
 2 files changed, 26 insertions(+), 9 deletions(-)

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
index 803c772f354b..5ef4098f3f8d 100644
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
@@ -4414,6 +4420,7 @@ struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 
 static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 {
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	struct mem_cgroup_per_node *pn;
 	int tmp = node;
 	/*
@@ -4430,11 +4437,12 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return 1;
 
-	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
-	if (!pn->lruvec_stat_cpu) {
+	lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
+	if (!lruvec_stat_cpu) {
 		kfree(pn);
 		return 1;
 	}
+	rcu_assign_pointer(pn->lruvec_stat_cpu, lruvec_stat_cpu);
 
 	lruvec_init(&pn->lruvec);
 	pn->usage_in_excess = 0;
-- 
2.20.1

