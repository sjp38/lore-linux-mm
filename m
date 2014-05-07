Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BD01C6B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 04:27:45 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so864970pab.1
        for <linux-mm@kvack.org>; Wed, 07 May 2014 01:27:45 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id gr5si1692547pac.114.2014.05.07.01.27.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 May 2014 01:27:44 -0700 (PDT)
Message-ID: <5369EE61.1040003@huawei.com>
Date: Wed, 7 May 2014 16:27:13 +0800
From: Qiang Huang <h.huangqiang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] memcg: correct comments for __mem_cgroup_begin_update_page_stat
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>


Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 mm/memcontrol.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5804d71..f96e68e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2251,12 +2251,11 @@ cleanup:
 }

 /*
- * Currently used to update mapped file statistics, but the routine can be
- * generalized to update other statistics as well.
+ * Used to update mapped file or writeback or other statistics.
  *
  * Notes: Race condition
  *
- * We usually use page_cgroup_lock() for accessing page_cgroup member but
+ * We usually use lock_page_cgroup() for accessing page_cgroup member but
  * it tends to be costly. But considering some conditions, we doesn't need
  * to do so _always_.
  *
@@ -2270,8 +2269,8 @@ cleanup:
  * by flags.
  *
  * Considering "move", this is an only case we see a race. To make the race
- * small, we check mm->moving_account and detect there are possibility of race
- * If there is, we take a lock.
+ * small, we check memcg->moving_account and detect there are possibility
+ * of race or not. If there is, we take a lock.
  */

 void __mem_cgroup_begin_update_page_stat(struct page *page,
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
