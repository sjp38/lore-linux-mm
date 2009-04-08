Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3421C5F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 01:21:54 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n385MBkf015963
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Apr 2009 14:22:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 17A4D45DE52
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 14:22:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E92F045DE51
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 14:22:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D90241DB8043
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 14:22:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CC421DB805B
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 14:22:10 +0900 (JST)
Date: Wed, 8 Apr 2009 14:20:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg remove warning at DEBUG_VM=off
Message-Id: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
This is against 2.6.30-rc1. (maybe no problem against mmotm.)

==
Fix warning as

  CC      mm/memcontrol.o
mm/memcontrol.c:318: warning: ‘mem_cgroup_is_obsolete’ defined but not used

This is called only from VM_BUG_ON().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: linux-2.6.30-rc1/mm/memcontrol.c
===================================================================
--- linux-2.6.30-rc1.orig/mm/memcontrol.c
+++ linux-2.6.30-rc1/mm/memcontrol.c
@@ -314,13 +314,14 @@ static struct mem_cgroup *try_get_mem_cg
 	return mem;
 }
 
+#ifdef CONFIG_DEBUG_VM
 static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
 {
 	if (!mem)
 		return true;
 	return css_is_removed(&mem->css);
 }
-
+#endif
 
 /*
  * Call callback function against all cgroup under hierarchy tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
