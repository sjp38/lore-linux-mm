Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L6BVlv012801
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 15:11:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A8A852AC02A
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:11:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84E4912C049
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:11:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FBEF1DB803B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:11:31 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCCE1DB8042
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:11:31 +0900 (JST)
Date: Tue, 21 Oct 2008 15:11:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: Fix init/Kconfig documentation
Message-Id: <20081021151105.f13ec6d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021055118.GA11429@balbir.in.ibm.com>
References: <20081021055118.GA11429@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 11:21:18 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> Date: Tue, 21 Oct 2008 11:12:45 +0530
> Subject: [PATCH] memcg: Update Kconfig to remove the struct page overhead statement.
> 
> The memory resource controller no longer has a struct page overhead
> associated with it. The init/Kconfig help has been replaced with
> something more suitable based on the current implementation.
> 
Oh, this is my version..could you merge if this includes something good ?

==
Fixes menu help text for memcg-allocate-page-cgroup-at-boot.patch.


Signed-off-by: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 init/Kconfig |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: mmotm-2.6.27+/init/Kconfig
===================================================================
--- mmotm-2.6.27+.orig/init/Kconfig
+++ mmotm-2.6.27+/init/Kconfig
@@ -401,16 +401,20 @@ config CGROUP_MEM_RES_CTLR
 	depends on CGROUPS && RESOURCE_COUNTERS
 	select MM_OWNER
 	help
-	  Provides a memory resource controller that manages both page cache and
-	  RSS memory.
+	  Provides a memory resource controller that manages both anonymous
+	  memory and page cache. (See Documentation/controllers/memory.txt)
 
 	  Note that setting this option increases fixed memory overhead
-	  associated with each page of memory in the system by 4/8 bytes
-	  and also increases cache misses because struct page on many 64bit
-	  systems will not fit into a single cache line anymore.
+	  associated with each page of memory in the system. By this,
+	  20(40)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
+	  usage tracking struct at boot. Total amount of this is printed out
+	  at boot.
 
 	  Only enable when you're ok with these trade offs and really
-	  sure you need the memory resource controller.
+	  sure you need the memory resource controller. Even when you enable
+	  this, you can set "cgroup_disable=memory" at your boot option to
+	  disable memory resource controller and you can avoid almost all bads.
+	  (and lost benefits of memory resource contoller)
 
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
