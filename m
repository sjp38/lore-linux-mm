Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A0B4D6B003B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 04:22:11 -0400 (EDT)
Message-ID: <51627E09.5010605@huawei.com>
Date: Mon, 8 Apr 2013 16:21:29 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 4/8] memcg: convert to use cgroup_from_id()
References: <51627DA9.7020507@huawei.com>
In-Reply-To: <51627DA9.7020507@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

This is a preparation to kill css_id.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14f1375..3561d0b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2769,15 +2769,15 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
  */
 static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 {
-	struct cgroup_subsys_state *css;
+	struct cgroup *cgrp;
 
 	/* ID 0 is unused ID */
 	if (!id)
 		return NULL;
-	css = css_lookup(&mem_cgroup_subsys, id);
-	if (!css)
+	cgrp = cgroup_from_id(&mem_cgroup_subsys, id);
+	if (!cgrp)
 		return NULL;
-	return mem_cgroup_from_css(css);
+	return mem_cgroup_from_cont(cgrp);
 }
 
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
