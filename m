Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 72DDC6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 23:29:42 -0400 (EDT)
Message-ID: <5195A41D.7050507@huawei.com>
Date: Fri, 17 May 2013 11:29:33 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: update TODO list in Documentation
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

hugetlb cgroup has already been implemented.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 Documentation/cgroups/memory.txt | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..327acec 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -834,10 +834,9 @@ Test:
 
 12. TODO
 
-1. Add support for accounting huge pages (as a separate controller)
-2. Make per-cgroup scanner reclaim not-shared pages first
-3. Teach controller to account for shared-pages
-4. Start reclamation in the background when the limit is
+1. Make per-cgroup scanner reclaim not-shared pages first
+2. Teach controller to account for shared-pages
+3. Start reclamation in the background when the limit is
    not yet hit but the usage is getting closer
 
 Summary
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
