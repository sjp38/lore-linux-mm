Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42D6B8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 19:22:44 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x67so11810249pfk.16
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 16:22:44 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id b3si10260947pgc.587.2019.01.04.16.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 16:22:43 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH 1/5] doc: memcontrol: fix the obsolete content about force empty
Date: Sat,  5 Jan 2019 08:19:16 +0800
Message-Id: <1546647560-40026-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We don't do page cache reparent anymore when offlining memcg, so update
force empty related content accordingly.

Reviewed-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/cgroup-v1/memory.txt | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index 3682e99..8e2cb1d 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -70,7 +70,7 @@ Brief summary of control files.
  memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
  memory.stat			 # show various statistics
  memory.use_hierarchy		 # set/show hierarchical account enabled
- memory.force_empty		 # trigger forced move charge to parent
+ memory.force_empty		 # trigger forced page reclaim
  memory.pressure_level		 # set memory pressure notifications
  memory.swappiness		 # set/show swappiness parameter of vmscan
 				 (See sysctl's vm.swappiness)
@@ -459,8 +459,9 @@ About use_hierarchy, see Section 6.
   the cgroup will be reclaimed and as many pages reclaimed as possible.
 
   The typical use case for this interface is before calling rmdir().
-  Because rmdir() moves all pages to parent, some out-of-use page caches can be
-  moved to the parent. If you want to avoid that, force_empty will be useful.
+  Though rmdir() offlines memcg, but the memcg may still stay there due to
+  charged file caches. Some out-of-use page caches may keep charged until
+  memory pressure happens. If you want to avoid that, force_empty will be useful.
 
   Also, note that when memory.kmem.limit_in_bytes is set the charges due to
   kernel pages will still be seen. This is not considered a failure and the
-- 
1.8.3.1
