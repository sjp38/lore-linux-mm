Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD7786B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 04:26:54 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i205so8415438ita.3
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 01:26:54 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 36si917134ioh.299.2018.03.12.01.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 01:26:53 -0700 (PDT)
From: Honglei Wang <honglei.wang@oracle.com>
Subject: [PATCH V2] mm/memcontrol.c: fix parameter description mismatch
Date: Mon, 12 Mar 2018 16:30:48 +0800
Message-Id: <1520843448-17347-1-git-send-email-honglei.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com

There are a couple of places where parameter description and function name
do not match the actual code. Fix it.

Signed-off-by: Honglei Wang <honglei.wang@oracle.com>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 670e99b..9ec024b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -714,9 +714,9 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
  * invocations for reference counting, or use mem_cgroup_iter_break()
  * to cancel a hierarchy walk before the round-trip is complete.
  *
- * Reclaimers can specify a zone and a priority level in @reclaim to
+ * Reclaimers can specify a node and a priority level in @reclaim to
  * divide up the memcgs in the hierarchy among all concurrent
- * reclaimers operating on the same zone and priority.
+ * reclaimers operating on the same node and priority.
  */
 struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
@@ -2299,7 +2299,7 @@ void memcg_kmem_put_cache(struct kmem_cache *cachep)
 }
 
 /**
- * memcg_kmem_charge: charge a kmem page
+ * memcg_kmem_charge_memcg: charge a kmem page
  * @page: page to charge
  * @gfp: reclaim mode
  * @order: allocation order
-- 
2.7.4
