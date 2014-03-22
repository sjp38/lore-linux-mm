Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E67FC6B0075
	for <linux-mm@kvack.org>; Sat, 22 Mar 2014 16:49:38 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so3858012pad.1
        for <linux-mm@kvack.org>; Sat, 22 Mar 2014 13:49:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tm9si6206319pab.305.2014.03.22.13.49.37
        for <linux-mm@kvack.org>;
        Sat, 22 Mar 2014 13:49:38 -0700 (PDT)
Date: Sun, 23 Mar 2014 04:49:27 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 191/463] mm/memcontrol.c:1074:19: sparse: symbol
 'get_mem_cgroup_from_mm' was not declared. Should it be static?
Message-ID: <532df757.AkU5AH07Cpb86z5c%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_532df757.iEvTk5usfvEOJpM+clOTd00Qg/JP32NnGQ3nxOkrs9qJ5cmo"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_532df757.iEvTk5usfvEOJpM+clOTd00Qg/JP32NnGQ3nxOkrs9qJ5cmo
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   06ed26d1de59ce7cbbe68378b7e470be169750e5
commit: 83ab64d4c75418a019166519d2f95015868f79a4 [191/463] memcg: get_mem_cgroup_from_mm()
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/memcontrol.c:1074:19: sparse: symbol 'get_mem_cgroup_from_mm' was not declared. Should it be static?
   mm/slab.h:182:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/slab.h:182:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/slab.h:182:18: sparse: incompatible types in comparison expression (different address spaces)
   mm/memcontrol.c:5562:21: sparse: incompatible types in comparison expression (different address spaces)
   mm/memcontrol.c:5564:21: sparse: incompatible types in comparison expression (different address spaces)
   mm/memcontrol.c:7015:31: sparse: incompatible types in comparison expression (different address spaces)

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_532df757.iEvTk5usfvEOJpM+clOTd00Qg/JP32NnGQ3nxOkrs9qJ5cmo
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-83ab64d4c75418a019166519d2f95015868f79a4.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH next] memcg: get_mem_cgroup_from_mm() can be static
TO: Johannes Weiner <hannes@cmpxchg.org>
CC: cgroups@vger.kernel.org 
CC: linux-mm@kvack.org 
CC: linux-kernel@vger.kernel.org 

CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 28fd509..bdb62eb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1071,7 +1071,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 	return mem_cgroup_from_css(task_css(p, mem_cgroup_subsys_id));
 }
 
-struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
+static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;
 

--=_532df757.iEvTk5usfvEOJpM+clOTd00Qg/JP32NnGQ3nxOkrs9qJ5cmo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
