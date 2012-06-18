Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id ACCF96B004D
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:10:43 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8617706dak.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 06:10:42 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: add unlikely to mercg->move_charge_at_immigrate
Date: Mon, 18 Jun 2012 21:10:21 +0800
Message-Id: <1340025022-7272-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

move_charge_at_immigrate feature is disabled by default. Charges
are moved only when you move mm->owner and it also add additional
overhead.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a9c3d01..795a00f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5316,7 +5316,7 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
 	int ret = 0;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
-	if (memcg->move_charge_at_immigrate) {
+	if (unlikely(memcg->move_charge_at_immigrate)) {
 		struct mm_struct *mm;
 		struct mem_cgroup *from = mem_cgroup_from_task(p);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
