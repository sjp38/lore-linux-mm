Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 49C936B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 23:45:19 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so16754238pbb.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 20:45:18 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: add BUG() to mem_cgroup_reset
Date: Fri,  6 Jul 2012 11:44:57 +0800
Message-Id: <1341546297-6223-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Branch in mem_cgroup_reset only can be RES_MAX_USAGE, RES_FAILCNT.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a501660..5e4d1ab 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3976,6 +3976,8 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 		else
 			res_counter_reset_failcnt(&memcg->memsw);
 		break;
+	default:
+		BUG();
 	}
 
 	return 0;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
