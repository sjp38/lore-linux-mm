Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE4526B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 21:14:09 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so5704739wid.0
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 18:14:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ki1si22556535wjc.118.2015.01.09.18.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jan 2015 18:14:09 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: memcontrol: remove unnecessary soft limit tree node test
Date: Fri,  9 Jan 2015 21:13:59 -0500
Message-Id: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

kzalloc_node() automatically falls back to nodes with suitable memory.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fd9e542fc26f..aad254b30708 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4520,13 +4520,10 @@ static void __init mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
 	struct mem_cgroup_tree_per_zone *rtpz;
-	int tmp, node, zone;
+	int node, zone;
 
 	for_each_node(node) {
-		tmp = node;
-		if (!node_state(node, N_NORMAL_MEMORY))
-			tmp = -1;
-		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
+		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
 		BUG_ON(!rtpn);
 
 		soft_limit_tree.rb_tree_per_node[node] = rtpn;
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
