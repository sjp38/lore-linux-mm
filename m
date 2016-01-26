Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 798D96B0256
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:56:16 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id r129so121120973wmr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:56:16 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hp6si104833wjb.162.2016.01.26.12.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 12:56:15 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: drop superfluous entry in the per-memcg stats array
Date: Tue, 26 Jan 2016 15:55:29 -0500
Message-Id: <1453841729-29072-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

MEM_CGROUP_STAT_NSTATS is just a delimiter for cgroup1 statistics, not
an actual array entry. Reuse it for the first cgroup2 stat entry, like
in the event array.

Fixes: b2807f07f4f8 ("mm: memcontrol: add "sock" to cgroup2 memory.stat")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9ae48d4aeb5e..792c8981e633 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -51,7 +51,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 	/* default hierarchy stats */
-	MEMCG_SOCK,
+	MEMCG_SOCK = MEM_CGROUP_STAT_NSTATS,
 	MEMCG_NR_STAT,
 };
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
