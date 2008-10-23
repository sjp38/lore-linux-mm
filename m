Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N90FZX001253
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Oct 2008 18:00:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 39A351B801E
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:00:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1069E2DC01F
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:00:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E97A41DB803C
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:00:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CE711DB803A
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:00:14 +0900 (JST)
Date: Thu, 23 Oct 2008 17:59:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/11] memcg: fix kconfig menu comment
Message-Id: <20081023175946.8c67a51f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

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
+	  disable memoyr resource controller and you can avoid overheads.
+	  (and lose benefits of memory resource contoller)
 
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
