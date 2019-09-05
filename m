Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF2EC43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A93C206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:46:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="WqjKf11s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A93C206DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F5566B000C; Thu,  5 Sep 2019 17:46:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A56C6B000D; Thu,  5 Sep 2019 17:46:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56BF26B000E; Thu,  5 Sep 2019 17:46:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 3657F6B000C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:46:15 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DA50C824CA36
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:14 +0000 (UTC)
X-FDA: 75902200668.17.base94_8dc9709d2af18
X-HE-Tag: base94_8dc9709d2af18
X-Filterd-Recvd-Size: 6964
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:46:14 +0000 (UTC)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85LjfHO025642
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:13 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=UwPjL9OaS6l+zw5+AffGQKehTN9tHhdRtYm7b2UrvFk=;
 b=WqjKf11sa3e1l8/TmjXpBgZNL7N1F+aC2Zd32rcPerdm+34rvdxiq45xBiZJV88F5cnD
 C7gK69ICIObQDdJ3mLVEBzmKblwoxcjl85brhwtnUMVpRE6k45YJG5qphEdVqkFbS78T
 9lhlExt+asGT6SDMJM61c/wNGask0dLNmRE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uu8mdrhe7-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:13 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:09 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id B3CAA17229E00; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
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
Subject: [PATCH RFC 05/14] mm: memcg/slab: allocate space for memcg ownership data for non-root slabs
Date: Thu, 5 Sep 2019 14:45:49 -0700
Message-ID: <20190905214553.1643060-6-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
References: <20190905214553.1643060-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_08:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 adultscore=0 spamscore=0
 suspectscore=3 priorityscore=1501 impostorscore=0 bulkscore=0
 mlxlogscore=749 clxscore=1015 mlxscore=0 lowpriorityscore=0 phishscore=0
 malwarescore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1906280000 definitions=main-1909050203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allocate and release memory for storing the memcg ownership data.
For each slab page allocate space sufficient for number_of_objects
pointers to struct mem_cgroup_vec.

The mem_cgroup field of the struct page isn't used for slab pages,
so let's use the space for storing the pointer for the allocated
space.

This commit makes sure that the space is ready for use, but nobody
is actually using it yet. Following commits in the series will fix it.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/mm_types.h |  5 ++++-
 mm/slab.c                |  3 ++-
 mm/slab.h                | 37 ++++++++++++++++++++++++++++++++++++-
 mm/slub.c                |  2 +-
 4 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 25395481d2ae..510cb170c4b8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -199,7 +199,10 @@ struct page {
 	atomic_t _refcount;
 
 #ifdef CONFIG_MEMCG
-	struct mem_cgroup *mem_cgroup;
+	union {
+		struct mem_cgroup *mem_cgroup;
+		struct mem_cgroup_ptr **mem_cgroup_vec;
+	};
 #endif
 
 	/*
diff --git a/mm/slab.c b/mm/slab.c
index 9df370558e5d..f0833f287dcf 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1369,7 +1369,8 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 		return NULL;
 	}
 
-	if (charge_slab_page(page, flags, cachep->gfporder, cachep)) {
+	if (charge_slab_page(page, flags, cachep->gfporder, cachep,
+			     cachep->num)) {
 		__free_pages(page, cachep->gfporder);
 		return NULL;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 7c5577c2b9ea..16d7ea30a2d3 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -406,6 +406,23 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 	percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
 }
 
+static inline int memcg_alloc_page_memcg_vec(struct page *page, gfp_t gfp,
+					     unsigned int objects)
+{
+	page->mem_cgroup_vec = kmalloc(sizeof(struct mem_cgroup_ptr *) *
+				       objects, gfp | __GFP_ZERO);
+	if (!page->mem_cgroup_vec)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static inline void memcg_free_page_memcg_vec(struct page *page)
+{
+	kfree(page->mem_cgroup_vec);
+	page->mem_cgroup_vec = NULL;
+}
+
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 
@@ -455,6 +472,16 @@ static inline void memcg_uncharge_slab(struct page *page, int order,
 {
 }
 
+static inline int memcg_alloc_page_memcg_vec(struct page *page, gfp_t gfp,
+					     unsigned int objects)
+{
+	return 0;
+}
+
+static inline void memcg_free_page_memcg_vec(struct page *page)
+{
+}
+
 static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
@@ -479,14 +506,21 @@ static inline struct kmem_cache *virt_to_cache(const void *obj)
 
 static __always_inline int charge_slab_page(struct page *page,
 					    gfp_t gfp, int order,
-					    struct kmem_cache *s)
+					    struct kmem_cache *s,
+					    unsigned int objects)
 {
+	int ret;
+
 	if (is_root_cache(s)) {
 		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
 				    PAGE_SIZE << order);
 		return 0;
 	}
 
+	ret = memcg_alloc_page_memcg_vec(page, gfp, objects);
+	if (ret)
+		return ret;
+
 	return memcg_charge_slab(page, gfp, order, s);
 }
 
@@ -499,6 +533,7 @@ static __always_inline void uncharge_slab_page(struct page *page, int order,
 		return;
 	}
 
+	memcg_free_page_memcg_vec(page);
 	memcg_uncharge_slab(page, order, s);
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 0873b77727bf..3014158c100d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1517,7 +1517,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = __alloc_pages_node(node, flags, order);
 
-	if (page && charge_slab_page(page, flags, order, s)) {
+	if (page && charge_slab_page(page, flags, order, s, oo_objects(oo))) {
 		__free_pages(page, order);
 		page = NULL;
 	}
-- 
2.21.0


