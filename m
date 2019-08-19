Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FA15C3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:01:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDB1220644
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:01:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="H7n3kRBX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDB1220644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 510876B000A; Mon, 19 Aug 2019 19:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C1CB6B000C; Mon, 19 Aug 2019 19:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AF406B000D; Mon, 19 Aug 2019 19:01:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id 089156B000C
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AD7526D6E
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:01:01 +0000 (UTC)
X-FDA: 75840699522.12.night60_603d0cbdac52a
X-HE-Tag: night60_603d0cbdac52a
X-Filterd-Recvd-Size: 5113
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:01:01 +0000 (UTC)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7JMoerr022702
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:01:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=ZHv3eexuYIoTswObGTlp7kl6b7HNonAZ8mYXd0OMTBw=;
 b=H7n3kRBXXdFFzG9E0DqCmePf0jbOgbQ0ygU3ssGxZa3dxj0XdIelX+Nfzhj8+T49D93M
 8E9m0FcH0WtNp8WKyQ7Nj5xveCd2gLNV8clOR9jQJG39i59MUKKKnupSq98zHCWtjWh7
 r/RaEG2OSDSAuzrF0Iboz+WQbGuzkuB9baM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2ug2v3gj7t-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:01:00 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 19 Aug 2019 16:00:58 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 729E6168C488D; Mon, 19 Aug 2019 16:00:56 -0700 (PDT)
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
Subject: [PATCH v3 2/3] mm: memcontrol: flush percpu vmevents before releasing memcg
Date: Mon, 19 Aug 2019 16:00:53 -0700
Message-ID: <20190819230054.779745-3-guro@fb.com>
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
 mlxlogscore=828 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190226
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to vmstats, percpu caching of local vmevents leads to an
accumulation of errors on non-leaf levels.  This happens because some
leftovers may remain in percpu caches, so that they are never propagated
up by the cgroup tree and just disappear into nonexistence with on
releasing of the memory cgroup.

To fix this issue let's accumulate and propagate percpu vmevents values
before releasing the memory cgroup similar to what we're doing with
vmstats.

Since on cpu hotplug we do flush percpu vmstats anyway, we can iterate
only over online cpus.

Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: <stable@vger.kernel.org>
---
 mm/memcontrol.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 818165d8de3f..f98c5293adae 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3418,6 +3418,25 @@ static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
 	}
 }
 
+static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
+{
+	unsigned long events[NR_VM_EVENT_ITEMS];
+	struct mem_cgroup *mi;
+	int cpu, i;
+
+	for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+		events[i] = 0;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+			events[i] += raw_cpu_read(
+				memcg->vmstats_percpu->events[i]);
+
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
+		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
+			atomic_long_add(events[i], &mi->vmevents[i]);
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
@@ -4841,10 +4860,11 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	int node;
 
 	/*
-	 * Flush percpu vmstats to guarantee the value correctness
+	 * Flush percpu vmstats and vmevents to guarantee the value correctness
 	 * on parent's and all ancestor levels.
 	 */
 	memcg_flush_percpu_vmstats(memcg);
+	memcg_flush_percpu_vmevents(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
-- 
2.21.0


