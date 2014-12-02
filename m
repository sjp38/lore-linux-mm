Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9096B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 06:07:56 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so27629953wiw.13
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 03:07:55 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id bs2si34608973wjc.34.2014.12.02.03.07.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 03:07:55 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id r20so20547488wiv.14
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 03:07:55 -0800 (PST)
Date: Tue, 2 Dec 2014 12:07:52 +0100
From: Michele Curti <michele.curti@gmail.com>
Subject: [PATCH] mm/memcontrol: fix defined but not used compiler warning
Message-ID: <20141202110752.GA11327@powerline.azcom-win.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

test_mem_cgroup_node_reclaimable is used only when MAX_NUMNODES > 1,
so move it into the compiler if statement

Signed-off-by: Michele Curti <michele.curti@gmail.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6ac50e..84531a9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1615,6 +1615,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
 			 NULL, "Memory cgroup out of memory");
 }
+#if MAX_NUMNODES > 1
 
 /**
  * test_mem_cgroup_node_reclaimable
@@ -1638,7 +1639,6 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 	return false;
 
 }
-#if MAX_NUMNODES > 1
 
 /*
  * Always updating the nodemask is not very good - even if we have an empty
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
