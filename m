Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7083C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1FF8206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SLK8TMs9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1FF8206DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8306C6B0010; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719326B000A; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3B36B000E; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 304D06B000C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:46:14 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D1B41180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:13 +0000 (UTC)
X-FDA: 75902200626.19.top49_8da5645d5370c
X-HE-Tag: top49_8da5645d5370c
X-Filterd-Recvd-Size: 4434
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:13 +0000 (UTC)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85LgktN016046
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=a0xRfNvZ6A20DAq+kUq8yz7y4FX28qaCwqEaBNzxJZ8=;
 b=SLK8TMs9JaS/3zhY99IsTN2IIENV2AQXlVDY2z+/yhYKIx4OgbHAEfEqr1uYpigRgLtK
 GoEbj8M1xVgaVndUUvNS14FrWlYrsNEGkWu73HdOODA5zHqN7eSVKBYI9DgkUn9f8bjx
 WqqT6qiWf/web1F2ts101CGDda/ox/gb1t0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uu93b0drb-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:12 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:08 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id C0C5817229E06; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
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
Subject: [PATCH RFC 08/14] mm: memcg: move memcg_kmem_bypass() to memcontrol.h
Date: Thu, 5 Sep 2019 14:45:52 -0700
Message-ID: <20190905214553.1643060-9-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
References: <20190905214553.1643060-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_08:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 spamscore=0 clxscore=1015 lowpriorityscore=0 suspectscore=1
 impostorscore=0 adultscore=0 bulkscore=0 phishscore=0 malwarescore=0
 mlxscore=0 mlxlogscore=982 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1906280000 definitions=main-1909050202
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To make the memcg_kmem_bypass() function available outside of
the memcontrol.c, let's move it to memcontrol.h. The function
is small and nicely fits into static inline sort of functions.

It will be used from the slab code.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 7 +++++++
 mm/memcontrol.c            | 7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b9643d758fc9..8f1d7161579f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1430,6 +1430,13 @@ static inline bool memcg_kmem_enabled(void)
 	return static_branch_unlikely(&memcg_kmem_enabled_key);
 }
 
+static inline bool memcg_kmem_bypass(void)
+{
+	if (in_interrupt() || !current->mm || (current->flags & PF_KTHREAD))
+		return true;
+	return false;
+}
+
 static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 {
 	if (memcg_kmem_enabled())
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 761b646eb968..d57f95177aec 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2992,13 +2992,6 @@ static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 	queue_work(memcg_kmem_cache_wq, &cw->work);
 }
 
-static inline bool memcg_kmem_bypass(void)
-{
-	if (in_interrupt() || !current->mm || (current->flags & PF_KTHREAD))
-		return true;
-	return false;
-}
-
 /**
  * memcg_kmem_get_cache: select the correct per-memcg cache for allocation
  * @cachep: the original global kmem cache
-- 
2.21.0


