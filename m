Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AB3446B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 10:13:45 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id e21so2876574fga.8
        for <linux-mm@kvack.org>; Fri, 08 Jan 2010 07:13:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] memcg: typo in comment to mem_cgroup_print_oom_info()
Date: Fri,  8 Jan 2010 17:13:23 +0200
Message-Id: <1262963603-21908-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: Andrew@kvack.org, "Morton <akpm"@linux-foundation.org
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

s/mem_cgroup_print_mem_info/mem_cgroup_print_oom_info/

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4572907..0d78570 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1070,7 +1070,7 @@ static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
 }
 
 /**
- * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in read mode.
+ * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
