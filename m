Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8776960021B
	for <linux-mm@kvack.org>; Sat, 26 Dec 2009 14:31:12 -0500 (EST)
Received: by fxm28 with SMTP id 28so779801fxm.6
        for <linux-mm@kvack.org>; Sat, 26 Dec 2009 11:31:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] [TRIVIAL] memcg: typo in comment to mem_cgroup_print_oom_info()
Date: Sat, 26 Dec 2009 21:31:01 +0200
Message-Id: <1261855861-3204-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

s/mem_cgroup_print_mem_info/mem_cgroup_print_oom_info/

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 488b644..cebe6b9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1000,7 +1000,7 @@ static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
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
