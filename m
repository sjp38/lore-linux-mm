Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 398DE6B02EB
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:45:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so122456059pgq.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:45:27 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e69si28616967pfk.231.2016.11.15.15.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:45:25 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x23so12965797pgx.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:45:25 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RESEND] [PATCH v1 3/3] powerpc: fix node_possible_map limitations
Date: Wed, 16 Nov 2016 10:45:01 +1100
Message-Id: <1479253501-26261-4-git-send-email-bsingharora@gmail.com>
In-Reply-To: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

We've fixed the memory hotplug issue with memcg, hence
this work around should not be required.

Reverts: commit 3af229f2071f
("powerpc/numa: Reset node_possible_map to only node_online_map")

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org> 
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Balbir Singh <bsingharora@gmail.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>

---
 arch/powerpc/mm/numa.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index a51c188..ca8c2ab 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -916,13 +916,6 @@ void __init initmem_init(void)
 
 	memblock_dump_all();
 
-	/*
-	 * Reduce the possible NUMA nodes to the online NUMA nodes,
-	 * since we do not support node hotplug. This ensures that  we
-	 * lower the maximum NUMA node ID to what is actually present.
-	 */
-	nodes_and(node_possible_map, node_possible_map, node_online_map);
-
 	for_each_online_node(nid) {
 		unsigned long start_pfn, end_pfn;
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
