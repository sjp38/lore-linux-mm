Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A57686B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:56:24 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2CHuI6B018998
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:26:18 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CHr6xs3629110
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:23:06 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2CHuHDT031640
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 23:26:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 12 Mar 2009 23:26:09 +0530
Message-Id: <20090312175609.17890.58677.sendpatchset@localhost.localdomain>
In-Reply-To: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/4] Memory controller soft limit documentation (v5)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Feature: Add documentation for soft limits

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/cgroups/memory.txt |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)


diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index a98a7fe..c5f73d9 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -360,7 +360,36 @@ cgroups created below it.
 
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
