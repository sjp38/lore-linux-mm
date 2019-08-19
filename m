Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F5FFC3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 20:23:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D233C22DA8
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 20:23:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ZIjvcGI9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D233C22DA8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E7656B0008; Mon, 19 Aug 2019 16:23:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6713B6B000A; Mon, 19 Aug 2019 16:23:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586BA6B000C; Mon, 19 Aug 2019 16:23:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 334346B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:23:55 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D60A68248AAB
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 20:23:54 +0000 (UTC)
X-FDA: 75840303588.27.tax51_221a9b383b55e
X-HE-Tag: tax51_221a9b383b55e
X-Filterd-Recvd-Size: 6217
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 20:23:54 +0000 (UTC)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7JKMpSj006668
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:23:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=avRSMxYHWI2nN6k5SuD3FwUt2pWdBC75ub4aAGj+xPU=;
 b=ZIjvcGI9ALY3ecLqF/IAy1qeg6VFEZGQ9SeNWQTaJJ5Rhfe/+JaSdHHqy3PcGQ83RDnt
 rXyi/huUj7hpvtGM5OptEeNwleoTZZdYRsLXcY/YbemcAAsFJd4+GqxlswibBNi+6jEJ
 ECND7ggLO/w/O5t7qxkRxNhKVNqbn1a5BlA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2ufx6jhbrv-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:23:53 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 19 Aug 2019 13:23:47 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 477DE168A8ACF; Mon, 19 Aug 2019 13:23:47 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>, <stable@vger.kernel.org>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v2 1/3] mm: memcontrol: flush percpu vmstats before releasing memcg
Date: Mon, 19 Aug 2019 13:23:36 -0700
Message-ID: <20190819202338.363363-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190819202338.363363-1-guro@fb.com>
References: <20190819202338.363363-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190207
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Percpu caching of local vmstats with the conditional propagation by the
cgroup tree leads to an accumulation of errors on non-leaf levels.

Let's imagine two nested memory cgroups A and A/B.  Say, a process
belonging to A/B allocates 100 pagecache pages on the CPU 0.  The percpu
cache will spill 3 times, so that 32*3=96 pages will be accounted to A/B
and A atomic vmstat counters, 4 pages will remain in the percpu cache.

Imagine A/B is nearby memory.max, so that every following allocation
triggers a direct reclaim on the local CPU.  Say, each such attempt will
free 16 pages on a new cpu.  That means every percpu cache will have -16
pages, except the first one, which will have 4 - 16 = -12.  A/B and A
atomic counters will not be touched at all.

Now a user removes A/B.  All percpu caches are freed and corresponding
vmstat numbers are forgotten.  A has 96 pages more than expected.

As memory cgroups are created and destroyed, errors do accumulate.  Even
1-2 pages differences can accumulate into large numbers.

To fix this issue let's accumulate and propagate percpu vmstat values
before releasing the memory cgroup.  At this point these numbers are
stable and cannot be changed.

Since on cpu hotplug we do flush percpu vmstats anyway, we can iterate
only over online cpus.

Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <stable@vger.kernel.org>
---
 mm/memcontrol.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e821f34399f..818165d8de3f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3383,6 +3383,41 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	}
 }
 
+static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
+{
+	unsigned long stat[MEMCG_NR_STAT];
+	struct mem_cgroup *mi;
+	int node, cpu, i;
+
+	for (i = 0; i < MEMCG_NR_STAT; i++)
+		stat[i] = 0;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < MEMCG_NR_STAT; i++)
+			stat[i] += raw_cpu_read(memcg->vmstats_percpu->stat[i]);
+
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
+		for (i = 0; i < MEMCG_NR_STAT; i++)
+			atomic_long_add(stat[i], &mi->vmstats[i]);
+
+	for_each_node(node) {
+		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
+		struct mem_cgroup_per_node *pi;
+
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+			stat[i] = 0;
+
+		for_each_online_cpu(cpu)
+			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+				stat[i] += raw_cpu_read(
+					pn->lruvec_stat_cpu->count[i]);
+
+		for (pi = pn; pi; pi = parent_nodeinfo(pi, node))
+			for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+				atomic_long_add(stat[i], &pi->lruvec_stat[i]);
+	}
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
@@ -4805,6 +4840,11 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
+	/*
+	 * Flush percpu vmstats to guarantee the value correctness
+	 * on parent's and all ancestor levels.
+	 */
+	memcg_flush_percpu_vmstats(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
-- 
2.21.0


