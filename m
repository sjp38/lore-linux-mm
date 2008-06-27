Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5RFIUfV018033
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:18:30 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5RFIK2I152950
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 09:18:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5RFIJ6p024801
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 09:18:20 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 27 Jun 2008 20:48:18 +0530
Message-Id: <20080627151818.31664.69486.sendpatchset@balbir-laptop>
In-Reply-To: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
Subject: [RFC 1/5] Memory controller soft limit documentation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Add documentation for the soft limit feature.

Changelog v2 (Thanks to the review by Randy Dunlap)
1. Change several misuses of it's to its
2. Fix spelling errors and punctuation

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memory.txt |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff -puN Documentation/controllers/memory.txt~memory-controller-soft-limit-add-documentation Documentation/controllers/memory.txt
--- linux-2.6.26-rc5/Documentation/controllers/memory.txt~memory-controller-soft-limit-add-documentation	2008-06-27 20:43:04.000000000 +0530
+++ linux-2.6.26-rc5-balbir/Documentation/controllers/memory.txt	2008-06-27 20:43:04.000000000 +0530
@@ -205,6 +205,22 @@ The memory.force_empty gives an interfac
 
 will drop all charges in cgroup. Currently, this is maintained for test.
 
+The file memory.soft_limit_in_bytes allows users to set soft limits. A soft
+limit is set in a manner similar to limit. The limit feature described
+earlier is a hard limit. A group can never exceed its hard limit. A soft
+limit on the other hand can be exceeded. A group will be shrunk back
+to its soft limit, when there is memory pressure/contention.
+
+Ideally the soft limit should always be set to a value smaller than the
+hard limit. However, the code does not force the user to do so. The soft
+limit can be greater than the hard limit; then the soft limit has
+no meaning in that setup, since the group will always be restrained to its
+hard limit.
+
+Example setting of soft limit
+
+# echo 100M > memory.soft_limit_in_bytes
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
