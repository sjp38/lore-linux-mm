Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD1EEC04AAE
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62EC820675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:30:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PdLT9fVP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62EC820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0D986B0008; Wed,  8 May 2019 16:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7D526B000C; Wed,  8 May 2019 16:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E52D6B000D; Wed,  8 May 2019 16:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 337A96B0008
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:30:52 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q18so60756pll.16
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=PF7epo97MxShKnhAVmvE6ZPniKssoQry9k+G7xvR+Wg=;
        b=rayIYHoZJ4Yi37xeW5JT8uYKDyL3w9CoIIJIjPGye1MUCfAP9UmHcx/zpNTV6BNJSj
         XNe0GpieaRyp4F68z2sltgHTwSGZ6mGHeVbdaHZOy3C9oX+zdZx6PJitCifWqYZi2PuM
         dRtguB94f7e4GL1RdH6YTefIWYq1+WDmoS+Y60XFOCTK4BcoU4+aVYLWleTkPOi2DYIu
         RNA8RGWNMUsj5u49Un41TgS/ncVMPd9/mNap+VHNzm+1A+WPzss6JHCPAHFlNALRdVrK
         0eLfYSXxEQ8x7q8ahf7OH+6eoPLLLKrHTZFhc9xHo+PZ+SNemLfm5mpgg9IieH6tr67R
         34Ow==
X-Gm-Message-State: APjAAAX+5wxNzt/v3gOtcZNLJzufzZkivGDZUJIMPGkuQd33Cx+gdfTs
	zjV9WubeFZwOeJ4NqMJrdiQKLWlUo+DAWzrcciiU7x2bFvLoIJOWyyAOEOXJq+MSccCc/nJazXM
	/gKWebEAjlmrPliyO6hKM8aLcqQ1522l0datXMhI7m3NOkMA1tWeFbaBN12FR9qVzUQ==
X-Received: by 2002:a65:60c7:: with SMTP id r7mr199490pgv.22.1557347451750;
        Wed, 08 May 2019 13:30:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3wGEzssrZ96w1tIaMlP7xr7cVfCuw+fwTnAVrUvfxQuO7acGpLgg8MVrnzHbAEbjqVXH8
X-Received: by 2002:a65:60c7:: with SMTP id r7mr199376pgv.22.1557347450756;
        Wed, 08 May 2019 13:30:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557347450; cv=none;
        d=google.com; s=arc-20160816;
        b=b7fyG6SWNMuykgIrQdEA621CeU9LP6SGYdDdz6LqMRSc+Oh1Scgs+cH6yrnpg/ln/p
         KdRuNMoIPn3Nwj8SRNdHkpat8WD16C9KKbBZ81xL5u3taAmdQw6mZMEK6RlVPAse7xtl
         FUxIonLutqDG2rCQCQHwEBEttdw8e2HGvBinc0paW80DgH4gvX5qa561rSrIbr+qA40Y
         gOMPqPCssm/srXpgn+wFhwJ7NuBGTPxpmuoi272l6NbZ9eCLqiPdt7VzRH/cOnKqauCm
         IC9PJpjq2IpVIAj1HuSSyFU7plvgDch8aNfge7IoPUhkmtAe/FGkqk3qlgaGiyQ71+29
         uiRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=PF7epo97MxShKnhAVmvE6ZPniKssoQry9k+G7xvR+Wg=;
        b=ar5vmHfPEgIOz2CurtHYdA24auuesdnJJ0pgvMKr8v3x/U0RYkQlbaznbO646JLpqb
         l5Yv6/ruyP3iSmo5fuZyLFXcyGiNNGrRM+Mki7NU/0MCTcOd/FEOIgZ4CWVXd9ff34L2
         Oe6vdP+W6sLnUgONUlJaOMIWK32eYfo2VE3zBEvwfY4xA3QGWp5KPye806A9KtPJO3k7
         nO3QWaFY8wMS5X1YMf3Eh2PqZ95xKJ1xB2RwpRTyBfvQ7SXSP4I0F5JONOrMtwW8r7Ha
         +Zq55e7/bbiTLmYSrYigQf2CRs9womBdMsPo1w7tREGCLE3cgchZTXvtqayqZT8IOppj
         g94w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PdLT9fVP;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t22si17118012pgg.292.2019.05.08.13.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:30:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PdLT9fVP;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KEfM6003391
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:30:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=PF7epo97MxShKnhAVmvE6ZPniKssoQry9k+G7xvR+Wg=;
 b=PdLT9fVP79Ypex9FoewJmzx3IDUzS04bP65H3mEX5VyS0F11AcLsYBJCeetwwRY7ABGk
 tjn8ehydvbNMWE37KHnrBCPKXPamz9wMlBit2fds4Q1gtpdt1xnJYIO+6fY9hMruDGY3
 3Kx9mjSAIe+hfmZmmmlHNnA4QgSf94ZiBnQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc2q3gv7c-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 8 May 2019 13:30:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 0739611CDBCF4; Wed,  8 May 2019 13:25:00 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Christoph Lameter
	<cl@linux.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 2/7] mm: generalize postponed non-root kmem_cache deactivation
Date: Wed, 8 May 2019 13:24:53 -0700
Message-ID: <20190508202458.550808-3-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
References: <20190508202458.550808-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently SLUB uses a work scheduled after an RCU grace period
to deactivate a non-root kmem_cache. This mechanism can be reused
for kmem_caches reparenting, but requires some generalization.

Let's decouple all infrastructure (rcu callback, work callback)
from the SLUB-specific code, so it can be used with SLAB as well.

Also, let's rename some functions to make the code look simpler.
All SLAB/SLUB-specific functions start with "__". Remove "deact_"
prefix from the corresponding struct fields.

Here is the graph of a new calling scheme:
kmemcg_cache_deactivate()
  __kmemcg_cache_deactivate()                  SLAB/SLUB-specific
  kmemcg_schedule_work_after_rcu()             rcu
    kmemcg_after_rcu_workfn()                  work
      kmemcg_cache_deactivate_after_rcu()
        __kmemcg_cache_deactivate_after_rcu()  SLAB/SLUB-specific

instead of:
__kmemcg_cache_deactivate()                    SLAB/SLUB-specific
  slab_deactivate_memcg_cache_rcu_sched()      SLUB-only
    kmemcg_deactivate_rcufn                    SLUB-only, rcu
      kmemcg_deactivate_workfn                 SLUB-only, work
        kmemcg_cache_deact_after_rcu()         SLUB-only

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  6 ++---
 mm/slab.c            |  4 +++
 mm/slab.h            |  3 ++-
 mm/slab_common.c     | 62 ++++++++++++++++++++------------------------
 mm/slub.c            |  8 +-----
 5 files changed, 38 insertions(+), 45 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..47923c173f30 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -642,10 +642,10 @@ struct memcg_cache_params {
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
 
-			void (*deact_fn)(struct kmem_cache *);
+			void (*work_fn)(struct kmem_cache *);
 			union {
-				struct rcu_head deact_rcu_head;
-				struct work_struct deact_work;
+				struct rcu_head rcu_head;
+				struct work_struct work;
 			};
 		};
 	};
diff --git a/mm/slab.c b/mm/slab.c
index f6eff59e018e..83000e46b870 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2281,6 +2281,10 @@ void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
 {
 	__kmem_cache_shrink(cachep);
 }
+
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
+{
+}
 #endif
 
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index 6a562ca72bca..4a261c97c138 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -172,6 +172,7 @@ int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
@@ -291,7 +292,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-				void (*deact_fn)(struct kmem_cache *));
+				void (*work_fn)(struct kmem_cache *));
 
 #else /* CONFIG_MEMCG_KMEM */
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6e00bdf8618d..4e5b4292a763 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -691,17 +691,18 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	put_online_cpus();
 }
 
-static void kmemcg_deactivate_workfn(struct work_struct *work)
+static void kmemcg_after_rcu_workfn(struct work_struct *work)
 {
 	struct kmem_cache *s = container_of(work, struct kmem_cache,
-					    memcg_params.deact_work);
+					    memcg_params.work);
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
-	s->memcg_params.deact_fn(s);
+	s->memcg_params.work_fn(s);
+	s->memcg_params.work_fn = NULL;
 
 	mutex_unlock(&slab_mutex);
 
@@ -712,37 +713,28 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 	css_put(&s->memcg_params.memcg->css);
 }
 
-static void kmemcg_deactivate_rcufn(struct rcu_head *head)
+/*
+ * We need to grab blocking locks.  Bounce to ->work.  The
+ * work item shares the space with the RCU head and can't be
+ * initialized eariler.
+*/
+static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
 {
 	struct kmem_cache *s = container_of(head, struct kmem_cache,
-					    memcg_params.deact_rcu_head);
+					    memcg_params.rcu_head);
 
-	/*
-	 * We need to grab blocking locks.  Bounce to ->deact_work.  The
-	 * work item shares the space with the RCU head and can't be
-	 * initialized eariler.
-	 */
-	INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
-	queue_work(memcg_kmem_cache_wq, &s->memcg_params.deact_work);
+	INIT_WORK(&s->memcg_params.work, kmemcg_after_rcu_workfn);
+	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
-/**
- * slab_deactivate_memcg_cache_rcu_sched - schedule deactivation after a
- *					   sched RCU grace period
- * @s: target kmem_cache
- * @deact_fn: deactivation function to call
- *
- * Schedule @deact_fn to be invoked with online cpus, mems and slab_mutex
- * held after a sched RCU grace period.  The slab is guaranteed to stay
- * alive until @deact_fn is finished.  This is to be used from
- * __kmemcg_cache_deactivate().
- */
-void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-					   void (*deact_fn)(struct kmem_cache *))
+static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
-	if (WARN_ON_ONCE(is_root_cache(s)) ||
-	    WARN_ON_ONCE(s->memcg_params.deact_fn))
-		return;
+	__kmemcg_cache_deactivate_after_rcu(s);
+}
+
+static void kmemcg_cache_deactivate(struct kmem_cache *s)
+{
+	__kmemcg_cache_deactivate(s);
 
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
@@ -750,8 +742,9 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
-	s->memcg_params.deact_fn = deact_fn;
-	call_rcu(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
+	WARN_ON_ONCE(s->memcg_params.work_fn);
+	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
+	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
 }
 
 void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
@@ -773,7 +766,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmemcg_cache_deactivate(c);
+		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -866,11 +859,12 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
 	mutex_unlock(&slab_mutex);
 
 	/*
-	 * SLUB deactivates the kmem_caches through call_rcu. Make
+	 * SLAB and SLUB deactivate the kmem_caches through call_rcu. Make
 	 * sure all registered rcu callbacks have been invoked.
 	 */
-	if (IS_ENABLED(CONFIG_SLUB))
-		rcu_barrier();
+#ifndef CONFIG_SLOB
+	rcu_barrier();
+#endif
 
 	/*
 	 * SLAB and SLUB create memcg kmem_caches through workqueue and SLUB
diff --git a/mm/slub.c b/mm/slub.c
index 16f7e4f5a141..43c34d54ad86 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4028,7 +4028,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 }
 
 #ifdef CONFIG_MEMCG
-static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
 	/*
 	 * Called with all the locks held after a sched RCU grace period.
@@ -4054,12 +4054,6 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slub_set_cpu_partial(s, 0);
 	s->min_partial = 0;
-
-	/*
-	 * s->cpu_partial is checked locklessly (see put_cpu_partial), so
-	 * we have to make sure the change is visible before shrinking.
-	 */
-	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
 #endif	/* CONFIG_MEMCG */
 
-- 
2.20.1

