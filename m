Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2181BC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:18:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30F672070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:18:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="JGwogWPy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30F672070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68CC46B0003; Thu,  5 Sep 2019 18:18:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E256B0005; Thu,  5 Sep 2019 18:18:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 552876B0007; Thu,  5 Sep 2019 18:18:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9A16B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:18:57 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C43C645A0
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:18:56 +0000 (UTC)
X-FDA: 75902283072.10.offer06_883e9df151d30
X-HE-Tag: offer06_883e9df151d30
X-Filterd-Recvd-Size: 6090
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:18:56 +0000 (UTC)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85Lhr2x032677
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=0TGz2gJ0tZNu6OTGW7RsyezpkFK8N/gfzLdnuPDN3vA=;
 b=JGwogWPyFdChIpr5UQoPD8vIQmZBoI9ulUQlI5gsywzal9KVz5XhTkSqS6kzaPVPjRRW
 o8D3ol+fXetjeit793DtVfuF5hZyV1k855W1KCwqKXwC3kgJmevhWZ6U56uLjBs8Sbhy
 ygm182ka0KVvmsbqReBs2pDUGFxYIN2D0HA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2utksg62eu-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:10 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:08 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id AA85717229DFC; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
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
Subject: [PATCH RFC 03/14] mm: vmstat: use s32 for vm_node_stat_diff in struct per_cpu_nodestat
Date: Thu, 5 Sep 2019 14:45:47 -0700
Message-ID: <20190905214553.1643060-4-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
References: <20190905214553.1643060-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_08:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 malwarescore=0
 clxscore=1015 impostorscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 priorityscore=1501 suspectscore=1 phishscore=0
 adultscore=0 bulkscore=0 spamscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1906280000 definitions=main-1909050203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently s8 type is used for per-cpu caching of per-node statistics.
It works fine because the overfill threshold can't exceed 125.

But if some counters are in bytes (and the next commit in the series
will convert slab counters to bytes), it's not gonna work:
value in bytes can easily exceed s8 without exceeding the threshold
converted to bytes. So to avoid overfilling per-cpu caches and breaking
vmstats correctness, let's use s32 instead.

This doesn't affect per-zone statistics. There are no plans to use
zone-level byte-sized counters, so no reasons to change anything.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/mmzone.h |  2 +-
 mm/vmstat.c            | 16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bda20282746b..6e8233d52971 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -353,7 +353,7 @@ struct per_cpu_pageset {
 
 struct per_cpu_nodestat {
 	s8 stat_threshold;
-	s8 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
+	s32 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
 };
 
 #endif /* !__GENERATING_BOUNDS.H */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6afc892a148a..98f43725d910 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -337,7 +337,7 @@ void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
 				long delta)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
-	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	s32 __percpu *p = pcp->vm_node_stat_diff + item;
 	long x;
 	long t;
 
@@ -395,13 +395,13 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
-	s8 __percpu *p = pcp->vm_node_stat_diff + item;
-	s8 v, t;
+	s32 __percpu *p = pcp->vm_node_stat_diff + item;
+	s32 v, t;
 
 	v = __this_cpu_inc_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
 	if (unlikely(v > t)) {
-		s8 overstep = t >> 1;
+		s32 overstep = t >> 1;
 
 		node_page_state_add(v + overstep, pgdat, item);
 		__this_cpu_write(*p, -overstep);
@@ -439,13 +439,13 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
-	s8 __percpu *p = pcp->vm_node_stat_diff + item;
-	s8 v, t;
+	s32 __percpu *p = pcp->vm_node_stat_diff + item;
+	s32 v, t;
 
 	v = __this_cpu_dec_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
 	if (unlikely(v < - t)) {
-		s8 overstep = t >> 1;
+		s32 overstep = t >> 1;
 
 		node_page_state_add(v - overstep, pgdat, item);
 		__this_cpu_write(*p, overstep);
@@ -538,7 +538,7 @@ static inline void mod_node_state(struct pglist_data *pgdat,
        enum node_stat_item item, int delta, int overstep_mode)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
-	s8 __percpu *p = pcp->vm_node_stat_diff + item;
+	s32 __percpu *p = pcp->vm_node_stat_diff + item;
 	long o, n, t, z;
 
 	do {
-- 
2.21.0


