Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30BA5C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D724E20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="hAHz+/8G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D724E20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56AE26B0007; Tue, 14 May 2019 17:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51D146B0008; Tue, 14 May 2019 17:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3208D6B000A; Tue, 14 May 2019 17:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 163C16B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:44:59 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id k23so444669ybj.6
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:44:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Gl8pp3KYsdZV699fGKd7n8I36sqXFKD3Pr1ctINiCIU=;
        b=WzLwmAezkcXUYY0snAtE9xuNvyxcWQmgCWy++IKUAZ02yaoNBl6YhkuWdddjJF0+z9
         Qks8QxYUfnfuaFDSrmdqfHrj1OCaRE7roJBtevoURKKh4F07VlVs4QsWOgJljOaS8zKH
         gYyVHE86z8+F5DNa6Z31EeBkzqIm+LDe7pVBT1p1oTLgrkCFcL5Twe6wsfukN7tFRtjL
         yQUgnKkvjplDG1zW4z+DYiWWntuHiITR3NWbQJaM7GoVW6M4qkLOLXMz1npX51tVzv04
         L+Yk4NTCP6RBuztqt4FdEqDkwqgfF0gMyaKkj9zQIeEaCl+7O2crEenWScYrAONmCfW9
         R7zw==
X-Gm-Message-State: APjAAAWgUPqXkyVthYcY6YsdKmUcZ585FELo2djoZAThidi4TP6YuFzL
	EQ19g3ngPHAnESdUX1R3lEKHhUU0LWfQHIq9XjnBTqvUvMFA2+YuG9cx1z60cAvECD15hCkj6uE
	6X40Mo9QhWsEnnC3LNGhEPjLgpmVw1Os6R0oYvHsV5gzIT0Vcp7FJ5Rp3jqgQmGJZIA==
X-Received: by 2002:a81:66c2:: with SMTP id a185mr18410733ywc.240.1557870298735;
        Tue, 14 May 2019 14:44:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyG/luTKEW7UVHdQJX1fcUdJcz9RG0up2pkKI6cXbusw4m3CFOIpvy0zoBg10FgCoN6MVEC
X-Received: by 2002:a81:66c2:: with SMTP id a185mr18410707ywc.240.1557870298060;
        Tue, 14 May 2019 14:44:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870298; cv=none;
        d=google.com; s=arc-20160816;
        b=m/ELwqd8JemHxvBT9lDP0PV73omFzwNgLaa1FUedrgHHGK62IOnr3i26PqqJWdcZZ5
         CZoR7GAIyQFvEaGYpfEN/2wxCdVN+mNfR14YR1TQEapOdEkhH9JWh++xqjnTKCmlsdJX
         iW4GfeQxAqTSg9mAtwWvdJD1TV9FLrB4+Fo4lNcagpXz4yhPUjK+H7Jb9ruMpc+6JdEn
         ELaTdMsM3wedmmMnv0Gd6e+sEb0Xa0sulPJyQtCRQTh3RtnIeEst4scZpi6ndb4u6NaK
         e97A6stf6nGzZOdSqrypB0CaILjJAlnYU1x4wPMmQ4RajAWj7rwk9j/raEl/5NKzkYJW
         lJ5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Gl8pp3KYsdZV699fGKd7n8I36sqXFKD3Pr1ctINiCIU=;
        b=E4Vcb3wCI5WNccW8gYXDfTofiKvdZoYqH3kqpTG6QobADb1vlrGlcvWoY2+wBLHiQu
         T/VOtLv2+reG959iYV9HSh7G7i7xsxUIpo5RYWqHU9yn581LdoCTws5KBnMiv2ndHGYs
         1Cl/2EV6cfOgfolVnnS52uLtLFx3xZlUa6jhWW1pkNSTE7HhJsW63CBGxupQDhgJ+Y3y
         xi1JuMtI9zUXJQ/1qpwMJtEcMLV4+cB/wEspaXOozo8ek+dSUsbxu9rN108pDJGmhVnp
         ha+fD4yuUkxnHJ761oY6sFjKDYI3JSg/UquBb0+nNY1ECT0TFvL5oTvW9b6jzF3dnIws
         /iRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="hAHz+/8G";
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x3si4735686yba.15.2019.05.14.14.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:44:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="hAHz+/8G";
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4ELe6qR008329
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:44:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Gl8pp3KYsdZV699fGKd7n8I36sqXFKD3Pr1ctINiCIU=;
 b=hAHz+/8GBdJiBTsRVJsNZ0hxFyU0ZuVtO1tGb2HkW0JktCZ3Sp1osTJGPRmSryua6JY4
 nF5H4VquEQ2KixfyLKOyxPe/ZRg3NgR6kqqFuao7dv47vuyl2bV+xuFQDf7HbWfEEulZ
 C/fuyiLFSHEqHFAzgDPnthHAngR+gU1X4Bk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2sfv362atf-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:44:57 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 14 May 2019 14:44:54 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 780BA1207729F; Tue, 14 May 2019 14:39:41 -0700 (PDT)
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
Subject: [PATCH v4 1/7] mm: postpone kmem_cache memcg pointer initialization to memcg_link_cache()
Date: Tue, 14 May 2019 14:39:34 -0700
Message-ID: <20190514213940.2405198-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514213940.2405198-1-guro@fb.com>
References: <20190514213940.2405198-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Initialize kmem_cache->memcg_params.memcg pointer in
memcg_link_cache() rather than in init_memcg_params().

Once kmem_cache will hold a reference to the memory cgroup,
it will simplify the refcounting.

For non-root kmem_caches memcg_link_cache() is always called
before the kmem_cache becomes visible to a user, so it's safe.

Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---
 mm/slab.c        |  2 +-
 mm/slab.h        |  5 +++--
 mm/slab_common.c | 14 +++++++-------
 mm/slub.c        |  2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2915d912e89a..f6eff59e018e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1268,7 +1268,7 @@ void __init kmem_cache_init(void)
 				  nr_node_ids * sizeof(struct kmem_cache_node *),
 				  SLAB_HWCACHE_ALIGN, 0, 0);
 	list_add(&kmem_cache->list, &slab_caches);
-	memcg_link_cache(kmem_cache);
+	memcg_link_cache(kmem_cache, NULL);
 	slab_state = PARTIAL;
 
 	/*
diff --git a/mm/slab.h b/mm/slab.h
index 43ac818b8592..6a562ca72bca 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -289,7 +289,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
-extern void memcg_link_cache(struct kmem_cache *s);
+extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
 
@@ -344,7 +344,8 @@ static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
 
-static inline void memcg_link_cache(struct kmem_cache *s)
+static inline void memcg_link_cache(struct kmem_cache *s,
+				    struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..6e00bdf8618d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -140,13 +140,12 @@ void slab_init_memcg_params(struct kmem_cache *s)
 }
 
 static int init_memcg_params(struct kmem_cache *s,
-		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+			     struct kmem_cache *root_cache)
 {
 	struct memcg_cache_array *arr;
 
 	if (root_cache) {
 		s->memcg_params.root_cache = root_cache;
-		s->memcg_params.memcg = memcg;
 		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
 		return 0;
@@ -221,11 +220,12 @@ int memcg_update_all_caches(int num_memcgs)
 	return ret;
 }
 
-void memcg_link_cache(struct kmem_cache *s)
+void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 {
 	if (is_root_cache(s)) {
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
+		s->memcg_params.memcg = memcg;
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
 		list_add(&s->memcg_params.kmem_caches_node,
@@ -244,7 +244,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 }
 #else
 static inline int init_memcg_params(struct kmem_cache *s,
-		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+				    struct kmem_cache *root_cache)
 {
 	return 0;
 }
@@ -384,7 +384,7 @@ static struct kmem_cache *create_cache(const char *name,
 	s->useroffset = useroffset;
 	s->usersize = usersize;
 
-	err = init_memcg_params(s, memcg, root_cache);
+	err = init_memcg_params(s, root_cache);
 	if (err)
 		goto out_free_cache;
 
@@ -394,7 +394,7 @@ static struct kmem_cache *create_cache(const char *name,
 
 	s->refcount = 1;
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, memcg);
 out:
 	if (err)
 		return ERR_PTR(err);
@@ -997,7 +997,7 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 
 	create_boot_cache(s, name, size, flags, useroffset, usersize);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	s->refcount = 1;
 	return s;
 }
diff --git a/mm/slub.c b/mm/slub.c
index cd04dbd2b5d0..c5646cb02055 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4215,7 +4215,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	}
 	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
-	memcg_link_cache(s);
+	memcg_link_cache(s, NULL);
 	return s;
 }
 
-- 
2.20.1

