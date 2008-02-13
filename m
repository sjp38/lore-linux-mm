Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1DFG4ms020168
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:16:04 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DFFpN1151716
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 08:15:52 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1DFFlBP023341
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 08:15:49 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2008 20:42:56 +0530
Message-Id: <20080213151256.7529.59791.sendpatchset@localhost.localdomain>
In-Reply-To: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
Subject: [RFC] [PATCH 4/4] Add soft limit documentation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Paul Menage <menage@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Add documentation for the soft limit feature.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memory.txt |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff -puN Documentation/controllers/memory.txt~memory-controller-add-soft-limit-documentation Documentation/controllers/memory.txt
--- linux-2.6.24/Documentation/controllers/memory.txt~memory-controller-add-soft-limit-documentation	2008-02-13 18:45:40.000000000 +0530
+++ linux-2.6.24-balbir/Documentation/controllers/memory.txt	2008-02-13 18:49:58.000000000 +0530
@@ -201,6 +201,22 @@ The memory.force_empty gives an interfac
 
 will drop all charges in cgroup. Currently, this is maintained for test.
 
+The file memory.soft_limit_in_bytes allows users to set soft limits. A soft
+limit is set in a manner similar to limit. The limit feature described
+earlier is a hard limit, a group can never exceed it's hard limit. A soft
+limit on the other hand can be exceeded. A group will be shrunk back
+to it's soft limit, when there is memory pressure/contention.
+
+Ideally the soft limit should always be set to a value smaller than the
+hard limit. However, the code does not force the user to do so. The soft
+limit can be greater than the hard limit; then the soft limit has
+no meaning in that setup, since the group will alwasy be restrained to its
+hard limit.
+
+Example setting of soft limit
+
+# echo -n 100M > memory.soft_limit_in_bytes
+
 4. Testing
 
 Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
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
