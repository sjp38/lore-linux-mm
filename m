Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4ED9Y4c013717
	for <linux-mm@kvack.org>; Wed, 14 May 2008 09:09:34 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4ED9XmG074336
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:09:33 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4ED9XvD008769
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:09:33 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 14 May 2008 18:39:15 +0530
Message-Id: <20080514130915.24440.56106.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 1/4] Add memrlimit controller documentation (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Documentation patch - describes the goals and usage of the memrlimit
controller.


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memrlimit.txt |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff -puN /dev/null Documentation/controllers/memrlimit.txt
--- /dev/null	2008-05-14 04:27:30.032276540 +0530
+++ linux-2.6.26-rc2-balbir/Documentation/controllers/memrlimit.txt	2008-05-14 18:35:55.000000000 +0530
@@ -0,0 +1,29 @@
+This controller is enabled by the CONFIG_CGROUP_MEMRLIMIT_CTLR option. Prior
+to reading this documentation please read Documentation/cgroups.txt and
+Documentation/controllers/memory.txt. Several of the principles of this
+controller are similar to the memory resource controller.
+
+This controller framework is designed to be extensible to control any
+memory resource limit with little effort.
+
+This new controller, controls the address space expansion of the tasks
+belonging to a cgroup. Address space control is provided along the same lines as
+RLIMIT_AS control, which is available via getrlimit(2)/setrlimit(2).
+The interface for controlling address space is provided through
+"rlimit.limit_in_bytes". The file is similar to "limit_in_bytes" w.r.t. the user
+interface. Please see section 3 of the memory resource controller documentation
+for more details on how to use the user interface to get and set values.
+
+The "memrlimit.usage_in_bytes" file provides information about the total address
+space usage of the tasks in the cgroup, in bytes.
+
+Advantages of providing this feature
+
+1. Control over virtual address space allows for a cgroup to fail gracefully
+   i.e., via a malloc or mmap failure as compared to OOM kill when no
+   pages can be reclaimed.
+2. It provides better control over how many pages can be swapped out when
+   the cgroup goes over its limit. A badly setup cgroup can cause excessive
+   swapping. Providing control over the address space allocations ensures
+   that the system administrator has control over the total swapping that
+   can take place.
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
