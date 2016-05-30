Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0D3E6B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:46:04 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id yu3so276394400obb.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:46:04 -0700 (PDT)
Received: from m50-133.163.com (m50-133.163.com. [123.125.50.133])
        by mx.google.com with ESMTP id h206si20652076oif.189.2016.05.30.01.46.02
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 01:46:04 -0700 (PDT)
From: Wenwei Tao <wwtao0320@163.com>
Subject: [PATCH] mm/memcontrol.c: add memory allocation result check
Date: Mon, 30 May 2016 16:45:51 +0800
Message-Id: <1464597951-2976-1-git-send-email-wwtao0320@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ww.tao0320@gmail.com

From: Wenwei Tao <ww.tao0320@gmail.com>

The mem_cgroup_tree_per_node allocation might fail,
check that before continue the memcg init. Since it
is in the init phase, trigger the panic if that failure
happens.

Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
---
 mm/memcontrol.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 925b431..6385c62 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5712,6 +5712,7 @@ static int __init mem_cgroup_init(void)
 
 		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
 				    node_online(node) ? node : NUMA_NO_NODE);
+		BUG_ON(!rtpn);
 
 		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 			struct mem_cgroup_tree_per_zone *rtpz;
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
