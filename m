Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3329F6B00FB
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:23:41 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n269NYH1032503
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 14:53:34 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n269KV8w4329626
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 14:50:31 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n269NXng032226
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 20:23:34 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 06 Mar 2009 14:53:30 +0530
Message-Id: <20090306092330.21063.2864.sendpatchset@localhost.localdomain>
In-Reply-To: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/4] Memory controller soft limit documentation (v4)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Add documentation for soft limits

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
