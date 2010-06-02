Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 717B36B01B6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 21:04:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5214s99001478
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Jun 2010 10:04:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 28D2E45DE50
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 10:04:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AECA45DE4F
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 10:04:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E353AE18001
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 10:04:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A04511DB8048
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 10:04:53 +0900 (JST)
Date: Wed, 2 Jun 2010 10:00:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg remove experimental from swap account config
Message-Id: <20100602100038.34149d10.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It's 11 months since we changed swap_map[] to indicates SWAP_HAS_CACHE.
Since that, memcg's swap accounting has been very stable and it seems
it can be maintained.

So, I'd like to remove EXPERIMENTAL from the config.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 init/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: mmotm-2.6.34-May21/init/Kconfig
===================================================================
--- mmotm-2.6.34-May21.orig/init/Kconfig
+++ mmotm-2.6.34-May21/init/Kconfig
@@ -577,8 +577,8 @@ config CGROUP_MEM_RES_CTLR
 	  could in turn add some fork/exit overhead.
 
 config CGROUP_MEM_RES_CTLR_SWAP
-	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
-	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
+	bool "Memory Resource Controller Swap Extension"
+	depends on CGROUP_MEM_RES_CTLR && SWAP
 	help
 	  Add swap management feature to memory resource controller. When you
 	  enable this, you can limit mem+swap usage per cgroup. In other words,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
