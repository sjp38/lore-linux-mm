Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id BD0806B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 02:29:27 -0400 (EDT)
Received: by obhx4 with SMTP id x4so10533092obh.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 23:29:26 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: replace inexistence move_lock_page_cgroup() by move_lock_mem_cgroup() in comment
Date: Thu,  5 Jul 2012 14:28:53 +0800
Message-Id: <1341469733-12104-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <a>
References: <a>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3d318f6..63e36e7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1899,7 +1899,7 @@ again:
 		return;
 	/*
 	 * If this memory cgroup is not under account moving, we don't
-	 * need to take move_lock_page_cgroup(). Because we already hold
+	 * need to take move_lock_mem_cgroup(). Because we already hold
 	 * rcu_read_lock(), any calls to move_account will be delayed until
 	 * rcu_read_unlock() if mem_cgroup_stolen() == true.
 	 */
@@ -1921,7 +1921,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 	/*
 	 * It's guaranteed that pc->mem_cgroup never changes while
 	 * lock is held because a routine modifies pc->mem_cgroup
-	 * should take move_lock_page_cgroup().
+	 * should take move_lock_mem_cgroup().
 	 */
 	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
