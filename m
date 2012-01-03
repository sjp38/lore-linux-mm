Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 678936B00B1
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 18:34:03 -0500 (EST)
Received: by yhgm50 with SMTP id m50so9504223yhg.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 15:34:02 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 2/2] memcg: mark rcu protected member as __rcu
Date: Tue,  3 Jan 2012 18:33:52 -0500
Message-Id: <1325633632-9978-2-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1325633632-9978-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1325633632-9978-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Currently "make C=2 mm/memcontrol.o" makes following warnings. fix it.

mm/memcontrol.c:4243:21: error: incompatible types in comparison expression (different address spaces)
mm/memcontrol.c:4245:21: error: incompatible types in comparison expression (different address spaces)

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6adeeec..138be2b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -195,7 +195,7 @@ struct mem_cgroup_threshold_ary {
 
 struct mem_cgroup_thresholds {
 	/* Primary thresholds array */
-	struct mem_cgroup_threshold_ary *primary;
+	struct mem_cgroup_threshold_ary __rcu *primary;
 	/*
 	 * Spare threshold array.
 	 * This is needed to make mem_cgroup_unregister_event() "never fail".
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
