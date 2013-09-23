Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id AE6696B0033
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 04:56:33 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so2941981pdj.7
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 01:56:33 -0700 (PDT)
Message-ID: <5240020F.3010008@huawei.com>
Date: Mon, 23 Sep 2013 16:55:43 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v6 1/5] memcg: convert to use cgroup_is_descendant()
References: <524001F8.6070205@huawei.com>
In-Reply-To: <524001F8.6070205@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is a preparation to kill css_id.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7dda769..9117249 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1405,7 +1405,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 		return true;
 	if (!root_memcg->use_hierarchy || !memcg)
 		return false;
-	return css_is_ancestor(&memcg->css, &root_memcg->css);
+	return cgroup_is_descendant(memcg->css.cgroup, root_memcg->css.cgroup);
 }
 
 static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
