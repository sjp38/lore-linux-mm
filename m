Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 026546B0260
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:44:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so86148445pgc.2
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:44:27 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id tx6si20099300pab.295.2016.11.14.15.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 15:44:27 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id i88so6817321pfk.2
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:44:27 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v1 3/3] powerpc: fix node_possible_map limitations
Date: Tue, 15 Nov 2016 10:44:05 +1100
Message-Id: <1479167045-28136-4-git-send-email-bsingharora@gmail.com>
In-Reply-To: <1479167045-28136-1-git-send-email-bsingharora@gmail.com>
References: <1479167045-28136-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, akpm@linux-foundation.org, tj@kernel.org, Balbir Singh <bsingharora@gmail.com>

We've fixed the memory hotplug issue with memcg, hence
this work around should not be required.

Fixes: commit 3af229f2071f
("powerpc/numa: Reset node_possible_map to only node_online_map")

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
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
