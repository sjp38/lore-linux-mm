Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 544A96B00AA
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 07:48:01 -0500 (EST)
Received: by wgbdr13 with SMTP id dr13so1161269wgb.26
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:47:59 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 17 Jan 2012 20:47:59 +0800
Message-ID: <CAJd=RBBdDriMhfetM2AWGzgxiJ1DDs-W4Ff9_1Z8DUgbyQmSkA@mail.gmail.com>
Subject: [PATCH] mm: memcg: remove checking reclaim order in soft limit reclaim
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

If async order-O reclaim expected here, it is settled down when setting up scan
control, with scan priority hacked to be zero. Other than that, deny of reclaim
should be removed.


Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/memcontrol.c	Tue Jan 17 20:41:36 2012
+++ b/mm/memcontrol.c	Tue Jan 17 20:47:48 2012
@@ -3512,9 +3512,6 @@ unsigned long mem_cgroup_soft_limit_recl
 	unsigned long long excess;
 	unsigned long nr_scanned;

-	if (order > 0)
-		return 0;
-
 	mctz = soft_limit_tree_node_zone(zone_to_nid(zone), zone_idx(zone));
 	/*
 	 * This loop can run a while, specially if mem_cgroup's continuously

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
