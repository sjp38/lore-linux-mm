Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 67DB96B0096
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 01:30:14 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n216U7IY028734
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 12:00:07 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n216UET83436624
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 12:00:14 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n216U6VE013632
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 17:30:06 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 01 Mar 2009 12:00:05 +0530
Message-Id: <20090301063005.31557.1071.sendpatchset@localhost.localdomain>
In-Reply-To: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/4] Memory controller soft limit documentation (v3)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add documentation for soft limit feature support.

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/cgroups/memory.txt |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)


diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index a98a7fe..812cb74 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -360,7 +360,32 @@ cgroups created below it.
 
 NOTE2: This feature can be enabled/disabled per subtree.
 
-7. TODO
+7. Soft limits
+
+Soft limits allow for greater sharing of memory. The idea behind soft limits
+is to allow control groups to use as much of the memory as needed, provided
+
+a. There is no memory contention
+b. They do not exceed their hard limit
+
+When the system detects memory contention or low memory (kswapd is woken up)
+control groups are pushed back to their soft limits. If the soft limit of each
+control group is very high, they are pushed back as much as possible to make
+sure that one control group does not starve the others of memory.
+
+7.1 Interface
+
+Soft limits can be setup by using the following commands (in this example we
+assume a soft limit of 256 megabytes)
+
+# echo 256M > memory.soft_limit_in_bytes
+
+If we want to change this to 1G, we can at any time use
+
+# echo 1G > memory.soft_limit_in_bytes
+
+
+8. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
