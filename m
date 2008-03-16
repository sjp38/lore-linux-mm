Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2GHVhjb024892
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 13:31:43 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2GHVhUW194034
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:43 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2GHVg22009234
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:43 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Mar 2008 23:00:17 +0530
Message-Id: <20080316173017.8812.41614.sendpatchset@localhost.localdomain>
In-Reply-To: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
Subject: [RFC][3/3] Update documentation for virtual address space control
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch adds documentation for virtual address space control.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memory.txt |   26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff -puN Documentation/controllers/memory.txt~memory-controller-virtual-address-control-documentation Documentation/controllers/memory.txt
--- linux-2.6.25-rc5/Documentation/controllers/memory.txt~memory-controller-virtual-address-control-documentation	2008-03-16 22:57:44.000000000 +0530
+++ linux-2.6.25-rc5-balbir/Documentation/controllers/memory.txt	2008-03-16 22:57:44.000000000 +0530
@@ -237,7 +237,31 @@ cgroup might have some charge associated
 tasks have migrated away from it. Such charges are automatically dropped at
 rmdir() if there are no tasks.
 
-5. TODO
+5. Virtual address space accounting
+
+A new resource counter controls the address space expansion of the tasks in
+the cgroup. Address space control is provided along the same lines as
+RLIMIT_AS control, which is available via getrlimit(2)/setrlimit(2).
+The interface for controlling address space is provided through
+"as_limit_in_bytes". The file is similar to "limit_in_bytes" w.r.t the user
+interface. Please see section 3 for more details on how to use the user
+interface to get and set values.
+
+The "as_usage_in_bytes" file provides information about the total address
+space usage of the cgroup in bytes.
+
+5.1 Advantages of providing this feature
+
+1. Control over virtual address space allows for a cgroup to fail gracefully
+   i.e, via a malloc or mmap failure as compared to OOM kill when no
+   pages can be reclaimed
+2. It provides better control over how many pages can be swapped out when
+   the cgroup goes over it's limit. A badly setup cgroup can cause excessive
+   swapping. Providing control over the address space allocations ensures
+   that the system administrator has control over the total swapping that
+   can take place.
+
+6. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
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
