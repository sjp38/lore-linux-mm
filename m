Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 22B9C6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:10:13 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3109992pab.20
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:10:12 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id yy4si4812736pbc.279.2014.02.07.04.10.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:10:11 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3083092pde.20
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:10:10 -0800 (PST)
Date: Fri, 7 Feb 2014 17:40:06 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 6/9] mm: Mark function as static in memcontrol.c
Message-ID: <0dbbc0fe4360069993ef8a9ca179f30482610270.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, josh@joshtriplett.org

Mark function as static in memcontrol.c because it is not used outside
this file.

This also eliminates the following warning in memcontrol.c:
mm/memcontrol.c:3089:5: warning: no previous prototype for a??memcg_update_cache_sizesa?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bf5e894..fbec2a5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3086,7 +3086,7 @@ int memcg_cache_id(struct mem_cgroup *memcg)
  * But when we create a new cache, we can call this as well if its parent
  * is kmem-limited. That will have to hold set_limit_mutex as well.
  */
-int memcg_update_cache_sizes(struct mem_cgroup *memcg)
+static int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 {
 	int num, ret;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
