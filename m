Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85039C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A052E206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KVrfu9Ck"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A052E206DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5C946B000A; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82F416B000C; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D70A6B000D; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0206.hostedemail.com [216.40.44.206])
	by kanga.kvack.org (Postfix) with ESMTP id 327BB6B000D
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D34D134A3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:13 +0000 (UTC)
X-FDA: 75902200626.13.sink61_8da50b2fb3022
X-HE-Tag: sink61_8da50b2fb3022
X-Filterd-Recvd-Size: 7603
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:13 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85LjCGc007194
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=SigM+i1toavMqTPh1qC3TfkVYP0HGpMJnAT2A/4oDIs=;
 b=KVrfu9CkBaur46aD/cHEmbEqERZE7J2QdSzmIO8FItCMn8BwDW15rYqMGmTavwiNVxLr
 kYC+h7RYjOn+Gm3A1sZW6SK6chgynstaMGoEAB65qFQw1KR6xpDBXvt+TrLcsVicFAZ9
 EwD2zZC0xee6Wlcs53akE+QJ61E8OtsbwRk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2utkkxwup9-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:12 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:09 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id C4A0717229E08; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Shakeel Butt
	<shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH RFC 09/14] mm: memcg: introduce __mod_lruvec_memcg_state()
Date: Thu, 5 Sep 2019 14:45:53 -0700
Message-ID: <20190905214553.1643060-10-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
References: <20190905214553.1643060-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_08:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 malwarescore=0
 lowpriorityscore=0 spamscore=0 priorityscore=1501 phishscore=0
 mlxlogscore=701 mlxscore=0 clxscore=1015 adultscore=0 suspectscore=3
 impostorscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1906280000 definitions=main-1909050203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To prepare for per-object accounting of slab objects, let's introduce
__mod_lruvec_memcg_state() and mod_lruvec_memcg_state() helpers,
which are similar to mod_lruvec_state(), but do not update global
node counters, only lruvec and per-cgroup.

It's necessary because soon node slab counters will be used for
accounting of all memory used by slab pages, however on memcg level
only the actually used memory will be counted. Free space will be
shared between all cgroups, so it can't be accounted to any.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 22 ++++++++++++++++++++++
 mm/memcontrol.c            | 37 +++++++++++++++++++++++++++----------
 2 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8f1d7161579f..cef8a9c51482 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -739,6 +739,8 @@ static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
 
 void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 			int val);
+void __mod_lruvec_memcg_state(struct lruvec *lruvec, enum node_stat_item idx,
+			      int val);
 void __mod_lruvec_slab_state(void *p, enum node_stat_item idx, int val);
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
@@ -751,6 +753,16 @@ static inline void mod_lruvec_state(struct lruvec *lruvec,
 	local_irq_restore(flags);
 }
 
+static inline void mod_lruvec_memcg_state(struct lruvec *lruvec,
+					  enum node_stat_item idx, int val)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_lruvec_memcg_state(lruvec, idx, val);
+	local_irq_restore(flags);
+}
+
 static inline void __mod_lruvec_page_state(struct page *page,
 					   enum node_stat_item idx, int val)
 {
@@ -1143,6 +1155,16 @@ static inline void mod_lruvec_state(struct lruvec *lruvec,
 	mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
 }
 
+static inline void __mod_lruvec_memcg_state(struct lruvec *lruvec,
+					    enum node_stat_item idx, int val)
+{
+}
+
+static inline void mod_lruvec_memcg_state(struct lruvec *lruvec,
+					  enum node_stat_item idx, int val)
+{
+}
+
 static inline void __mod_lruvec_page_state(struct page *page,
 					   enum node_stat_item idx, int val)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d57f95177aec..89a892ef7699 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -795,16 +795,16 @@ parent_nodeinfo(struct mem_cgroup_per_node *pn, int nid)
 }
 
 /**
- * __mod_lruvec_state - update lruvec memory statistics
+ * __mod_lruvec_memcg_state - update lruvec memory statistics
  * @lruvec: the lruvec
  * @idx: the stat item
  * @val: delta to add to the counter, can be negative
  *
  * The lruvec is the intersection of the NUMA node and a cgroup. This
- * function updates the all three counters that are affected by a
- * change of state at this level: per-node, per-cgroup, per-lruvec.
+ * function updates the two of three counters that are affected by a
+ * change of state at this level: per-cgroup and per-lruvec.
  */
-void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
+void __mod_lruvec_memcg_state(struct lruvec *lruvec, enum node_stat_item idx,
 			int val)
 {
 	pg_data_t *pgdat = lruvec_pgdat(lruvec);
@@ -812,12 +812,6 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	struct mem_cgroup *memcg;
 	long x, threshold = MEMCG_CHARGE_BATCH;
 
-	/* Update node */
-	__mod_node_page_state(pgdat, idx, val);
-
-	if (mem_cgroup_disabled())
-		return;
-
 	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
 	memcg = pn->memcg;
 
@@ -841,6 +835,29 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
 }
 
+/**
+ * __mod_lruvec_state - update lruvec memory statistics
+ * @lruvec: the lruvec
+ * @idx: the stat item
+ * @val: delta to add to the counter, can be negative
+ *
+ * The lruvec is the intersection of the NUMA node and a cgroup. This
+ * function updates the all three counters that are affected by a
+ * change of state at this level: per-node, per-cgroup, per-lruvec.
+ */
+void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
+			int val)
+{
+	pg_data_t *pgdat = lruvec_pgdat(lruvec);
+
+	/* Update node */
+	__mod_node_page_state(pgdat, idx, val);
+
+	/* Update per-cgroup and per-lruvec stats */
+	if (!mem_cgroup_disabled())
+		__mod_lruvec_memcg_state(lruvec, idx, val);
+}
+
 void __mod_lruvec_slab_state(void *p, enum node_stat_item idx, int val)
 {
 	struct page *page = virt_to_head_page(p);
-- 
2.21.0


