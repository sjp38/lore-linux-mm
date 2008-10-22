Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9M1tQR8015635
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Oct 2008 10:55:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F7B1B801E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:55:26 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C6AE2DC01E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:55:26 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DE501DB803C
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:55:26 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id D11721DB8044
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 10:55:25 +0900 (JST)
Date: Wed, 22 Oct 2008 10:54:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: uptodate menuconfig help text
Message-Id: <20081022105459.3f7f2485.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Now, page_cgroup is allocated at boot and memmap doesn't includes pointer for
page_cgroup.
Fixes menu help text for memcg-allocate-page-cgroup-at-boot.patch.

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 init/Kconfig |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
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
+	  disable memory resource controller and you can avoid overheads.
+	  (and lose benefits of memory resource contoller)
 
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
