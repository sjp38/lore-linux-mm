Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9144F6B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 21:37:26 -0500 (EST)
Received: by pwi1 with SMTP id 1so18292pwi.6
        for <linux-mm@kvack.org>; Sun, 06 Dec 2009 18:37:24 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 7 Dec 2009 10:37:24 +0800
Message-ID: <cf18f8340912061837j16c9aa25vc6af8a4a1fce989c@mail.gmail.com>
Subject: [PATCH] memcg: code clean,rm unused variable in mem_cgroup_resize_limit
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Variable progress isn't used in funtion mem_cgroup_resize_limit anymore.
Remove it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 984cf27..9d4776e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2100,7 +2100,6 @@ static int mem_cgroup_resize_limit(struct
mem_cgroup *memcg,
 				unsigned long long val)
 {
 	int retry_count;
-	int progress;
 	u64 memswlimit;
 	int ret = 0;
 	int children = mem_cgroup_count_children(memcg);
@@ -2144,7 +2143,7 @@ static int mem_cgroup_resize_limit(struct
mem_cgroup *memcg,
 		if (!ret)
 			break;

-		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
+		mem_cgroup_hierarchical_reclaim(memcg, NULL,
 						GFP_KERNEL,
 						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
