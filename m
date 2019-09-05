Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94A4CC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2C0520825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:37:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YZe7maOd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2C0520825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89366B0007; Thu,  5 Sep 2019 18:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B39C06B0008; Thu,  5 Sep 2019 18:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A28236B000A; Thu,  5 Sep 2019 18:37:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 8200E6B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:37:36 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 09E1345C1
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:37:35 +0000 (UTC)
X-FDA: 75902330070.23.toad97_7ea6be9dd447
X-HE-Tag: toad97_7ea6be9dd447
X-Filterd-Recvd-Size: 10866
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:37:34 +0000 (UTC)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85MXXx0001345
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 15:37:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=lSqqi78fHp3ioQ5wDihlnWL/SQg6g8y6flEaOHNcEsI=;
 b=YZe7maOdTas13hB6VT6ZbnQkD0fue86QdDdagREhK72OKGEPnUHyCZ65Pmn1+2VoCu99
 Z36JS38vbSG9SVGpfzmZN01QPLH8X/ZANXk0vJ7NXbf/yqNTi97E0MW9W5eLi3GfFlvX
 T1HrSw1NNWA1eOBGQdxlg9qVmgufgMsfIjM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uu93b0m8a-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 15:37:33 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 15:37:31 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 9C6161722F059; Thu,  5 Sep 2019 15:37:30 -0700 (PDT)
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
Subject: [PATCH RFC 02/14] mm: memcg: introduce mem_cgroup_ptr
Date: Thu, 5 Sep 2019 15:37:07 -0700
Message-ID: <20190905223707.1779299-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190905214553.1643060-1-guro@fb.com>
References: <20190905214553.1643060-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_09:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 spamscore=0 clxscore=1015 lowpriorityscore=0 suspectscore=3
 impostorscore=0 adultscore=0 bulkscore=0 phishscore=0 malwarescore=0
 mlxscore=0 mlxlogscore=999 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1906280000 definitions=main-1909050210
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit introduces mem_cgroup_ptr structure and corresponding API.
It implements a pointer to a memory cgroup with a built-in reference
counter. The main goal of it is to implement reparenting efficiently.

If a number of objects (e.g. slab pages) have to keep a pointer and
a reference to a memory cgroup, they can use mem_cgroup_ptr instead.
On reparenting, only one mem_cgroup_ptr->memcg pointer has to be
changed, instead of walking over all accounted objects.

mem_cgroup_ptr holds a single reference to the corresponding memory
cgroup. Because it's initialized before the css reference counter,
css's refcounter can't be bumped at allocation time. Instead, it's
bumped on reparenting which happens during offlining. A cgroup is
never released online, so it's fine.

mem_cgroup_ptr is released using rcu, so memcg->kmem_memcg_ptr can
be accessed in a rcu read section. On reparenting it's atomically
switched to NULL. If the reader gets NULL, it can just read parent's
kmem_memcg_ptr instead.

Each memory cgroup contains a list of kmem_memcg_ptrs. On reparenting
the list is spliced into the parent's list. The list is protected
using the css set lock.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 50 ++++++++++++++++++++++
 mm/memcontrol.c            | 87 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 133 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 120d39066148..d822ea66278c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -23,6 +23,7 @@
 #include <linux/page-flags.h>
 
 struct mem_cgroup;
+struct mem_cgroup_ptr;
 struct page;
 struct mm_struct;
 struct kmem_cache;
@@ -199,6 +200,22 @@ struct memcg_cgwb_frn {
 	struct wb_completion done;	/* tracks in-flight foreign writebacks */
 };
 
+/*
+ * A pointer to a memory cgroup with a built-in reference counter.
+ * For a use as an intermediate object to simplify reparenting of
+ * objects charged to the cgroup. The memcg pointer can be switched
+ * to the parent cgroup without a need to modify all objects
+ * which hold the reference to the cgroup.
+ */
+struct mem_cgroup_ptr {
+	struct percpu_ref refcnt;
+	struct mem_cgroup *memcg;
+	union {
+		struct list_head list;
+		struct rcu_head rcu;
+	};
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -312,6 +329,8 @@ struct mem_cgroup {
 	int kmemcg_id;
 	enum memcg_kmem_state kmem_state;
 	struct list_head kmem_caches;
+	struct mem_cgroup_ptr __rcu *kmem_memcg_ptr;
+	struct list_head kmem_memcg_ptr_list;
 #endif
 
 	int last_scanned_node;
@@ -440,6 +459,21 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+static inline bool mem_cgroup_ptr_tryget(struct mem_cgroup_ptr *ptr)
+{
+	return percpu_ref_tryget(&ptr->refcnt);
+}
+
+static inline void mem_cgroup_ptr_get(struct mem_cgroup_ptr *ptr)
+{
+	percpu_ref_get(&ptr->refcnt);
+}
+
+static inline void mem_cgroup_ptr_put(struct mem_cgroup_ptr *ptr)
+{
+	percpu_ref_put(&ptr->refcnt);
+}
+
 static inline void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 	if (memcg)
@@ -1433,6 +1467,22 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
+static inline struct mem_cgroup_ptr *
+mem_cgroup_get_kmem_ptr(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup_ptr *memcg_ptr;
+
+	rcu_read_lock();
+	do {
+		memcg_ptr = rcu_dereference(memcg->kmem_memcg_ptr);
+		if (memcg_ptr && mem_cgroup_ptr_tryget(memcg_ptr))
+			break;
+	} while ((memcg = parent_mem_cgroup(memcg)));
+	rcu_read_unlock();
+
+	return memcg_ptr;
+}
+
 #else
 
 static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index effefcec47b3..cb9adb31360e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -266,6 +266,77 @@ struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr)
 }
 
 #ifdef CONFIG_MEMCG_KMEM
+extern spinlock_t css_set_lock;
+
+static void memcg_ptr_release(struct percpu_ref *ref)
+{
+	struct mem_cgroup_ptr *ptr = container_of(ref, struct mem_cgroup_ptr,
+						  refcnt);
+	unsigned long flags;
+
+	spin_lock_irqsave(&css_set_lock, flags);
+	list_del(&ptr->list);
+	spin_unlock_irqrestore(&css_set_lock, flags);
+
+	mem_cgroup_put(ptr->memcg);
+	percpu_ref_exit(ref);
+	kfree_rcu(ptr, rcu);
+}
+
+static int memcg_init_kmem_memcg_ptr(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup_ptr *kmem_memcg_ptr;
+	int ret;
+
+	kmem_memcg_ptr = kmalloc(sizeof(struct mem_cgroup_ptr), GFP_KERNEL);
+	if (!kmem_memcg_ptr)
+		return -ENOMEM;
+
+	ret = percpu_ref_init(&kmem_memcg_ptr->refcnt, memcg_ptr_release,
+			      0, GFP_KERNEL);
+	if (ret) {
+		kfree(kmem_memcg_ptr);
+		return ret;
+	}
+
+	kmem_memcg_ptr->memcg = memcg;
+	INIT_LIST_HEAD(&kmem_memcg_ptr->list);
+	rcu_assign_pointer(memcg->kmem_memcg_ptr, kmem_memcg_ptr);
+	list_add(&kmem_memcg_ptr->list, &memcg->kmem_memcg_ptr_list);
+	return 0;
+}
+
+static void memcg_reparent_kmem_memcg_ptr(struct mem_cgroup *memcg,
+					  struct mem_cgroup *parent)
+{
+	unsigned int nr_reparented = 0;
+	struct mem_cgroup_ptr *memcg_ptr = NULL;
+
+	rcu_swap_protected(memcg->kmem_memcg_ptr, memcg_ptr, true);
+	percpu_ref_kill(&memcg_ptr->refcnt);
+
+	/*
+	 * kmem_memcg_ptr is initialized before css refcounter, so until now
+	 * it doesn't hold a reference to the memcg. Bump it here.
+	 */
+	css_get(&memcg->css);
+
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry(memcg_ptr, &memcg->kmem_memcg_ptr_list, list) {
+		xchg(&memcg_ptr->memcg, parent);
+		nr_reparented++;
+	}
+	if (nr_reparented)
+		list_splice(&memcg->kmem_memcg_ptr_list,
+			    &parent->kmem_memcg_ptr_list);
+	spin_unlock_irq(&css_set_lock);
+
+	if (nr_reparented) {
+		css_get_many(&parent->css, nr_reparented);
+		css_put_many(&memcg->css, nr_reparented);
+	}
+}
+
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
  * The main reason for not using cgroup id for this:
@@ -3554,7 +3625,7 @@ static void memcg_flush_percpu_vmevents(struct mem_cgroup *memcg)
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
-	int memcg_id;
+	int memcg_id, ret;
 
 	if (cgroup_memory_nokmem)
 		return 0;
@@ -3566,6 +3637,12 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 	if (memcg_id < 0)
 		return memcg_id;
 
+	ret = memcg_init_kmem_memcg_ptr(memcg);
+	if (ret) {
+		memcg_free_cache_id(memcg_id);
+		return ret;
+	}
+
 	static_branch_inc(&memcg_kmem_enabled_key);
 	/*
 	 * A memory cgroup is considered kmem-online as soon as it gets
@@ -3601,12 +3678,13 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 		parent = root_mem_cgroup;
 
 	/*
-	 * Deactivate and reparent kmem_caches. Then flush percpu
-	 * slab statistics to have precise values at the parent and
-	 * all ancestor levels. It's required to keep slab stats
+	 * Deactivate and reparent kmem_caches and reparent kmem_memcg_ptr.
+	 * Then flush percpu slab statistics to have precise values at the
+	 * parent and all ancestor levels. It's required to keep slab stats
 	 * accurate after the reparenting of kmem_caches.
 	 */
 	memcg_deactivate_kmem_caches(memcg, parent);
+	memcg_reparent_kmem_memcg_ptr(memcg, parent);
 	memcg_flush_percpu_vmstats(memcg, true);
 
 	kmemcg_id = memcg->kmemcg_id;
@@ -5171,6 +5249,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	memcg->socket_pressure = jiffies;
 #ifdef CONFIG_MEMCG_KMEM
 	memcg->kmemcg_id = -1;
+	INIT_LIST_HEAD(&memcg->kmem_memcg_ptr_list);
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
-- 
2.21.0


