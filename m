Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D720C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23EDF20828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Wtjh7Yvp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23EDF20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9D196B0007; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4DBA6B0008; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 914F46B000A; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0187.hostedemail.com [216.40.44.187])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9966B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:46:13 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AC7314835
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:12 +0000 (UTC)
X-FDA: 75902200584.17.ear18_8d73c17e54a13
X-HE-Tag: ear18_8d73c17e54a13
X-Filterd-Recvd-Size: 4927
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:11 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85LjAkP007158
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=rZedqTwzLOw9+QlYlJrNiqvvmmCUA+1LduWzC6DbQlU=;
 b=Wtjh7YvprPq/wx77nE+Im9sKl64kliQH1v9NIYFx/meAYcS+D9g83JFWQyDteeH9rgWO
 7Pfp/4k9C4tq69SqkYxQK/afcOh4mGNO2E8iC65qXzeloau5DQH36TnkhmKKnlFXWQjl
 SXWMVIwbpLb54fNCQVzW3FjP4E9BR4Ns2TQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2utkkxwup2-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:11 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:08 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id B7F3917229E02; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
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
Subject: [PATCH RFC 06/14] mm: slub: implement SLUB version of obj_to_index()
Date: Thu, 5 Sep 2019 14:45:50 -0700
Message-ID: <20190905214553.1643060-7-guro@fb.com>
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
 mlxlogscore=840 mlxscore=0 clxscore=1015 adultscore=0 suspectscore=3
 impostorscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1906280000 definitions=main-1909050203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit implements SLUB version of the obj_to_index() function,
which will be required to calculate the offset of memcg_ptr in the
mem_cgroup_vec to store/obtain the memcg ownership data.

To make it faster, let's repeat the SLAB's trick introduced by
commit 6a2d7a955d8d ("[PATCH] SLAB: use a multiply instead of a
divide in obj_to_index()") and avoid an expensive division.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slub_def.h | 9 +++++++++
 mm/slub.c                | 1 +
 2 files changed, 10 insertions(+)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d2153789bd9f..200ea292f250 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -8,6 +8,7 @@
  * (C) 2007 SGI, Christoph Lameter
  */
 #include <linux/kobject.h>
+#include <linux/reciprocal_div.h>
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
@@ -86,6 +87,7 @@ struct kmem_cache {
 	unsigned long min_partial;
 	unsigned int size;	/* The size of an object including metadata */
 	unsigned int object_size;/* The size of an object without metadata */
+	struct reciprocal_value reciprocal_size;
 	unsigned int offset;	/* Free pointer offset */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
 	/* Number of per cpu partial objects to keep around */
@@ -182,4 +184,11 @@ static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
 	return result;
 }
 
+static inline unsigned int obj_to_index(const struct kmem_cache *cache,
+					const struct page *page, void *obj)
+{
+	return reciprocal_divide(kasan_reset_tag(obj) - page_address(page),
+				 cache->reciprocal_size);
+}
+
 #endif /* _LINUX_SLUB_DEF_H */
diff --git a/mm/slub.c b/mm/slub.c
index 3014158c100d..b043cfb673c9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3587,6 +3587,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 */
 	size = ALIGN(size, s->align);
 	s->size = size;
+	s->reciprocal_size = reciprocal_value(size);
 	if (forced_order >= 0)
 		order = forced_order;
 	else
-- 
2.21.0


