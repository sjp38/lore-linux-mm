Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72079C3A5A1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:01:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B16F20644
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:01:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="iQjs/UUW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B16F20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E386B0008; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC1336B000A; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD66E6B000C; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2626B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4EA68180AD7C1
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:01:01 +0000 (UTC)
X-FDA: 75840699522.18.soap59_6028a1a243936
X-HE-Tag: soap59_6028a1a243936
X-Filterd-Recvd-Size: 7582
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:01:00 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7JMxZmw008747
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:00:59 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=sWhCn1MkVcyl0S66olKX6n9IQ1ill6txaHPzEEn2R9g=;
 b=iQjs/UUW817RLEG3p5C5S6ewog0BovMHswyfRS4UkOwq7s+yg1+tvtFAvzqDT1P5e3Ex
 8HqHAVdi+4NeFEJcyS9R3GGVR/PQfoP1/aoUREygEfbBKi6da6clwepqHbjT0HtZEiBV
 7OAs4sQ+Pf+rQ3XUpJr7V+hWwn7LldVja4A= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ug1vv8veh-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:00:59 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 19 Aug 2019 16:00:57 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 7839E168C488F; Mon, 19 Aug 2019 16:00:56 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 3/3] mm: memcontrol: flush percpu slab vmstats on kmem offlining
Date: Mon, 19 Aug 2019 16:00:54 -0700
Message-ID: <20190819230054.779745-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190819230054.779745-1-guro@fb.com>
References: <20190819230054.779745-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=607 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190227
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've noticed that the "slab" value in memory.stat is sometimes 0,
even if some children memory cgroups have a non-zero "slab" value.
The following investigation showed that this is the result
of the kmem_cache reparenting in combination with the per-cpu
batching of slab vmstats.

At the offlining some vmstat value may leave in the percpu cache,
not being propagated upwards by the cgroup hierarchy. It means
that stats on ancestor levels are lower than actual. Later when
slab pages are released, the precise number of pages is substracted
on the parent level, making the value negative. We don't show negative
values, 0 is printed instead.

To fix this issue, let's flush percpu slab memcg and lruvec stats
on memcg offlining. This guarantees that numbers on all ancestor
levels are accurate and match the actual number of outstanding
slab pages.

Fixes: fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches on cgroup removal")
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 include/linux/mmzone.h |  5 +++--
 mm/memcontrol.c        | 35 +++++++++++++++++++++++++++--------
 2 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8b5f758942a2..bda20282746b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -215,8 +215,9 @@ enum node_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
-	NR_SLAB_RECLAIMABLE,
-	NR_SLAB_UNRECLAIMABLE,
+	NR_SLAB_RECLAIMABLE,	/* Please do not reorder this item */
+	NR_SLAB_UNRECLAIMABLE,	/* and this one without looking at
+				 * memcg_flush_percpu_vmstats() first. */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	WORKINGSET_NODES,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f98c5293adae..3137de6a46f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3383,37 +3383,49 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	}
 }
 
-static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
+static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg, bool slab_only)
 {
 	unsigned long stat[MEMCG_NR_STAT];
 	struct mem_cgroup *mi;
 	int node, cpu, i;
+	int min_idx, max_idx;
 
-	for (i = 0; i < MEMCG_NR_STAT; i++)
+	if (slab_only) {
+		min_idx = NR_SLAB_RECLAIMABLE;
+		max_idx = NR_SLAB_UNRECLAIMABLE;
+	} else {
+		min_idx = 0;
+		max_idx = MEMCG_NR_STAT;
+	}
+
+	for (i = min_idx; i < max_idx; i++)
 		stat[i] = 0;
 
 	for_each_online_cpu(cpu)
-		for (i = 0; i < MEMCG_NR_STAT; i++)
+		for (i = min_idx; i < max_idx; i++)
 			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
 
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-		for (i = 0; i < MEMCG_NR_STAT; i++)
+		for (i = min_idx; i < max_idx; i++)
 			atomic_long_add(stat[i], &mi->vmstats[i]);
 
+	if (!slab_only)
+		max_idx = NR_VM_NODE_STAT_ITEMS;
+
 	for_each_node(node) {
 		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 		struct mem_cgroup_per_node *pi;
 
-		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		for (i = min_idx; i < max_idx; i++)
 			stat[i] = 0;
 
 		for_each_online_cpu(cpu)
-			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			for (i = min_idx; i < max_idx; i++)
 				stat[i] += raw_cpu_read(
 					pn->lruvec_stat_cpu->count[i]);
 
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
-			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			for (i = min_idx; i < max_idx; i++)
 				atomic_long_add(stat[i], &pi->lruvec_stat[i]);
 	}
 }
@@ -3486,7 +3498,14 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	if (!parent)
 		parent = root_mem_cgroup;
 
+	/*
+	 * Deactivate and reparent kmem_caches. Then flush percpu
+	 * slab statistics to have precise values at the parent and
+	 * all ancestor levels. It's required to keep slab stats
+	 * accurate after the reparenting of kmem_caches.
+	 */
 	memcg_deactivate_kmem_caches(memcg, parent);
+	memcg_flush_percpu_vmstats(memcg, true);
 
 	kmemcg_id = memcg->kmemcg_id;
 	BUG_ON(kmemcg_id < 0);
@@ -4863,7 +4882,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	 * Flush percpu vmstats and vmevents to guarantee the value correctness
 	 * on parent's and all ancestor levels.
 	 */
-	memcg_flush_percpu_vmstats(memcg);
+	memcg_flush_percpu_vmstats(memcg, false);
 	memcg_flush_percpu_vmevents(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
-- 
2.21.0


