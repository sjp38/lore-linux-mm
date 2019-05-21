Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B54BC18E7C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:29:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12BEA2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:29:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="eQahIBYt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12BEA2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F39F06B0006; Tue, 21 May 2019 16:29:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB7E46B000A; Tue, 21 May 2019 16:29:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA62F6B0007; Tue, 21 May 2019 16:29:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66EB36B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:29:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c7so66498pfp.14
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=KM/nHlU4zhsLfG8c0YB8Ffe5Um+2X27Yn+rA2wKE+IE=;
        b=E7Xp8NmzywqMAJWlNX1qcEG13ymmuvI5EWHbrFIlCMABacIEkoFhCRc91lPzCJXUiX
         KeQv+iEChTjhYcpmJUxS2PycDPXL5fGblqW5F36dtsgoRlxyPYDnoR4HJdNHSkVOypXS
         kkUG9J1lVeyH7kVyGhe7OA103XGgYcAdiz5uj0nJH+vPGofyodERfQ3A24JpbC5gvbUr
         rHVokYvhJ702FZNfc6ndrCSighZrwgKmZZT0HRPnfd1XThVmoBZkvZIhaLj5ViIfzQIQ
         zQwytpuz2Y0p5Xr+3Gz+4XNz1QBHVHju6+at5DTblbsVWqWnwCKNHhv0Lbwy/M6H3mkf
         f7dg==
X-Gm-Message-State: APjAAAX0RggjoTVrnJKWr8FVH6dLluNzv/N9qioC4BP29K/qvy1/IXd8
	WoC/SlWGU21qgD39D3xPv5j6cqEauu/5lrlT+n8kzS8H4NBnyKtqXvBmfORihcI8UJAJV+VDhGe
	fFoJraZW7xP6yPntDpjNjx608Sev95IXKvP74xnNLHJBBZd4VYbsp9zAtcMX477HGJQ==
X-Received: by 2002:a65:41c6:: with SMTP id b6mr20385715pgq.399.1558470545016;
        Tue, 21 May 2019 13:29:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFKL5cfOe8p+Zv5XPcUEy+F3uD3LsgPw2f0BMvcC5Eg5Foe5S9IOutYzDiygBTzZB9LQ8Z
X-Received: by 2002:a65:41c6:: with SMTP id b6mr20385596pgq.399.1558470543841;
        Tue, 21 May 2019 13:29:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558470543; cv=none;
        d=google.com; s=arc-20160816;
        b=Gg8fN8SYeZ4K5OC0x5dH6da/UE8hBqusQpAT5uuflJ+DzXii1AVu3mmgAaMEdb9zPm
         vUQbK03lNEqFAkuncObi6IYeoGe7DKXVI+N7v/K44TW4XkyPwrGEmATANw6W7XMIielm
         JjQjj7uSZ6vIBNoJmPFcAs+lVCnnrHOQYbqvA9PkPL3fxpVAPSU3iv9Dwgplc6NbGiDz
         +XmWFnzCLB/7NKo/KVpmkmlOj/w6mKMAqqiCJxpY0facpLvI/9/qLiVFAiZa5+m5vbhr
         xM5k7nOgI0pJprgTOL33t6IyqGL5CO1pAaTREBPUy3sExj4LBhGslmOyxm16z18ExpqS
         SCnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=KM/nHlU4zhsLfG8c0YB8Ffe5Um+2X27Yn+rA2wKE+IE=;
        b=eXktIJX99weRpOT/IFfqTn2mbuN31jhfgIKOlAhGhn8hog99t4z1iRuP/xRk31hj1b
         gEdNTDMVsfBu9wbIKVeLoVyggDBCPFTJ0+AMW+qn48m4WTormB3q89NVPd5c9n2aHjg4
         7PKBRSRf0/KDxXQi4U8a30lxCA2WJZ6lnEzrrxfUmTIyrkdU7f0F3JeAWxqLW57jHoVC
         bcAAX7Vv7GHUZIErvroydaPa1qyqQfJh6QSk6cKhD250vmO8faXSuVsmmAeHJvz8yyVX
         +ka4uAclRZen3QtnoCi/m23l0ZN5AturYA+S5sWkKd2NR9TqFyciXynHUQaaXWIX9+qs
         JMoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eQahIBYt;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t1si23478457pgh.406.2019.05.21.13.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:29:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eQahIBYt;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LKRnPo018599
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=KM/nHlU4zhsLfG8c0YB8Ffe5Um+2X27Yn+rA2wKE+IE=;
 b=eQahIBYtJTjd/zZp2PxdvVJmtCZx0dBSF0FPO/MDcPR3twsLvVsw5xk+Ax9vkT8ZznJi
 mAEypsAzuvw6xX5ZrV96rxMKtwsrKyfbeFdCxw5W3umAcQ1QE8JT6YMMqzGUeefxUdM5
 /1Xirz2vJZ7v0JlBEcvMWZuMRFeDMc8MTxU= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2smd9cjh28-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:29:03 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 21 May 2019 13:29:01 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 15EA91245FFB0; Tue, 21 May 2019 13:07:50 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Shakeel Butt
	<shakeelb@google.com>, Christoph Lameter <cl@linux.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v5 6/7] mm: reparent slab memory on cgroup removal
Date: Tue, 21 May 2019 13:07:34 -0700
Message-ID: <20190521200735.2603003-7-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190521200735.2603003-1-guro@fb.com>
References: <20190521200735.2603003-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210128
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's reparent memcg slab memory on memcg offlining. This allows us
to release the memory cgroup without waiting for the last outstanding
kernel object (e.g. dentry used by another application).

So instead of reparenting all accounted slab pages, let's do reparent
a relatively small amount of kmem_caches. Reparenting is performed as
a part of the deactivation process.

Since the parent cgroup is already charged, everything we need to do
is to splice the list of kmem_caches to the parent's kmem_caches list,
swap the memcg pointer and drop the css refcounter for each kmem_cache
and adjust the parent's css refcounter. Quite simple.

Please, note that kmem_cache->memcg_params.memcg isn't a stable
pointer anymore. It's safe to read it under rcu_read_lock() or
with slab_mutex held.

We can race with the slab allocation and deallocation paths. It's not
a big problem: parent's charge and slab global stats are always
correct, and we don't care anymore about the child usage and global
stats. The child cgroup is already offline, so we don't use or show it
anywhere.

Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
aren't used anywhere except count_shadow_nodes(). But even there it
won't break anything: after reparenting "nodes" will be 0 on child
level (because we're already reparenting shrinker lists), and on
parent level page stats always were 0, and this patch won't change
anything.

Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/slab.h |  4 ++--
 mm/memcontrol.c      | 14 ++++++++------
 mm/slab.h            | 21 ++++++++++++++++-----
 mm/slab_common.c     | 21 ++++++++++++++++++---
 4 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1b54e5f83342..109cab2ad9b4 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -152,7 +152,7 @@ void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
-void memcg_deactivate_kmem_caches(struct mem_cgroup *);
+void memcg_deactivate_kmem_caches(struct mem_cgroup *, struct mem_cgroup *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -638,7 +638,7 @@ struct memcg_cache_params {
 			bool dying;
 		};
 		struct {
-			struct mem_cgroup *memcg;
+			struct mem_cgroup __rcu *memcg;
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
 			struct percpu_ref refcnt;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1828d82763d8..de664ff1e310 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3224,15 +3224,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	 */
 	memcg->kmem_state = KMEM_ALLOCATED;
 
-	memcg_deactivate_kmem_caches(memcg);
-
-	kmemcg_id = memcg->kmemcg_id;
-	BUG_ON(kmemcg_id < 0);
-
 	parent = parent_mem_cgroup(memcg);
 	if (!parent)
 		parent = root_mem_cgroup;
 
+	memcg_deactivate_kmem_caches(memcg, parent);
+
+	kmemcg_id = memcg->kmemcg_id;
+	BUG_ON(kmemcg_id < 0);
+
 	/*
 	 * Change kmemcg_id of this cgroup and all its descendants to the
 	 * parent's id, and then move all entries from this cgroup's list_lrus
@@ -3265,7 +3265,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4677,6 +4676,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index b86744c58702..7ba50e526d82 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -268,10 +268,18 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	struct lruvec *lruvec;
 	int ret;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = rcu_dereference(s->memcg_params.memcg);
+	while (memcg && !css_tryget_online(&memcg->css))
+		memcg = parent_mem_cgroup(memcg);
+	rcu_read_unlock();
+
+	if (unlikely(!memcg))
+		return true;
+
 	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	if (ret)
-		return ret;
+		goto out;
 
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
@@ -279,8 +287,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	/* transer try_charge() page references to kmem_cache */
 	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
 	css_put_many(&memcg->css, 1 << order);
-
-	return 0;
+out:
+	css_put(&memcg->css);
+	return ret;
 }
 
 /*
@@ -293,10 +302,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = rcu_dereference(s->memcg_params.memcg);
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
 	memcg_kmem_uncharge_memcg(page, order, memcg);
+	rcu_read_unlock();
 
 	percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8d68de4a2341..7607a40772aa 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -237,7 +237,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
 		css_get(&memcg->css);
-		s->memcg_params.memcg = memcg;
+		rcu_assign_pointer(s->memcg_params.memcg, memcg);
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
 		list_add(&s->memcg_params.kmem_caches_node,
@@ -252,7 +252,8 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
-		css_put(&s->memcg_params.memcg->css);
+		mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
+			lockdep_is_held(&slab_mutex)));
 	}
 }
 #else
@@ -776,11 +777,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
 }
 
-void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
+void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg,
+				  struct mem_cgroup *parent)
 {
 	int idx;
 	struct memcg_cache_array *arr;
 	struct kmem_cache *s, *c;
+	unsigned int nr_reparented;
 
 	idx = memcg_cache_id(memcg);
 
@@ -798,6 +801,18 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
+	nr_reparented = 0;
+	list_for_each_entry(s, &memcg->kmem_caches,
+			    memcg_params.kmem_caches_node) {
+		rcu_assign_pointer(s->memcg_params.memcg, parent);
+		css_put(&memcg->css);
+		nr_reparented++;
+	}
+	if (nr_reparented) {
+		list_splice_init(&memcg->kmem_caches,
+				 &parent->kmem_caches);
+		css_get_many(&parent->css, nr_reparented);
+	}
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
-- 
2.20.1

