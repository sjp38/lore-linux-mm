Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C55F66B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:00:52 -0400 (EDT)
Message-ID: <51EFA59B.9070409@huawei.com>
Date: Wed, 24 Jul 2013 17:59:55 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2 2/8] cgroup: document how cgroup IDs are assigned
References: <51EFA554.6080801@huawei.com>
In-Reply-To: <51EFA554.6080801@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

As cgroup id has been used in netprio cgroup and will be used in memcg,
it's important to make it clear how a cgroup id is allocated.

For example, in netprio cgroup, the id is used as index of an array.

Signed-off-by: Li Zefan <lizefan@huwei.com>
---
 include/linux/cgroup.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2bd052d..8c107e9 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -161,7 +161,13 @@ struct cgroup_name {
 struct cgroup {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 
-	int id;				/* idr allocated in-hierarchy ID */
+	/*
+	 * idr allocated in-hierarchy ID.
+	 *
+	 * The ID of the root cgroup is always 0, and a new cgroup
+	 * will be assigned with a smallest available ID.
+	 */
+	int id;
 
 	/*
 	 * We link our 'sibling' struct into our parent's 'children'.
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
