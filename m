Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 72C046B0069
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 22:00:27 -0500 (EST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 4/6] memcg: mark stat field of mem_cgroup struct as __percpu
Date: Sat, 24 Dec 2011 05:00:17 +0200
Message-Id: <1324695619-5537-4-git-send-email-kirill@shutemov.name>
In-Reply-To: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

It fixes a lot of sparse warnings.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 627c19e..b27ce0f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -291,7 +291,7 @@ struct mem_cgroup {
 	/*
 	 * percpu counter.
 	 */
-	struct mem_cgroup_stat_cpu *stat;
+	struct mem_cgroup_stat_cpu __percpu *stat;
 	/*
 	 * used when a cpu is offlined or other synchronizations
 	 * See mem_cgroup_read_stat().
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
