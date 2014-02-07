Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3746B0038
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:11:41 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so3077277pdj.2
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:11:40 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id yy4si4840219pbc.189.2014.02.07.04.11.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:11:39 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3084464pde.20
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:11:38 -0800 (PST)
Date: Fri, 7 Feb 2014 17:41:34 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 7/9] mm: Mark functions as static in page_cgroup.c
Message-ID: <6054d570fc83c3d4f3de240d6da488f876e21450.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, josh@joshtriplett.org

Mark functions as static in page_cgroup.c because they are not used
outside this file.

This eliminates the following warning in mm/page_cgroup.c:
mm/page_cgroup.c:177:6: warning: no previous prototype for a??__free_page_cgroupa?? [-Wmissing-prototypes]
mm/page_cgroup.c:190:15: warning: no previous prototype for a??online_page_cgroupa?? [-Wmissing-prototypes]
mm/page_cgroup.c:225:15: warning: no previous prototype for a??offline_page_cgroupa?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/page_cgroup.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 6d757e3a..6ec349c 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -174,7 +174,7 @@ static void free_page_cgroup(void *addr)
 	}
 }
 
-void __free_page_cgroup(unsigned long pfn)
+static void __free_page_cgroup(unsigned long pfn)
 {
 	struct mem_section *ms;
 	struct page_cgroup *base;
@@ -187,9 +187,9 @@ void __free_page_cgroup(unsigned long pfn)
 	ms->page_cgroup = NULL;
 }
 
-int __meminit online_page_cgroup(unsigned long start_pfn,
-			unsigned long nr_pages,
-			int nid)
+static int __meminit online_page_cgroup(unsigned long start_pfn,
+				unsigned long nr_pages,
+				int nid)
 {
 	unsigned long start, end, pfn;
 	int fail = 0;
@@ -222,8 +222,8 @@ int __meminit online_page_cgroup(unsigned long start_pfn,
 	return -ENOMEM;
 }
 
-int __meminit offline_page_cgroup(unsigned long start_pfn,
-		unsigned long nr_pages, int nid)
+static int __meminit offline_page_cgroup(unsigned long start_pfn,
+				unsigned long nr_pages, int nid)
 {
 	unsigned long start, end, pfn;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
