Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4C84B6B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 10:39:54 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id s7so1939787lbd.32
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 07:39:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ja7si7262132lbc.28.2014.06.25.07.39.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jun 2014 07:39:52 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] slab: document why cache can have no per cpu array on kfree
Date: Wed, 25 Jun 2014 18:39:37 +0400
Message-ID: <1403707177-3740-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <20140624073840.GC4836@js1304-P5Q-DELUXE>
References: <20140624073840.GC4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 6009e44a4d1d..4cb2619277ff 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3530,6 +3530,10 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 	kmemcheck_slab_free(cachep, objp, cachep->object_size);
 
 #ifdef CONFIG_MEMCG_KMEM
+	/*
+	 * Per cpu arrays are disabled for dead memcg caches in order not to
+	 * prevent self-destruction.
+	 */
 	if (unlikely(!ac)) {
 		int nodeid = page_to_nid(virt_to_page(objp));
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
