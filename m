Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E044F6B0075
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 05:16:20 -0400 (EDT)
Received: by yenr5 with SMTP id r5so10271713yen.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 02:16:19 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: complete documentation for tcp memcg files
Date: Fri,  6 Jul 2012 17:15:48 +0800
Message-Id: <1341566148-10198-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 Documentation/cgroups/memory.txt |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index dd88540..b388e4a 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -73,6 +73,8 @@ Brief summary of control files.
 
  memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
  memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
+ memory.kmem.tcp.failcnt            # show the number of tcp buf memory usage hits limits
+ memory.kmem.tcp.max_usage_in_bytes # show max tcp buf memory usage recorded
 
 1. History
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
