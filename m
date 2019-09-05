Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDDECC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:24:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D05862070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:24:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="CNOo37C+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D05862070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51756B0003; Thu,  5 Sep 2019 18:24:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDB126B0005; Thu,  5 Sep 2019 18:24:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA1866B0007; Thu,  5 Sep 2019 18:24:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7E56B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:24:36 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0EF5A180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:24:36 +0000 (UTC)
X-FDA: 75902297352.25.shop72_2816ca3ee5f53
X-HE-Tag: shop72_2816ca3ee5f53
X-Filterd-Recvd-Size: 12313
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:24:35 +0000 (UTC)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85Lhr2v032677
	for <linux-mm@kvack.org>; Thu, 5 Sep 2019 14:46:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=F6+Y/3KaVJP+sTReowVqRgiVYePOKXbKfRKu1OS1cQw=;
 b=CNOo37C+wR2FT9w55v9ic/fR2lcHK0+5ibSpi3gCiet14MHztSwdQmTCxECKpkawlFrz
 cNT48JxVG1xWiacjxiu3FP4NIufgJ4FrCOm9jbaZw1XwFfP/ds34no/uvndPhO90KziS
 cd7Ko/mbtQPu4baCb4DIyzvuRUP8vLq0Q84= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2utksg62eu-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:46:09 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 14:46:08 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id A2A7A17229DF8; Thu,  5 Sep 2019 14:46:06 -0700 (PDT)
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
Subject: [PATCH RFC 01/14] mm: memcg: subpage charging API
Date: Thu, 5 Sep 2019 14:45:45 -0700
Message-ID: <20190905214553.1643060-2-guro@fb.com>
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

Introduce an API to charge subpage objects to the memory cgroup.
The API will be used by the new slab memory controller. Later it
can also be used to implement percpu memory accounting.
In both cases, a single page can be shared between multiple cgroups
(and in percpu case a single allocation is split over multiple pages),
so it's not possible to use page-based accounting.

The implementation is based on percpu stocks. Memory cgroups are still
charged in pages, and the residue is stored in perpcu stock, or on the
memcg itself, when it's necessary to flush the stock.

Please, note, that unlike the generic page charging API, a subpage
object is not holding a reference to the memory cgroup. It's because
a more complicated indirect scheme is required in order to implement
cheap reparenting. The percpu stock holds a single reference to the
cached cgroup though.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h |   4 ++
 mm/memcontrol.c            | 129 +++++++++++++++++++++++++++++++++----
 2 files changed, 119 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0c762e8ca6a6..120d39066148 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -214,6 +214,7 @@ struct mem_cgroup {
 	/* Accounted resources */
 	struct page_counter memory;
 	struct page_counter swap;
+	atomic_t nr_stocked_bytes;
 
 	/* Legacy consumer-oriented counters */
 	struct page_counter memsw;
@@ -1370,6 +1371,9 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			      struct mem_cgroup *memcg);
 void __memcg_kmem_uncharge_memcg(struct mem_cgroup *memcg,
 				 unsigned int nr_pages);
+int __memcg_kmem_charge_subpage(struct mem_cgroup *memcg, size_t size,
+				gfp_t gfp);
+void __memcg_kmem_uncharge_subpage(struct mem_cgroup *memcg, size_t size);
 
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1c4c08b45e44..effefcec47b3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2149,6 +2149,10 @@ EXPORT_SYMBOL(unlock_page_memcg);
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached; /* this never be root cgroup */
 	unsigned int nr_pages;
+
+	struct mem_cgroup *subpage_cached;
+	unsigned int nr_bytes;
+
 	struct work_struct work;
 	unsigned long flags;
 #define FLUSHING_CACHED_CHARGE	0
@@ -2189,6 +2193,29 @@ static bool consume_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 	return ret;
 }
 
+static bool consume_subpage_stock(struct mem_cgroup *memcg,
+				  unsigned int nr_bytes)
+{
+	struct memcg_stock_pcp *stock;
+	unsigned long flags;
+	bool ret = false;
+
+	if (nr_bytes > (MEMCG_CHARGE_BATCH << PAGE_SHIFT))
+		return ret;
+
+	local_irq_save(flags);
+
+	stock = this_cpu_ptr(&memcg_stock);
+	if (memcg == stock->subpage_cached && stock->nr_bytes >= nr_bytes) {
+		stock->nr_bytes -= nr_bytes;
+		ret = true;
+	}
+
+	local_irq_restore(flags);
+
+	return ret;
+}
+
 /*
  * Returns stocks cached in percpu and reset cached information.
  */
@@ -2206,6 +2233,27 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 	stock->cached = NULL;
 }
 
+static void drain_subpage_stock(struct memcg_stock_pcp *stock)
+{
+	struct mem_cgroup *old = stock->subpage_cached;
+
+	if (stock->nr_bytes) {
+		unsigned int nr_pages = stock->nr_bytes >> PAGE_SHIFT;
+		unsigned int nr_bytes = stock->nr_bytes & (PAGE_SIZE - 1);
+
+		page_counter_uncharge(&old->memory, nr_pages);
+		if (do_memsw_account())
+			page_counter_uncharge(&old->memsw, nr_pages);
+
+		atomic_add(nr_bytes, &old->nr_stocked_bytes);
+		stock->nr_bytes = 0;
+	}
+	if (stock->subpage_cached) {
+		css_put(&old->css);
+		stock->subpage_cached = NULL;
+	}
+}
+
 static void drain_local_stock(struct work_struct *dummy)
 {
 	struct memcg_stock_pcp *stock;
@@ -2218,8 +2266,11 @@ static void drain_local_stock(struct work_struct *dummy)
 	local_irq_save(flags);
 
 	stock = this_cpu_ptr(&memcg_stock);
-	drain_stock(stock);
-	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
+	if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
+		drain_stock(stock);
+		drain_subpage_stock(stock);
+		clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
+	}
 
 	local_irq_restore(flags);
 }
@@ -2248,6 +2299,29 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 	local_irq_restore(flags);
 }
 
+static void refill_subpage_stock(struct mem_cgroup *memcg,
+				 unsigned int nr_bytes)
+{
+	struct memcg_stock_pcp *stock;
+	unsigned long flags;
+
+	local_irq_save(flags);
+
+	stock = this_cpu_ptr(&memcg_stock);
+	if (stock->subpage_cached != memcg) { /* reset if necessary */
+		drain_subpage_stock(stock);
+		css_get(&memcg->css);
+		stock->subpage_cached = memcg;
+		stock->nr_bytes = atomic_xchg(&memcg->nr_stocked_bytes, 0);
+	}
+	stock->nr_bytes += nr_bytes;
+
+	if (stock->nr_bytes > (MEMCG_CHARGE_BATCH << PAGE_SHIFT))
+		drain_subpage_stock(stock);
+
+	local_irq_restore(flags);
+}
+
 /*
  * Drains all per-CPU charge caches for given root_memcg resp. subtree
  * of the hierarchy under it.
@@ -2276,6 +2350,9 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 		if (memcg && stock->nr_pages &&
 		    mem_cgroup_is_descendant(memcg, root_memcg))
 			flush = true;
+		memcg = stock->subpage_cached;
+		if (memcg && mem_cgroup_is_descendant(memcg, root_memcg))
+			flush = true;
 		rcu_read_unlock();
 
 		if (flush &&
@@ -2500,8 +2577,9 @@ void mem_cgroup_handle_over_high(void)
 }
 
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
-		      unsigned int nr_pages)
+		      unsigned int amount, bool subpage)
 {
+	unsigned int nr_pages = subpage ? ((amount >> PAGE_SHIFT) + 1) : amount;
 	unsigned int batch = max(MEMCG_CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
@@ -2514,7 +2592,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_is_root(memcg))
 		return 0;
 retry:
-	if (consume_stock(memcg, nr_pages))
+	if (subpage && consume_subpage_stock(memcg, amount))
+		return 0;
+	else if (!subpage && consume_stock(memcg, nr_pages))
 		return 0;
 
 	if (!do_memsw_account() ||
@@ -2632,14 +2712,22 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	page_counter_charge(&memcg->memory, nr_pages);
 	if (do_memsw_account())
 		page_counter_charge(&memcg->memsw, nr_pages);
-	css_get_many(&memcg->css, nr_pages);
+
+	if (subpage)
+		refill_subpage_stock(memcg, (nr_pages << PAGE_SHIFT) - amount);
+	else
+		css_get_many(&memcg->css, nr_pages);
 
 	return 0;
 
 done_restock:
-	css_get_many(&memcg->css, batch);
-	if (batch > nr_pages)
-		refill_stock(memcg, batch - nr_pages);
+	if (subpage && (batch << PAGE_SHIFT) > amount) {
+		refill_subpage_stock(memcg, (batch << PAGE_SHIFT) - amount);
+	} else if (!subpage) {
+		css_get_many(&memcg->css, batch);
+		if (batch > nr_pages)
+			refill_stock(memcg, batch - nr_pages);
+	}
 
 	/*
 	 * If the hierarchy is above the normal consumption range, schedule
@@ -2942,7 +3030,7 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 	struct page_counter *counter;
 	int ret;
 
-	ret = try_charge(memcg, gfp, nr_pages);
+	ret = try_charge(memcg, gfp, nr_pages, false);
 	if (ret)
 		return ret;
 
@@ -3020,6 +3108,18 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 
 	css_put_many(&memcg->css, nr_pages);
 }
+
+int __memcg_kmem_charge_subpage(struct mem_cgroup *memcg, size_t size,
+				gfp_t gfp)
+{
+	return try_charge(memcg, gfp, size, true);
+}
+
+void __memcg_kmem_uncharge_subpage(struct mem_cgroup *memcg, size_t size)
+{
+	refill_subpage_stock(memcg, size);
+}
+
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -5267,7 +5367,8 @@ static int mem_cgroup_do_precharge(unsigned long count)
 	int ret;
 
 	/* Try a single bulk charge without reclaim first, kswapd may wake */
-	ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_DIRECT_RECLAIM, count);
+	ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_DIRECT_RECLAIM, count,
+			 false);
 	if (!ret) {
 		mc.precharge += count;
 		return ret;
@@ -5275,7 +5376,7 @@ static int mem_cgroup_do_precharge(unsigned long count)
 
 	/* Try charges one by one with reclaim, but do not retry */
 	while (count--) {
-		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1);
+		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1, false);
 		if (ret)
 			return ret;
 		mc.precharge++;
@@ -6487,7 +6588,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 	if (!memcg)
 		memcg = get_mem_cgroup_from_mm(mm);
 
-	ret = try_charge(memcg, gfp_mask, nr_pages);
+	ret = try_charge(memcg, gfp_mask, nr_pages, false);
 
 	css_put(&memcg->css);
 out:
@@ -6866,10 +6967,10 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 
 	mod_memcg_state(memcg, MEMCG_SOCK, nr_pages);
 
-	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
+	if (try_charge(memcg, gfp_mask, nr_pages, false) == 0)
 		return true;
 
-	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
+	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages, false);
 	return false;
 }
 
-- 
2.21.0


