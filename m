Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E48796B004F
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 06:09:04 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id n1GB7KDJ016266
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:07:20 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1GB8rhI381414
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:08:55 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1GB8qaa027726
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 22:08:53 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 16 Feb 2009 16:38:49 +0530
Message-Id: <20090216110849.29795.65329.sendpatchset@localhost.localdomain>
In-Reply-To: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 1/4] Memory controller soft limit documentation (v2)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add documentation for soft limit feature support.

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/cgroups/memory.txt |   28 +++++++++++++++++++++++++++-
 1 files changed, 27 insertions(+), 1 deletions(-)


diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index a98a7fe..6e6ef41 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -360,7 +360,33 @@ cgroups created below it.
 
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
+When the system detects memory contention (through do_try_to_free_pages(),
+while allocating), control groups are pushed back to their soft limits if
+possible. If the soft limit of each control group is very high, they are
+pushed back as much as possible to make sure that one control group does not
+starve the others.
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
