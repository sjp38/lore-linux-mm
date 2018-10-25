Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7C86B027D
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:45:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id k12-v6so4809418plt.0
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 02:45:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8-v6sor7022647pgp.61.2018.10.25.02.45.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 02:45:45 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 3/3] mm, slub: make the comment of put_cpu_partial() complete
Date: Thu, 25 Oct 2018 17:44:37 +0800
Message-Id: <20181025094437.18951-3-richard.weiyang@gmail.com>
In-Reply-To: <20181025094437.18951-1-richard.weiyang@gmail.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

There are two cases when put_cpu_partial() is invoked.

    * __slab_free
    * get_partial_node

This patch just makes it cover these two cases and fix one typo in
slub_def.h.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3a1a1dbc6f49..201a635be846 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -81,7 +81,7 @@ struct kmem_cache_order_objects {
  */
 struct kmem_cache {
 	struct kmem_cache_cpu __percpu *cpu_slab;
-	/* Used for retriving partial slabs etc */
+	/* Used for retrieving partial slabs etc */
 	slab_flags_t flags;
 	unsigned long min_partial;
 	unsigned int size;	/* The size of an object including meta data */
diff --git a/mm/slub.c b/mm/slub.c
index 715372a786e3..3db6ce58e92e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2201,8 +2201,8 @@ static void unfreeze_partials(struct kmem_cache *s,
 }
 
 /*
- * Put a page that was just frozen (in __slab_free) into a partial page
- * slot if available.
+ * Put a page that was just frozen (in __slab_free|get_partial_node) into a
+ * partial page slot if available.
  *
  * If we did not find a slot then simply move all the partials to the
  * per node partial list.
-- 
2.15.1
