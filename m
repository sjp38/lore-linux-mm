Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m9L5xG2l002400
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:29:16 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9L5xGTx925708
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:29:16 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m9L5xFws022633
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 16:59:15 +1100
Date: Tue, 21 Oct 2008 11:21:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: memcg: Fix init/Kconfig documentation
Message-ID: <20081021055118.GA11429@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 21 Oct 2008 11:12:45 +0530
Subject: [PATCH] memcg: Update Kconfig to remove the struct page overhead statement.
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

The memory resource controller no longer has a struct page overhead
associated with it. The init/Kconfig help has been replaced with
something more suitable based on the current implementation.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 init/Kconfig |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 113c74c..1847f87 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -404,13 +404,10 @@ config CGROUP_MEM_RES_CTLR
 	  Provides a memory resource controller that manages both page cache and
 	  RSS memory.
 
-	  Note that setting this option increases fixed memory overhead
-	  associated with each page of memory in the system by 4/8 bytes
-	  and also increases cache misses because struct page on many 64bit
-	  systems will not fit into a single cache line anymore.
-
-	  Only enable when you're ok with these trade offs and really
-	  sure you need the memory resource controller.
+	  The config option adds a small memory overhead proportional to the
+	  size of memory. The controller can be disabled at run time by
+	  using the cgroup_disable=memory option, at which point the overhead
+	  disappears.
 
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
-- 
1.5.6.3


        Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
