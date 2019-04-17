Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65674C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1816821871
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TnQkXWhr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1816821871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E55896B000E; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8FA36B0010; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1DF06B0269; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 600796B0010
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:55:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e128so13226pfc.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:55:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NUinwwoqQqqlnaj+hfWxAVvkl/hYr3H9Nu7bos7N4pE=;
        b=iEBCn/8jrLgU+CpGlp1bv05f8/qrt01GhXQ71N3fXCI+QN3GsNZ+jmqiIggLPRn37W
         vUa+z0bPWS0VnlwCfIvGZ8kdyPsrWyp+3siWz+9jmYawbLMSA52yuenjNXjHnoKMpl7S
         n3UYEkNZk+h8bElQjH8Zkl2GFug0aR9Nsp4zQs8/+KmkaGmiyKje1LCzn7bYKiVfeZGX
         5q6LEXzcUDZAoP6foSX0Hv3yeHpP3pUwpw4LCqvhfFTtEDZ+u3Bse5wAOirTN9cX4Ic7
         azrqqDNDk1LvJOkMqT8KavIYlsqvSnRICyYsMm7dmF/u9MM9WX5hfYCl7yFajes29Wm6
         tttw==
X-Gm-Message-State: APjAAAX58t4UBEIWjkURf5fh5NscA850udNf6prWsLgad3UdxtoULLCP
	52hc0cy/cQqwTtGKWkSG22xLLqZqyZ1alql0zazE5AOH2xVA0ydPfqUxVIRDeok9oWaF0OChJcm
	JUpv6NWVfmhWQxBtmZHyeDTvh1qPA0biHG49PsoAMliOJG/c24ARuhJckOULC8gNRTA==
X-Received: by 2002:a63:2c09:: with SMTP id s9mr81422641pgs.411.1555538101976;
        Wed, 17 Apr 2019 14:55:01 -0700 (PDT)
X-Received: by 2002:a63:2c09:: with SMTP id s9mr81422595pgs.411.1555538101201;
        Wed, 17 Apr 2019 14:55:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538101; cv=none;
        d=google.com; s=arc-20160816;
        b=B/ZBr0m7QmKpXYfZQyE8uHSrQLgNHz31kjUGDyVHfPJd6w/CNaImOkDvU5UawcO3d0
         9GhLpNXrGj49yFL/6g6FJu3m581RTAObWux/G7dSPnVmsgIg520j7GSVAxgFp0XXAnNL
         z8RFsaYTxD8dx7OZrHLf01CseXrJsmgVKnP5VJxhfw9D/EZ9xcDVOAqJroPSYsf9Qcm5
         oSjlkno/DB5zd2okO3Xuzr59iIkCQER1ABmTcNr7yTzki0pYS+h1taep1ovJ5S+CAveq
         M7af7gCh+ANaon1bLILK+QtM1eTt1pN/QyCngTHhqaE6GRsEU7Vus1a7i/3evpwqvgIW
         1GVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NUinwwoqQqqlnaj+hfWxAVvkl/hYr3H9Nu7bos7N4pE=;
        b=rMrDf1V7LEbpxJe//F2+RWJjpUM0g6HP6ZYOpN50LfUCTuXOHvjbWRbJXwijcVTtcM
         OvPwAOogUsmMVCom3hAVu+IpBniAqju91nrv7EtJtciiu4xCpmNwR+s0y3k661JVV0d5
         wvvayGDemPmu1WGc4A608XwLYv0kHHhDcsPpXyMKFjaETbuVxjBjEgFjijuczGmnurVX
         /5ACU2G8rH1IeSQzYVoiGY7iTm01Ii1XTAahbqechbWiXYvFZn3a1mjvaGkMcLiWcbfz
         +2qYQv6f5GA/VwsYWawgI2qzD4L9g4YSqI9ZYBAqSRwQa7KJvP7os9zObWE02c8cIG7C
         aZsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TnQkXWhr;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k65sor40412pge.41.2019.04.17.14.55.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:55:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TnQkXWhr;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NUinwwoqQqqlnaj+hfWxAVvkl/hYr3H9Nu7bos7N4pE=;
        b=TnQkXWhriERaZfgxnd6oMoknEpldpZY4+ddqcjT9GjKwVe5mHq0dOSP71ukwgXypvq
         gzYvkoj5vWdSnXSRCCXCNagTc11B45enD9TrF5IxKI/NmjZLJcINdRJXe//lfyxQlxpA
         g1QIAY14d3wugoG2GI6i9vqpSBFgidozl3m/zEJH2ZbtqH1G7kNtgeATO01BFvh1iAug
         txs59zhsh/UB2k+oPSuUnLxiP6LHaLRttbMVvFmVYUbYIx18owHtFaviC8Mb2QvyP44e
         D/8viFGHj8Ezgc3m9xb9MnAOcO2tPQYTC2AC7tt88lJ76EfU3h1K7a0HOPPF2HSCG/n1
         td9Q==
X-Google-Smtp-Source: APXvYqxo8fFyf4UjadiGuY16LsgpI7/aYDRL0AuqAX0+SEjmKOud84TnNLhLUufhyWE4dCeVlf+U9g==
X-Received: by 2002:a63:6a44:: with SMTP id f65mr50910693pgc.354.1555538100889;
        Wed, 17 Apr 2019 14:55:00 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5597])
        by smtp.gmail.com with ESMTPSA id x6sm209024pfb.171.2019.04.17.14.54.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 14:55:00 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	david@fromorbit.com,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 5/5] mm: reparent slab memory on cgroup removal
Date: Wed, 17 Apr 2019 14:54:34 -0700
Message-Id: <20190417215434.25897-6-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417215434.25897-1-guro@fb.com>
References: <20190417215434.25897-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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
the last part of the deactivation process, so it's guaranteed that all
kmem_caches are not active at this moment.

Since the parent cgroup is already charged, everything we need to do
is to move the kmem_cache to the parent's kmem_caches list,
swap the memcg pointer, bump parent's css refcounter and drop
the cgroup's refcounter. Quite simple.

We can't race with the slab allocation path, and if we race with
deallocation path, it's not a big deal: parent's charge and slab stats
are always correct*, and we don't care anymore about the child usage
and stats. The child cgroup is already offline, so we don't use or
show it anywhere.

* please, look at the comment in kmemcg_cache_deactivate_after_rcu()
  for some additional details

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/memcontrol.c  |  4 +++-
 mm/slab.h        |  4 +++-
 mm/slab_common.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 87c06e342e05..2f61d13df0c4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3239,7 +3239,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4651,6 +4650,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 1f49945f5c1d..be4f04ef65f9 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -329,10 +329,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 		return;
 	}
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = READ_ONCE(s->memcg_params.memcg);
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, idx, -(1 << order));
 	memcg_kmem_uncharge_memcg(page, order, memcg);
+	rcu_read_unlock();
 
 	kmemcg_cache_put_many(s, 1 << order);
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3fdd02979a1c..fc2e86de402f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -745,7 +745,35 @@ void kmemcg_queue_cache_shutdown(struct kmem_cache *s)
 
 static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
+	struct mem_cgroup *memcg, *parent;
+
 	__kmemcg_cache_deactivate_after_rcu(s);
+
+	memcg = s->memcg_params.memcg;
+	parent = parent_mem_cgroup(memcg);
+	if (!parent)
+		parent = root_mem_cgroup;
+
+	if (memcg == parent)
+		return;
+
+	/*
+	 * Let's reparent the kmem_cache. It's already deactivated, so we
+	 * can't race with memcg_charge_slab(). We still can race with
+	 * memcg_uncharge_slab(), but it's not a problem. The parent cgroup
+	 * is already charged, so it's ok to uncharge either the parent cgroup
+	 * directly, either recursively.
+	 * The same is true for recursive vmstats. Local vmstats are not use
+	 * anywhere, except count_shadow_nodes(). But reparenting will not
+	 * cahnge anything for count_shadow_nodes(): on memcg removal
+	 * shrinker lists are reparented, so it always returns SHRINK_EMPTY
+	 * for non-leaf dead memcgs. For the parent memcgs local slab stats
+	 * are always 0 now, so reparenting will not change anything.
+	 */
+	list_move(&s->memcg_params.kmem_caches_node, &parent->kmem_caches);
+	s->memcg_params.memcg = parent;
+	css_get(&parent->css);
+	css_put(&memcg->css);
 }
 
 static void kmemcg_cache_deactivate(struct kmem_cache *s)
-- 
2.20.1

