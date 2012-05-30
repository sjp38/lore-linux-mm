Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EC76E6B0082
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:40:08 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 30 May 2012 20:10:06 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4UEe33011731242
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:10:03 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4UK9IhI027921
	for <linux-mm@kvack.org>; Thu, 31 May 2012 06:09:19 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 14/14] hugetlb: add HugeTLB controller documentation
Date: Wed, 30 May 2012 20:08:59 +0530
Message-Id: <1338388739-22919-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 Documentation/cgroups/hugetlb.txt |   45 +++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)
 create mode 100644 Documentation/cgroups/hugetlb.txt

diff --git a/Documentation/cgroups/hugetlb.txt b/Documentation/cgroups/hugetlb.txt
new file mode 100644
index 0000000..a9faaca
--- /dev/null
+++ b/Documentation/cgroups/hugetlb.txt
@@ -0,0 +1,45 @@
+HugeTLB Controller
+-------------------
+
+The HugeTLB controller allows to limit the HugeTLB usage per control group and
+enforces the controller limit during page fault. Since HugeTLB doesn't
+support page reclaim, enforcing the limit at page fault time implies that,
+the application will get SIGBUS signal if it tries to access HugeTLB pages
+beyond its limit. This requires the application to know beforehand how much
+HugeTLB pages it would require for its use.
+
+HugeTLB controller can be created by first mounting the cgroup filesystem.
+
+# mount -t cgroup -o hugetlb none /sys/fs/cgroup
+
+With the above step, the initial or the parent HugeTLB group becomes
+visible at /sys/fs/cgroup. At bootup, this group includes all the tasks in
+the system. /sys/fs/cgroup/tasks lists the tasks in this cgroup.
+
+New groups can be created under the parent group /sys/fs/cgroup.
+
+# cd /sys/fs/cgroup
+# mkdir g1
+# echo $$ > g1/tasks
+
+The above steps create a new group g1 and move the current shell
+process (bash) into it.
+
+Brief summary of control files
+
+ hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
+ hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
+ hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
+ hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
+
+For a system supporting two hugepage size (16M and 16G) the control
+files include:
+
+hugetlb.16GB.limit_in_bytes
+hugetlb.16GB.max_usage_in_bytes
+hugetlb.16GB.usage_in_bytes
+hugetlb.16GB.failcnt
+hugetlb.16MB.limit_in_bytes
+hugetlb.16MB.max_usage_in_bytes
+hugetlb.16MB.usage_in_bytes
+hugetlb.16MB.failcnt
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
