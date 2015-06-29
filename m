Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7796B0070
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 10:13:57 -0400 (EDT)
Received: by igcsj18 with SMTP id sj18so80905834igc.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:13:57 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id b16si12502288icr.6.2015.06.29.07.13.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 07:13:56 -0700 (PDT)
Received: by iebmu5 with SMTP id mu5so115563908ieb.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:13:56 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
Date: Mon, 29 Jun 2015 10:13:53 -0400
Message-Id: <1435587233-27976-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This makes the function alloc_mem_cgroup_per_zone_info have a
return type of bool now due to this particular function always
returning either one or zero as its return value.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c5..35d86d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4425,7 +4425,7 @@ static struct cftype mem_cgroup_legacy_files[] = {
 	{ },	/* terminate */
 };
 
-static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
+static bool alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
@@ -4442,7 +4442,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		tmp = -1;
 	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
 	if (!pn)
-		return 1;
+		return true;
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
@@ -4452,7 +4452,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		mz->memcg = memcg;
 	}
 	memcg->nodeinfo[node] = pn;
-	return 0;
+	return false;
 }
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
