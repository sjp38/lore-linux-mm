Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id EECB16B0035
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 03:15:49 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id q8so148019lbi.26
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 00:15:49 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id d9si2323408lad.90.2013.12.14.00.15.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Dec 2013 00:15:48 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/2] memcg: fix memcg_size() calculation
Date: Sat, 14 Dec 2013 12:15:33 +0400
Message-ID: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The mem_cgroup structure contains nr_node_ids pointers to
mem_cgroup_per_node objects, not the objects themselves.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bf5e894..7f1a356 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -338,7 +338,7 @@ struct mem_cgroup {
 static size_t memcg_size(void)
 {
 	return sizeof(struct mem_cgroup) +
-		nr_node_ids * sizeof(struct mem_cgroup_per_node);
+		nr_node_ids * sizeof(struct mem_cgroup_per_node *);
 }
 
 /* internal only representation about the status of kmem accounting. */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
