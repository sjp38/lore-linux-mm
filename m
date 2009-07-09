Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B82016B005C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:57:11 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n69HF2vJ022554
	for <linux-mm@kvack.org>; Thu, 9 Jul 2009 22:45:02 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69HEovT995530
	for <linux-mm@kvack.org>; Thu, 9 Jul 2009 22:44:52 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n69HEoB1004865
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:14:50 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 09 Jul 2009 22:44:49 +0530
Message-Id: <20090709171449.8080.40970.sendpatchset@balbir-laptop>
In-Reply-To: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
Subject: [RFC][PATCH 1/5] Memory controller soft limit documentation (v8)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Add documentation for soft limits

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/cgroups/memory.txt |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)


diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ab0a021..b47815c 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -379,7 +379,36 @@ cgroups created below it.
 
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
+When the system detects memory contention or low memory control groups
+are pushed back to their soft limits. If the soft limit of each control
+group is very high, they are pushed back as much as possible to make
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
+NOTE1: Soft limits take effect over a long period of time, since they involve
+       reclaiming memory for balancing between memory cgroups
+NOTE2: It is recommended to set the soft limit always below the hard limit,
+       otherwise the hard limit will take precedence.
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
